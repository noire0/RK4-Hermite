#!/bin/sh
cd fortran
rm *.mod bin/*
cd graphs
rm *.mod bin/* rk4/* poly/*
cd ../..
rm graphs/*
echo 'Done'
