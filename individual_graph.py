#!/bin/python
import matplotlib.pyplot as plt
import fnmatch
import os
import sys

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

def individual(A):
    for i in A:
    #    if not fnmatch.fnmatch(i, '*11.5*'):
        plt.plot(A[i][0],A[i][1],label=i[:-4])
        plt.legend(loc='upper left')
        plt.savefig(i[:-4]+'.png')
        plt.clf()

arguments = sys.argv
for i in range(1,len(arguments)):
    individual(addPlot(arguments[i]))
