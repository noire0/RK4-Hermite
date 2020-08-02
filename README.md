# RK4-Hermite
Libraries for calculating or integrating the solution of various differential equations.
The fortran directory contains the code used to write tables of X and Y coordinates. Such tables can be graphed in python with matplotlib, and so, I include two python scripts to interpret the data obtained from the differential equations. 
## Still in work
The python scripts use default colors, nothing fancy, but you can see the name of the original equations used in fortran. Given that when you run the fortran executables, you will choose a name for the differential equation solution, if you don't want a different name it will use a default.
Some of the functionality you are reading here is still in work though, I will edit this README when I finish, and I will try to inlcude a makefile.
# Compile and run
Just run compile.sh, works for my default shell (zsh) or just the default sh fedora has.
Running run.sh does as expected, but it's not as simple without an explanation. It creates files in fortran/rk4 and fortran/poly, which have X and Y coordinates to graph on python. 
## Graphs
By default my python scripts will look exactly there, so if you wat to use the python scripts for something else you have to change the directories, it's actually easy since they only appear once in the python scripts.
