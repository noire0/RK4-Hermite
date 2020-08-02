# RK4-Hermite
Programs for calculating or integrating the solution of various differential equations.
The fortran directory contains the code used to write tables of X and Y coordinates. Such tables can be graphed in python with matplotlib, and so, I include two python scripts to interpret the data obtained from the differential equations. 
You should be able to edit fortran code, the most relevant change you can do is changing the functions "Dv" and "RK4", from there you will be able to solve any differential equation that RK4 could be used for.
Just notice that, it is written for Hermite_n, that is to say "Dv" is actually a function of x, y, Dy and a number n. So changes will also need a new main program.
This repository works better as a fortran reference than as a user centric program. So I will not add many features in the future, if any.
## Still needs some work
The python scripts use default colors, nothing fancy, but you can see the name of the filenames (of the graphs) used in fortran. 
Some of the functionality you are reading here is still in work though, but I think it won't change much from here.
## Compile and run
Just run compile.sh, works for my default shell (zsh) or just the default sh fedora has.
Running run.sh does as expected, but it's not as simple without an explanation. It creates files in fortran/rk4 and fortran/poly, which have X and Y coordinates to graph on python. 
## Graphs
By default my python scripts will look exactly there, so if you wat to use the python scripts for something else you have to change the directories, it's actually easy since they only appear once in the python scripts.
## Warnings
Fortran compilers that don't include f2008 standards don't have the gamma function, you will have to write it by yourself and include it in the code.
