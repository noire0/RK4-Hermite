#!/bin/python
import matplotlib.pyplot as plt
import fnmatch
import os

def openfile(filename):
    A = [[],[]]
    with open(filename) as array:
        for i in array:
            A[0].append(float(i.split()[0]))
            A[1].append(float(i.split()[1]))
    return A

def addPlot(location):
    A = dict()
    for filename in os.listdir(location):
        if fnmatch.fnmatch(filename, '*.txt'):
            A[filename] = openfile(location+'/'+filename)
#            print(filename)
    return A

def compare(A,B):
    for i in A:
        for j in B:
            if fnmatch.fnmatch(j, i[:10]+'*'):
                print(j+' matches '+i)
                plt.plot(A[i][0],A[i][1],label=i[:-4])
                plt.plot(B[j][0],B[j][1],label=j[:-4])
                plt.legend(loc='upper left')
                plt.savefig(i[:11]+' Comparison.png') #Hermite_5.6 son 11 chars
                plt.clf()

A = addPlot('fortran/poly')
B = addPlot('fortran/rk4')
compare(A,B)
