#!/bin/sh
cd fortran;
function createDir {
	if [ ! -d $1 ]
       	then
		mkdir $1
	fi
}
createDir bin;
for i in *.f; do
	gfortran ${i} -o bin/${i};
done
echo 'Compiled to fortran/bin'
cd graphs
for i in *.f; do
	gfortran ${i} -o bin/${i};
done
echo 'Compiled to fortran/graphs/bin'
cd ../..
echo 'Done'
