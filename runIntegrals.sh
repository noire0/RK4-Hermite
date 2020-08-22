#!/bin/sh
# run computations in integral source files
cdToDir() {
	if [ -d $1 ]
	then
		cd $1
	else
		mkdir $1; cd $1
	fi
}
createDir() {
	if [ ! -d $1 ]
       	then
		mkdir $1
	fi
}
cdToDir fortran
createDir bin
for i in *.f; do
	gfortran ${i} -o bin/${i}
	./bin/${i}
done
cd ..
echo 'Done'
