SHELL = /bin/bash
BASEDIR = $(shell pwd)
SRCDIR = $(BASEDIR)/fsrc
SRCEXT = .f
CFLAGS = -O2 #-fPIC -shared -g
CC = /usr/bin/gfortran

LIBDIR = $(SRCDIR)/lib
INT_SRCS = $(foreach libsrc, polynomial runge_kutta, $(LIBDIR)/$(libsrc)$(SRCEXT))
BASE_TABLES_SRCS = $(foreach libsrc, polynomial runge_kutta tables, $(LIBDIR)/$(libsrc)$(SRCEXT))
TABLES_SRCS = $(foreach libsrc, tables_poly_mod tables_rk4_mod, $(LIBDIR)/$(libsrc)$(SRCEXT))
RATIO_SRCS = $(foreach libsrc, tables_ratio_mod, $(LIBDIR)/$(libsrc)$(SRCEXT))

BASE_OBJS = $(foreach libsrc, $(BASE_TABLES_SRCS), $(notdir $(basename $(libsrc)).o))
TABLES_OBJS = $(foreach libsrc, $(TABLES_SRCS), $(notdir $(basename $(libsrc)).o))
RATIO_OBJS = $(foreach libsrc, $(RATIO_SRCS), $(notdir $(basename $(libsrc)).o))


# Integrals Fortran files
INT_SRCDIR = $(SRCDIR)/integrals
INT_SRCS = $(wildcard $(INT_SRCDIR)/*$(SRCEXT))
INT_BINS = $(notdir $(basename $(INT_SRCS)))

# Tables Fortran files
TAB_SRCDIR = $(SRCDIR)/tables
TAB_SRCS = $(wildcard $(TAB_SRCDIR)/*$(SRCEXT))
TAB_BINS = $(notdir $(basename $(TAB_SRCS)))

# Files after compilation
ACFILES = bin/* tables/* graphs/* build/* lib/*

.PHONY: clean integrals tables test run graphs objects lib
.ONESHELL:

build: $(TAB_BINS) $(INT_BINS)
	@echo Build all done
	@printf "\a"

graphs: tables
	@./py/graphs.py tables/poly tables/rk4
	@echo All graphs done
	@printf "\a"

integrals: $(INT_BINS)
	@./bin/integral_rk4
	@./bin/integral_poly
	@echo All integrals done

tables: $(TAB_BINS)
	@mkdir -p tables/rk4 && cd tables/rk4 && $(BASEDIR)/bin/tables_rk4 &&
	@echo RK4 tables done
	@cd $(BASEDIR)
	@mkdir -p tables/poly && cd tables/poly && $(BASEDIR)/bin/tables_poly &&
	@cd $(BASEDIR)
	@echo Polynomial tables done
	@cd tables && $(BASEDIR)/bin/tables_ratio &&
	@echo RK4 over polynomial tables done
	@cd $(BASEDIR)
	
clean:
	rm -rf $(ACFILES)
	
# OBJECT TARGETS
define OBJECT_TARGET =
$$(notdir $$(basename $(1))).o: $(2)
	@echo Building $$@
	@mkdir -p build && cd build &&
	@$$(CC) -o $$@ -c $(1) $$(CFLAGS)
endef

# LIBRARY TARGETS
define LIBRARY_TARGET =
$(1): $(2)
	@mkdir -p lib &&
	@cd build &&
	@ar rcs ../lib/$(1) $(2)
	@echo $(1) done
endef

# PROGRAM TARGETS
define PROGRAM_TARGET =
PROGRAM = $(notdir $(basename $(1)))
$$(PROGRAM): $(2)
	@mkdir -p bin && cd build &&
	@$$(CC) -c -o $$@.o $(1) $$(CFLAGS) &&
	@echo $$@.o done
	@$$(CC) -o $$(BASEDIR)/bin/$$@ $$@.o -L$$(BASEDIR)/lib -l$$(subst lib,,$$(subst .so,,$$<)) $$(CFLAGS) &&
	@echo bin/$$@ done
endef

# Gen BASE_OBJS
$(foreach objectsrc,$(BASE_TABLES_SRCS),$(eval $(call OBJECT_TARGET,$(objectsrc))))
# Gen TABLES_OBJS
$(foreach objectsrc,$(TABLES_SRCS),$(eval $(call OBJECT_TARGET,$(objectsrc),$(BASE_OBJS))))
# Gen RATIO_OBJS
$(foreach objectsrc,$(RATIO_SRCS),$(eval $(call OBJECT_TARGET,$(objectsrc),$(TABLES_OBJS))))

$(eval $(call LIBRARY_TARGET,librk4hermite1.so,$(BASE_OBJS)))
$(eval $(call LIBRARY_TARGET,librk4hermite2.so,$(TABLES_OBJS)))
$(eval $(call LIBRARY_TARGET,librk4hermite.so,$(RATIO_OBJS) $(BASE_OBJS) $(TABLES_OBJS)))

$(foreach program,$(INT_SRCS),$(eval $(call PROGRAM_TARGET,$(program),librk4hermite1.so)))
$(foreach program,$(TAB_SRCS),$(eval $(call PROGRAM_TARGET,$(program),librk4hermite.so)))