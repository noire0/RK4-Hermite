#!/bin/sh
cd fortran;
mkdir bin;
for i in *.f; do
	gfortran ${i} -o bin/${i};
done
cd ..
echo 'Done'
echo 'Compiled to fortran/bin'
