CFLAGS =
LIBS =
# Fortran .f files with and without extension
FFILES = $(wildcard fortran/integrals/*.f)
FFILENAMES = $(notdir $(basename $(FFILES)))
GFFILES = $(wildcard fortran/graphs/*.f)
GFFILENAMES = $(notdir $(basename $(GFFILES)))

.PHONY: clean integrals graphs test run
	
integrals: $(FFILENAMES)

graphs: $(GFFILENAMES)

clean:
	rm -rf bin

# Build template
define FPROGRAM_T =
$(basename $(notdir $(1))):
	mkdir -p bin
	gfortran -o bin/$(basename $(notdir $(1))) $(1)
	@rm -f *.mod
endef

$(foreach program,$(FFILES),\
  $(eval $(call FPROGRAM_T,$(program))))

$(foreach program,$(GFFILES),\
  $(eval $(call FPROGRAM_T,$(program))))