#!/bin/sh
# Create graphs in ./graphs folder
function cdToDir {
	if [ -d $1 ]
	then
		cd $1
	else
		mkdir $1; cd $1
	fi
}
function createDir {
	if [ ! -d $1 ]
       	then
		mkdir $1
	fi
}
cdToDir 'fortran/graphs'
createDir 'bin'
createDir 'rk4'
createDir 'poly'
for i in *.f; do
	gfortran ${i} -o bin/${i}
done
cd rk4; ../bin/*RK4*
cd ../poly; ../bin/*Poly*
cd ../../../graphs
../individual_graph.py ../fortran/graphs/rk4 ../fortran/graphs/poly
../comparative_graph.py ../fortran/graphs/rk4 ../fortran/graphs/poly
cd ..
echo 'Done'
