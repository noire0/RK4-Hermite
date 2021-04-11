SHELL = /bin/bash
BASEDIR = $(shell pwd)
SRCDIR = $(BASEDIR)/fortran
SRCEXT = .f
CFLAGS = -fPIC -shared -g -O2
CC = /usr/bin/gfortran

LIBDIR = $(SRCDIR)/lib
LIBSRCS1 = $(foreach libsrc, polynomial runge_kutta tables, $(LIBDIR)/$(libsrc)$(SRCEXT))
LIBSRCS2 = $(foreach libsrc, tables_poly_mod tables_rk4_mod, $(LIBDIR)/$(libsrc)$(SRCEXT))
LIBSRCS3 = $(foreach libsrc, tables_ratio_mod, $(LIBDIR)/$(libsrc)$(SRCEXT))

OBJS1 = $(foreach libsrc, $(LIBSRCS1), $(notdir $(basename $(libsrc)).o))
OBJS2 = $(foreach libsrc, $(LIBSRCS2), $(notdir $(basename $(libsrc)).o)) $(OBJS1)
OBJS = $(foreach libsrc, $(LIBSRCS3), $(notdir $(basename $(libsrc)).o)) $(OBJS2)


# Integrals Fortran files
INT_SRCDIR = $(SRCDIR)/integrals
INT_SRCS = $(wildcard $(INT_SRCDIR)/*$(SRCEXT))
INT_BINS = $(notdir $(basename $(INT_SRCS)))

# Tables Fortran files
TAB_SRCDIR = $(SRCDIR)/tables
TAB_SRCS = $(wildcard $(TAB_SRCDIR)/*$(SRCEXT))
TAB_BINS = $(notdir $(basename $(TAB_SRCS)))

# Files after compilation
ACFILES = bin tables graphs build/*

.PHONY: clean integrals tables test run graphs
.ONESHELL:

build: $(TAB_BINS) $(INT_BINS)

graphs: tables
	./py/graphs.py tables/poly tables/rk4

integrals: $(INT_BINS)
	./bin/integral_rk4 && printf "\a\n" 
	./bin/integral_poly && printf "\a\n"

tables: $(TAB_BINS)
	mkdir -p tables/rk4 && cd tables/rk4 && $(BASEDIR)/bin/tables_rk4; cd
	mkdir -p tables/poly && cd tables/poly && $(BASEDIR)/bin/tables_poly; cd
	cd tables && $(BASEDIR)/bin/tables_ratio
	
clean:
	rm -rf $(ACFILES)
	
# OBJECT TARGETS
define OBJECT_TARGET =
OBJ := $(notdir $(basename $(1))).o
$$(OBJ): $(2)
	@echo Building $$@
	@mkdir -p build && cd build &&
	@$$(CC) -o $$@ -c $(1) $$(CFLAGS)
endef
$(foreach objectsrc,$(LIBSRCS1),$(eval $(call OBJECT_TARGET,$(objectsrc))))
$(foreach objectsrc,$(LIBSRCS2),$(eval $(call OBJECT_TARGET,$(objectsrc),$(OBJS1))))
$(foreach objectsrc,$(LIBSRCS3),$(eval $(call OBJECT_TARGET,$(objectsrc),$(OBJS2))))

# LIBRARY TARGETS
define LIBRARY_TARGET =
$(1): $(2)
	@cd build &&
	ar rcs $(1) $(2)
endef
$(eval $(call LIBRARY_TARGET,lib1.so,$(OBJS1)))
$(eval $(call LIBRARY_TARGET,lib2.so,$(OBJS2)))
$(eval $(call LIBRARY_TARGET,liball.so,$(OBJS)))

# PROGRAM TARGETS
define PROGRAM_TARGET =
PROGRAM = $(notdir $(basename $(1)))
$$(PROGRAM): $(2)
	@echo Building $$@
	@mkdir -p bin && cd build &&
	@$$(CC) -c -o $$@.o $(1) $$(CFLAGS) &&
	@echo $$@.o done
	@$$(CC) -o $$(BASEDIR)/bin/$$@ $$@.o -L$$(BASEDIR)/build -l$$(subst lib,,$$(subst .so,,$$<)) $$(CFLAGS) &&
	@echo $$@ done
endef
$(foreach program,$(INT_SRCS),$(eval $(call PROGRAM_TARGET,$(program),lib1.so)))
$(foreach program,$(TAB_SRCS),$(eval $(call PROGRAM_TARGET,$(program),liball.so)))