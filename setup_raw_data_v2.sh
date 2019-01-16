#!/bin/bash

##############################################

# usage: download raw data using flywheel CLI

# WARNING: IF A SCAN WAS RE-RUN, THIS SCRIPT WILL DO THE WRONG THING 
# AND TAKE JUST THE FIRST (BAD) SCAN. THIS REQUIRES CAREFULLY MANUAL 
# CHECKING OF THE SCANS!!!! 
# (I haven't figured out how to correct this with flywheel CLI yet...)

# ALSO NOTE: before running this, I need to log into flywheel first:
# fw login cni.flywheel.io:faKngx7782veTjZPM9

#########################################################################
########################## DEFINE VARIABLES #############################
#########################################################################

# dataDir is the parent directory of subject-specific directories;
# path should be relative to where this script is saved
dataDir='../rawdata_bids' 


# subject ids to process
subject='gm181112'  # e.g. 'aa190123'

cniID='19073'


# set to 0 to skip a file, otherwise set to 1
cal_qt1num=1
qt1num=1
t1wnum=1
cuenum=1
dwinum=1

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
#mkdir func anat qt1 dwi


# t1-weighted file
if [ "$t1wnum" != "0" ]; then

	# make sure there's just 1 file: 
	scanStr='T1w .9mm BRAVO'
	outFilePath='anat/t1w.nii.gz'
	nscans=$(fw ls "knutson/fmrieat/${cniID}" --ids | grep ${scanStr} | wc -l)
	if [ "$nscans" -eq "1" ]; then
		printf("\n\n\n1 SCAN FOUND FOR ${scanStr} SO ALL IS GOOD...\n\n\n")
		scanID=$(fw ls "knutson/fmrieat/${cniID}" --ids | grep ${scanStr}  | awk '{print $1}')
		fileName=$(fw ls "knutson/fmrieat/${cniID}/${scanID}/files" | grep 'nii' | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/fmrieat/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command

	# if there's more than 1 scan with the same name, pick the last one
	elif [ "$nscans" -lt "1" ]; then
		printf "\n\n\nMORE THAN 1 SCAN FOUND FOR ${scanStr};\nCONFIRM THAT THE LAST ONE IS THE CORRECT ONE\n\n\n"
		scanID=$(fw ls "knutson/fmrieat/${cniID}" --ids | grep ${scanStr} | tail -n 1 | awk '{print $1}')
		fileName=$(fw ls "knutson/fmrieat/${cniID}/${scanID}/files" | grep 'nii' | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/fmrieat/${cniID}/${scanID}/${fileName}\" -o anat/t1w.nii.gz"
		echo $cmd
		eval $cmd	# execute the command

	# if no ID is found, skip it
	else	
		printf "\n\n\nCOULDNT FIND SCAN ID FOR ${scanStr}, SO SKIPPING...\n\n"
	fi

fi



# # # cue data file
# if [ "$cuenum" != "0" ]; then
# 	# get scan id for this file
# 	scanID=$(fw ls "knutson/fmrieat/${cniID}" --ids | grep 'BOLD EPI 2.9mm 2sec CUE' | awk '{print $1}')
# 	echo scanID: $scanID
# 	fileName=$(fw ls "knutson/fmrieat/${cniID}/${scanID}/files" | grep 'nii' | awk '{print $5}')
# 	echo fileName: $fileName
# 	cmd="fw download \"knutson/fmrieat/${cniID}/${scanID}/${fileName}\" -o anat/t1w.nii.gz"
# 	echo $cmd
# 	eval $cmd	# execute the command
# fi
# echo DONE


	


