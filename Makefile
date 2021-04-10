BASEDIR = $(shell pwd)
SRC = $(BASEDIR)/fortran
SRCEXT = .f

LIBDIR = $(SRC)/lib
OBJS = $(wildcard $(LIBDIR)/*{.o,.mod})
CLIBS = $(wildcard $(LIBDIR)/*_h$(SRCEXT))
CFLAGS = #-J$(LIBDIR)

# Integrals Fortran files
ISRC = $(SRC)/integrals
IFFILES = $(wildcard $(ISRC)/*$(SRCEXT))
IBINFILES = $(notdir $(basename $(IFFILES)))
ILIBS = $(foreach obj, rk4_h$(SRCEXT) poly_h$(SRCEXT), $(LIBDIR)/$(obj)$(SRCEXT))
# Tables Fortran files
TSRC = $(SRC)/tables
TFFILES = $(wildcard $(TSRC)/*$(SRCEXT))
TBINFILES = $(notdir $(basename $(TFFILES)))
TLIBS = $(CLIBS)

# Files after compilation
ACFILES = bin tables graphs build $(shell `echo `find -regex ".+\.\(mod\|o\)$$"``)

.PHONY: clean integrals tables test run graphs
	
graphs: tables
	./py/graphs.py tables/poly tables/rk4

integrals: $(IBINFILES)
	./bin/integral_rk4 && printf "\a\n" 
	./bin/integral_poly && printf "\a\n"

tables: $(TBINFILES)
	mkdir -p tables/rk4 && cd tables/rk4 && $(BASEDIR)/bin/table_rk4
	mkdir -p tables/poly && cd tables/poly && $(BASEDIR)/bin/table_poly
	cd tables && $(BASEDIR)/table_rk4-poly-ratio
	
clean:
	rm -rf $(ACFILES)

# Build template for BINFILES
define FPROGRAM_T =
$(notdir $(basename $(1))):
	mkdir -p bin && \
	mkdir -p build && cd build && \
	gfortran -c $(2) $(CFLAGS) && \
	gfortran -c $(1) $(CFLAGS) && \
	gfortran -o $(BASEDIR)/bin/$(notdir $(basename $(1))) \
	  $(foreach obj, $(notdir $(basename $(1) $(2))), $(obj).o) \
	  $(CFLAGS)
endef

# Integral targets
$(foreach program,$(IFFILES), \
  $(eval $(call FPROGRAM_T,$(program),$(ILIBS))))

# Table targets
$(foreach program,$(TFFILES), \
  $(eval $(call FPROGRAM_T,$(program),$(TLIBS))))