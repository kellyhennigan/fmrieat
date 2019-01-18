#!/bin/bash

##############################################

# usage: download raw data using flywheel CLI

# WARNING: IF A SCAN WAS RE-RUN, THIS SCRIPT WILL DO THE WRONG THING 
# AND TAKE JUST THE FIRST (BAD) SCAN. THIS REQUIRES CAREFULLY MANUAL 
# CHECKING OF THE SCANS!!!! 
# (I haven't figured out how to correct this with flywheel CLI yet...)

# ALSO NOTE: before running this, I need to log into flywheel first:
# fw login cni.flywheel.io:faKngx7782veTjZPM9

# code to iterate through 2 arrays: 
# A1=( "subj1" "subj2" "subj3" "subj4" )
# A2=( "s1" "s2" "s3" "s4" )
# for ((i=0;i<4;++i)); do
# printf "%s and then %s\n" "${A1[i]}" "${A2[i]}"
# done


# ga181112	19072
# gm181112	19073
# ks181114	19095
# tr181126	19179
# id181126	19180
# ap181126	19181
# pm181126	19182
# js181128	19200

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

cmd="fw login cni.flywheel.io:faKngx7782veTjZPM9"
eval $cmd
	
echo WORKING ON SUBJECT $subject

# subject directory 
subjDir=$dataDir/$subject
if [ ! -d "$subjDir" ]; then
	mkdir $subjDir
fi 

# raw subdirectories
cd $subjDir
mkdir qt1 anat func dwi


################################################################################


############# quant t1 calibration file
if [ "$cal_qt1num" != "0" ]; then

	# check how many files there are: 
	scanStr='SS-SMS T1 2mm pe1 CAL'
	outFilePath='qt1/qt1_cal.nii.gz'
	outPhaseFilePath='qt1/qt1_cal_phase.nii.gz'
	
	cmd="fw ls \"knutson/fmrieat/${cniID}\" --ids | grep '${scanStr}' | wc -l"
	nscans=$(eval $cmd)

	# if no scans are found with that string, skip the scan 
	if [ "$nscans" -lt "1" ]; then
		printf "\n\n\nCOULDNT FIND SCAN ID FOR ${scanStr}, SO SKIPPING...\n\n"
	else 	

		# if 1 scans is found, great! continue
		if [ "$nscans" -eq "1" ]; then
			printf "\n\n\n1 SCAN FOUND FOR ${scanStr} SO ALL IS GOOD...\n\n\n"
			cmd="fw ls \"knutson/fmrieat/${cniID}\" --ids | grep '${scanStr}'"
			scanID=$(eval $cmd | awk '{print $1}')
		
		# if >1 scans are found, take the last one (this assumes its the right one to take)
		elif [ "$nscans" -gt "1" ]; then
			printf "\n\n\nMORE THAN 1 SCAN FOUND FOR ${scanStr};\nCONFIRM THAT THE LAST ONE IS THE CORRECT ONE\n\n\n"
			cmd="fw ls \"knutson/fmrieat/${cniID}\" --ids | grep '${scanStr}' | tail -n 1"
			scanID=$(eval $cmd | awk '{print $1}')
		fi 	
		
		# cal file
		cmd="fw ls \"knutson/fmrieat/${cniID}/${scanID}/files\" | grep '1.nii'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/fmrieat/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command

		# phase file
		cmd="fw ls \"knutson/fmrieat/${cniID}/${scanID}/files\" | grep 'phase.nii'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/fmrieat/${cniID}/${scanID}/${fileName}\" -o ${outPhaseFilePath}"
		echo $cmd
		eval $cmd	# execute the command
	fi

fi

echo done with $scanStr


############# quant t1 file
if [ "$qt1num" != "0" ]; then

	# check how many files there are: 
	scanStr='SS-SMS T1 2mm pe0'
	outFilePath='qt1/qt1.nii.gz'
	outPhaseFilePath='qt1/qt1_phase.nii.gz'

	cmd="fw ls \"knutson/fmrieat/${cniID}\" --ids | grep '${scanStr}' | wc -l"
	nscans=$(eval $cmd)

	# if no scans are found with that string, skip the scan 
	if [ "$nscans" -lt "1" ]; then
		printf "\n\n\nCOULDNT FIND SCAN ID FOR ${scanStr}, SO SKIPPING...\n\n"
	else 	

		# if 1 scans is found, great! continue
		if [ "$nscans" -eq "1" ]; then
			printf "\n\n\n1 SCAN FOUND FOR ${scanStr} SO ALL IS GOOD...\n\n\n"
			cmd="fw ls \"knutson/fmrieat/${cniID}\" --ids | grep '${scanStr}'"
			scanID=$(eval $cmd | awk '{print $1}')
		
		# if >1 scans are found, take the last one (this assumes its the right one to take)
		elif [ "$nscans" -gt "1" ]; then
			printf "\n\n\nMORE THAN 1 SCAN FOUND FOR ${scanStr};\nCONFIRM THAT THE LAST ONE IS THE CORRECT ONE\n\n\n"
			cmd="fw ls \"knutson/fmrieat/${cniID}\" --ids | grep '${scanStr}' | tail -n 1"
			scanID=$(eval $cmd | awk '{print $1}')
		fi 	
		
		cmd="fw ls \"knutson/fmrieat/${cniID}/${scanID}/files\" | grep '1.nii'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/fmrieat/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command

		# phase file
		cmd="fw ls \"knutson/fmrieat/${cniID}/${scanID}/files\" | grep 'phase.nii'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/fmrieat/${cniID}/${scanID}/${fileName}\" -o ${outPhaseFilePath}"
		echo $cmd
		eval $cmd	# execute the command
	fi

fi

echo done with $scanStr


########### t1-weighted file
if [ "$t1wnum" != "0" ]; then

	# check how many files there are: 
	scanStr='T1w .9mm BRAVO'
	outFilePath='anat/t1w.nii.gz'
	
	cmd="fw ls \"knutson/fmrieat/${cniID}\" --ids | grep '${scanStr}' | wc -l"
	nscans=$(eval $cmd)

	# if no scans are found with that string, skip the scan 
	if [ "$nscans" -lt "1" ]; then
		printf "\n\n\nCOULDNT FIND SCAN ID FOR ${scanStr}, SO SKIPPING...\n\n"
	else 	

		# if 1 scans is found, great! continue
		if [ "$nscans" -eq "1" ]; then
			printf "\n\n\n1 SCAN FOUND FOR ${scanStr} SO ALL IS GOOD...\n\n\n"
			cmd="fw ls \"knutson/fmrieat/${cniID}\" --ids | grep '${scanStr}'"
			scanID=$(eval $cmd | awk '{print $1}')
		
		# if >1 scans are found, take the last one (this assumes its the right one to take)
		elif [ "$nscans" -gt "1" ]; then
			printf "\n\n\nMORE THAN 1 SCAN FOUND FOR ${scanStr};\nCONFIRM THAT THE LAST ONE IS THE CORRECT ONE\n\n\n"
			cmd="fw ls \"knutson/fmrieat/${cniID}\" --ids | grep '${scanStr}' | tail -n 1"
			scanID=$(eval $cmd | awk '{print $1}')
		fi 	
		
		cmd="fw ls \"knutson/fmrieat/${cniID}/${scanID}/files\" | grep 'nii'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/fmrieat/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command
	fi

fi

echo done with $scanStr



######### cue data file
if [ "$cuenum" != "0" ]; then

	# check how many files there are: 
	scanStr='BOLD EPI 2.9mm 2sec CUE'
	outFilePath='func/cue1.nii.gz'
	
	cmd="fw ls \"knutson/fmrieat/${cniID}\" --ids | grep '${scanStr}' | wc -l"
	nscans=$(eval $cmd)

	# if no scans are found with that string, skip the scan 
	if [ "$nscans" -lt "1" ]; then
		printf "\n\n\nCOULDNT FIND SCAN ID FOR ${scanStr}, SO SKIPPING...\n\n"
	else 	

		# if 1 scans is found, great! continue
		if [ "$nscans" -eq "1" ]; then
			printf "\n\n\n1 SCAN FOUND FOR ${scanStr} SO ALL IS GOOD...\n\n\n"
			cmd="fw ls \"knutson/fmrieat/${cniID}\" --ids | grep '${scanStr}'"
			scanID=$(eval $cmd | awk '{print $1}')
		
		# if >1 scans are found, take the last one (this assumes its the right one to take)
		elif [ "$nscans" -gt "1" ]; then
			printf "\n\n\nMORE THAN 1 SCAN FOUND FOR ${scanStr};\nCONFIRM THAT THE LAST ONE IS THE CORRECT ONE\n\n\n"
			cmd="fw ls \"knutson/fmrieat/${cniID}\" --ids | grep '${scanStr}' | tail -n 1"
			scanID=$(eval $cmd | awk '{print $1}')
		fi 	
		
		cmd="fw ls \"knutson/fmrieat/${cniID}/${scanID}/files\" | grep 'nii'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/fmrieat/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command
	fi

fi

echo done with $scanStr


############# DWI files
if [ "$dwinum" != "0" ]; then

	# check how many files there are: 
	scanStr='DTI 2mm b2500 96dir1'
	outDir='dwi'
	outFilePath=$outDir/dwi.nii.gz
	
	cmd="fw ls \"knutson/fmrieat/${cniID}\" --ids | grep '${scanStr}' | wc -l"
	nscans=$(eval $cmd)

	# if no scans are found with that string, skip the scan 
	if [ "$nscans" -lt "1" ]; then
		printf "\n\n\nCOULDNT FIND SCAN ID FOR ${scanStr}, SO SKIPPING...\n\n"
	else 	

		# if 1 scans is found, great! continue
		if [ "$nscans" -eq "1" ]; then
			printf "\n\n\n1 SCAN FOUND FOR ${scanStr} SO ALL IS GOOD...\n\n\n"
			cmd="fw ls \"knutson/fmrieat/${cniID}\" --ids | grep '${scanStr}'"
			scanID=$(eval $cmd | awk '{print $1}')
		
		# if >1 scans are found, take the last one (this assumes its the right one to take)
		elif [ "$nscans" -gt "1" ]; then
			printf "\n\n\nMORE THAN 1 SCAN FOUND FOR ${scanStr};\nCONFIRM THAT THE LAST ONE IS THE CORRECT ONE\n\n\n"
			cmd="fw ls \"knutson/fmrieat/${cniID}\" --ids | grep '${scanStr}' | tail -n 1"
			scanID=$(eval $cmd | awk '{print $1}')
		fi 	
		
		cmd="fw ls \"knutson/fmrieat/${cniID}/${scanID}/files\" | grep 'nii'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/fmrieat/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command

		# get bval and bvec files too:
		outFilePath=$outDir/bval
		cmd="fw ls \"knutson/fmrieat/${cniID}/${scanID}/files\" | grep 'bval'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/fmrieat/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command

		outFilePath=$outDir/bvec
		cmd="fw ls \"knutson/fmrieat/${cniID}/${scanID}/files\" | grep 'bvec'" 
		fileName=$(eval $cmd | awk '{print $5}')
		echo fileName: $fileName
		cmd="fw download \"knutson/fmrieat/${cniID}/${scanID}/${fileName}\" -o ${outFilePath}"
		echo $cmd
		eval $cmd	# execute the command

	fi

fi

echo done with $scanStr
	

ls qt1/*
ls anat/*
ls func/*
ls dwi/*




