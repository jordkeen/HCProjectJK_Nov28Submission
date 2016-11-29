//main do-file for replication of Table 2 and Figures 1-3

//Preliminaries

//set home directory
global home "***\HCProjectJK_Nov28Submission"

//establish other directories
global raw "$home\rawData"
global scripts "$home\StataScripts"
global data "$home\StataData"
global graphs "$home\StataGraphs"
global logs "$home\StataLogs"
global regs "$home\StataRegressionOutput"
global tables "$home\Tables"
global figs "$home\Figures"
global matlab "$home\Matlab"

set more off
capture log close
set matsize 10000

//assemble data
do "$scripts\assembleData.do"

//replicate analysis
do "$scripts\makeTables.do"
do "$scripts\makeFigures.do"

//see m-file in Matlab folder to replicate Table 5 and Figure 4
