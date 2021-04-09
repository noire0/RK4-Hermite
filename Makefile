CFLAGS =
LIBS =

BASEDIR = $(shell pwd)

# Files after compilation
ACFILES = bin tables graphs

# Fortran .f files with and without extension
FFILES = $(wildcard fortran/integrals/*.f)
FFILENAMES = $(notdir $(basename $(FFILES)))
TFFILES = $(wildcard fortran/tables/*.f)
TFFILENAMES = $(notdir $(basename $(TFFILES)))

.PHONY: clean integrals tables test run graphs
	
graphs: tables
	./py/graphs.py tables/poly tables/rk4

integrals: $(FFILENAMES)
	./bin/integral_rk4 && printf "\a\n" 
	./bin/integral_poly && printf "\a\n"

tables: $(TFFILENAMES)
	mkdir -p tables/rk4 && cd tables/rk4 && $(BASEDIR)/bin/table_rk4
	mkdir -p tables/poly && cd tables/poly && $(BASEDIR)/bin/table_poly
	
clean:
	rm -rf $(ACFILES)

# Build template
define FPROGRAM_T =
$(basename $(notdir $(1))):
	mkdir -p bin
	gfortran -o bin/$(basename $(notdir $(1))) $(1)
	rm -f *.mod
endef

$(foreach program,$(FFILES),\
  $(eval $(call FPROGRAM_T,$(program))))

$(foreach program,$(TFFILES),\
  $(eval $(call FPROGRAM_T,$(program))))
