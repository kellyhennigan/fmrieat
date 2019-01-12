#!/bin/bash

##############################################

# usage: download raw data using flywheel CLI

# WARNING: IF A SCAN WAS RE-RUN, THIS SCRIPT WILL DO THE WRONG THING 
# AND TAKE JUST THE FIRST (BAD) SCAN. THIS REQUIRES CAREFULLY MANUAL 
# CHECKING OF THE SCANS!!!! 
# (I haven't figured out how to correct this with flywheel CLI yet...)

# ALSO NOTE: before running this, I need to log into flywheel first:
# fw login cni.flywheel.io:GM52n5tciGhJHBZX6C

#########################################################################
########################## DEFINE VARIABLES #############################
#########################################################################

# dataDir is the parent directory of subject-specific directories;
# path should be relative to where this script is saved
dataDir='../data' 


# subject ids to process
subject='ga181112'  # e.g. 'aa190123'

cniID='19072'


# set to 0 to skip a file
cal_qt1num=5
qt1num=6
t1wnum=7
cuenum=10
dwinum=12

#########################################################################
############################# RUN IT ###################################
#########################################################################

	
echo WORKING ON SUBJECT $subject

# subject directory 
subjDir=$dataDir/$subject
if [ ! -d "$subjDir" ]; then
	mkdir $subjDir
fi 

# raw subdirectory
inDir=$subjDir/raw
if [ ! -d "$inDir" ]; then
	mkdir $inDir
fi 

# cd to subject's raw data directory 
cd $inDir


# calibration quant-t1 file
if [ "$cal_qt1num" != "0" ]; then
cmd="fw download \"knutson/fmrieat/${cniID}/SS-SMS T1 2mm pe1 CAL/files/${cniID}_${cal_qt1num}_1.nii.gz\" -o qt1_cal.nii.gz"
eval $cmd	# execute the command
fi

# quant-t1 file
if [ "$qt1num" != "0" ]; then
cmd="fw download \"knutson/fmrieat/${cniID}/SS-SMS T1 2mm pe0/files/${cniID}_${qt1num}_1.nii.gz\" -o qt1.nii.gz"
eval $cmd	# execute the command
fi

# t1-weighted file
if [ "$t1wnum" != "0" ]; then
cmd="fw download \"knutson/fmrieat/${cniID}/T1w .9mm BRAVO/files/${cniID}_${t1wnum}_1.nii.gz\" -o t1w.nii.gz"
eval $cmd	# execute the command
fi


# cue data file
if [ "$cuenum" != "0" ]; then
cmd="fw download \"knutson/fmrieat/${cniID}/BOLD EPI 2.9mm 2sec CUE/files/${cniID}_${cuenum}_1.nii.gz\" -o cue1.nii.gz"
eval $cmd	# execute the command
fi


# DWI files
if [ "$dwinum" != "0" ]; then
cmd="fw download \"knutson/fmrieat/${cniID}/DTI 2mm b2500 96dir1/files/${cniID}_${dwinum}_1.nii.gz\" -o dwi.nii.gz"
eval $cmd	# execute the command
cmd="fw download \"knutson/fmrieat/${cniID}/DTI 2mm b2500 96dir1/files/${cniID}_${dwinum}_1.bvec\" -o bvec"
eval $cmd	# execute the command
cmd="fw download \"knutson/fmrieat/${cniID}/DTI 2mm b2500 96dir1/files/${cniID}_${dwinum}_1.bval\" -o bval"
eval $cmd	# execute the command
fi

echo DONE


	


