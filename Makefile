SHELL = /bin/bash
BASEDIR = $(shell pwd)
SRCDIR = $(BASEDIR)/fortran
SRCEXT = .f
CFLAGS = -fPIC -std=f2018 -static-libgfortran
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

graphs: tables
	./py/graphs.py tables/poly tables/rk4

integrals: $(INT_BINS)
	./bin/integral_rk4 && printf "\a\n" 
	./bin/integral_poly && printf "\a\n"

tables: $(TAB_BINS)
	mkdir -p tables/rk4 && cd tables/rk4 && $(BASEDIR)/bin/table_rk4
	mkdir -p tables/poly && cd tables/poly && $(BASEDIR)/bin/table_poly
	cd tables && $(BASEDIR)/bin/table_ratio
	
clean:
	rm -rf $(ACFILES)
	
# OBJECT TARGETS
define OBJECT_TARGET =
OBJ := $(notdir $(basename $(1))).o
.ONESHELL:
$$(OBJ): $(2)
	@mkdir -p build && cd build &&
	@$$(CC) -o $$@ -c $(1) $$(CFLAGS)
	@echo $$@ done
endef
$(foreach objectsrc,$(LIBSRCS1),$(eval $(call OBJECT_TARGET,$(objectsrc))))
$(foreach objectsrc,$(LIBSRCS2),$(eval $(call OBJECT_TARGET,$(objectsrc),$(OBJS1))))
$(foreach objectsrc,$(LIBSRCS3),$(eval $(call OBJECT_TARGET,$(objectsrc),$(OBJS2))))

# LIBRARY TARGETS
define LIBRARY_TARGET =
.ONESHELL:
$(1): $(2)
	@cd build &&
	ar rcs $(1) $(2)
endef
$(eval $(call LIBRARY_TARGET,lib1.a,$(OBJS1)))
$(eval $(call LIBRARY_TARGET,lib2.a,$(OBJS2)))
$(eval $(call LIBRARY_TARGET,lib.a,$(OBJS)))

# PROGRAM TARGETS
define PROGRAM_TARGET =
.ONESHELL:
PROGRAM = $(notdir $(basename $(1)))
$$(PROGRAM): $(2)
	@echo Building $$(PROGRAM)
	@mkdir -p bin && cd build &&
	@$$(CC) -c -o $$(PROGRAM).o $(1) $$(CFLAGS) &&
	@echo $$(PROGRAM).o done
	@$$(CC) -o $$(BASEDIR)/bin/$$(PROGRAM) $$(PROGRAM).o &&
	@echo $$(PROGRAM) done
endef
$(foreach program,$(INT_SRCS),$(eval $(call PROGRAM_TARGET,$(program),$(OBJS1))))
$(foreach program,$(TAB_SRCS),$(eval $(call PROGRAM_TARGET,$(program),$(OBJS))))