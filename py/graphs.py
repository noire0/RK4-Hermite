#!/bin/python
import matplotlib.pyplot as plt
import fnmatch
import os
import sys
import re

def openTable(filename):
    arr = dict()
    arr['X'] = list()
    arr['Y'] = list()
    handle = open(filename)
    for pair in handle:
        arr['X'].append(float(pair.split()[0]))
        arr['Y'].append(float(pair.split()[1]))
    return arr

def dictOfTablesInPath(location):
    dictOfTables = dict()
    for filename in os.listdir(location):
        if fnmatch.fnmatch(filename, "*.txt"):
            dictOfTables[filename[:-4]] = openTable(location+"/"+filename)
    return dictOfTables

def mkdir(string):
    if not os.path.exists(string):
        try:
            subDrs = string.split('/')
            print(*subDrs)
            currentDr = str()
            for i in range(len(subDrs)):
                currentDr += subDrs[i]+'/'
                if not os.path.exists(currentDr): os.mkdir(currentDr)
        except:
            print("Possible permission error.")
            
def compare(dictOfTablesA, dictOfTablesB, targetDirectory = "graphs/comparison_graphs/"):
    mkdir(targetDirectory)
    if targetDirectory[-1] != '/': targetDirectory += '/'

    regexp = "(^hermite_[0-9]+\.[0-9]+_).+$"
    for tableA in dictOfTablesA:
        for tableB in dictOfTablesB:
            if re.findall(regexp, tableA) == re.findall(regexp, tableB):
                print(tableB+" matches "+tableA)
                plt.plot(dictOfTablesA[tableA]['X'], dictOfTablesA[tableA]['Y'], label=tableA)
                plt.plot(dictOfTablesB[tableB]['X'], dictOfTablesB[tableB]['Y'], label=tableB)
                plt.legend(loc='upper left')
                plt.savefig(targetDirectory+tableA[:11]+"_comparison.png") #Hermite_5.6 are 11 chars
                plt.clf()
                
def individual(dictOfTables, targetDirectory = "graphs/individual_graphs/"):
    mkdir(targetDirectory)
    if targetDirectory[-1] != '/': targetDirectory += '/'
    for table in dictOfTables:
        #-4 removes extension of the file
        plt.style.use("classic")
        plt.figure(dpi=100, figsize=[12,9])
        x = dictOfTables[table]['X']
        y = dictOfTables[table]['Y']
        plt.plot(x, y, label=table)
        # Close inspection of the division of Hermite / RK4
        if re.findall("^ratio", table).__len__() > 0:
            plt.ylim((-4, 4))
            plt.grid(b=True, which="both", axis="both", linestyle="--")
        plt.legend(loc="upper left")
        plt.savefig(targetDirectory+table+".png")
        plt.clf()

if __name__ == "__main__":
    for i in range(1, len(sys.argv)):
        individual(dictOfTablesInPath(sys.argv[i]))
        print(sys.argv[i])
    if len(sys.argv) > 1:
        compare(dictOfTablesInPath(sys.argv[1]), dictOfTablesInPath(sys.argv[2]))