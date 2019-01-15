#!/bin/bash

##############################################

# usage: download raw data using flywheel CLI

# WARNING: IF A SCAN WAS RE-RUN, THIS SCRIPT WILL DO THE WRONG THING 
# AND TAKE JUST THE FIRST (BAD) SCAN. THIS REQUIRES CAREFULLY MANUAL 
# CHECKING OF THE SCANS!!!! 
# (I haven't figured out how to correct this with flywheel CLI yet...)

# ALSO NOTE: before running this, I need to log into flywheel first:
# fw login cni.flywheel.io:faKngx7782veTjZPM9


# NOTE: for duplicate scans with the same name, as of now they must be downloaded manually. 
# To do that, do this: 

# command to get ID for each scan: 
# fw ls "knutson/fmrieat/19073"

# that prints out scan IDs. Use that id to specify the desired scan 
# *** MAKE SURE ITS THE RIGHT ONE!!!
# fw download "knutson/fmrieat/19073/<id:5bea0806d1f71500151540db>/files/19073_9_1.nii.gz" -o func/cue1.nii.gz

#########################################################################
########################## DEFINE VARIABLES #############################
#########################################################################

# dataDir is the parent directory of subject-specific directories;
# path should be relative to where this script is saved
dataDir='../rawdata_bids' 


# subject ids to process
subject='gm181112'  # e.g. 'aa190123'

cniID='19073'


# set to 0 to skip a file
cal_qt1num=4
qt1num=5
t1wnum=6
cuenum=9
dwinum=11

#########################################################################
############################# RUN IT ###################################
#########################################################################

	
echo WORKING ON SUBJECT $subject

# subject directory 
subjDir=$dataDir/$subject
if [ ! -d "$subjDir" ]; then
	mkdir $subjDir
fi 

# raw subdirectories
cd $subjDir
mkdir func anat qt1 dwi



# calibration quant-t1 file
if [ "$cal_qt1num" != "0" ]; then
cmd="fw download \"knutson/fmrieat/${cniID}/SS-SMS T1 2mm pe1 CAL/files/${cniID}_${cal_qt1num}_1.nii.gz\" -o qt1/qt1_cal.nii.gz"
echo GET QUANT T1 files:
echo $cmd
eval $cmd	# execute the command
fi

# quant-t1 file
if [ "$qt1num" != "0" ]; then
cmd="fw download \"knutson/fmrieat/${cniID}/SS-SMS T1 2mm pe0/files/${cniID}_${qt1num}_1.nii.gz\" -o qt1/qt1.nii.gz"
echo GET QUANT T1 files:
echo $cmd
eval $cmd	# execute the command
fi

# t1-weighted file
if [ "$t1wnum" != "0" ]; then
cmd="fw download \"knutson/fmrieat/${cniID}/T1w .9mm BRAVO/files/${cniID}_${t1wnum}_1.nii.gz\" -o anat/t1w.nii.gz"
echo GET T1-WEIGHTED file:
echo $cmd
eval $cmd	# execute the command
fi


# cue data file
if [ "$cuenum" != "0" ]; then
cmd="fw download \"knutson/fmrieat/${cniID}/BOLD EPI 2.9mm 2sec CUE/files/${cniID}_${cuenum}_1.nii.gz\" -o func/cue1.nii.gz"
echo GET FMRI file:
echo $cmd
eval $cmd	# execute the command
fi


# DWI files
if [ "$dwinum" != "0" ]; then
cmd="fw download \"knutson/fmrieat/${cniID}/DTI 2mm b2500 96dir1/files/${cniID}_${dwinum}_1.nii.gz\" -o dwi/dwi.nii.gz"
echo GET DWI files:
echo $cmd
eval $cmd	# execute the command

cmd="fw download \"knutson/fmrieat/${cniID}/DTI 2mm b2500 96dir1/files/${cniID}_${dwinum}_1.bvec\" -o dwi/bvec"
echo $cmd
eval $cmd	# execute the command

cmd="fw download \"knutson/fmrieat/${cniID}/DTI 2mm b2500 96dir1/files/${cniID}_${dwinum}_1.bval\" -o dwi/bval"
echo $cmd
eval $cmd	# execute the command
fi

echo DONE


	


