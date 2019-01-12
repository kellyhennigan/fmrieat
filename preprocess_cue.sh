#!/bin/bash

##############################################

# usage: pre-processing pipeline for fmri cue reactivity task
# for project, fmrieat

# written by Kelly, Jan-2019

########## assumes the directory structure is: 

# fmrieat 					# main project dir
# fmrieat/scripts			# scripts dir
# fmrieat/dataDir 			# data dir
# fmrieat/data/subj1D 		# subject dir
# fmrieat/data/subj1D/raw 	# dir containing subject's raw data
# fmrieat/data/subj1D/func_proc # dir to contain subject's processed data (output dir)


######### assumes a subject's raw data is in a subject's "raw" directory and is named: 

# cue1.nii.gz 				# raw fmri data from cue reactivity task 
# t1_raw.nii.gz 			# raw t1-weighted data


# output files are: 

	# pp_cue.nii.gz - pre-processed cue data in subject's native space 
	# cue_enorm.1D - vector containing an estimate of movement (euclidean norm) from each volume to the next
	# cue_censor.1D - vector containing 0 for volumes with bad movement, otherwise 1
	# cue_vr.1D - matrix with the following columns: 
		# 1 is the volume number, 
		# 2-7 are the 6 motion parameter estimates, 
		# 8-9 are root mean square error from 1 volume to the next before (8) and after (9) motion correction

	# pp_cue_tlrc_afni.nii.gz - pre-processed data in tlrc space
	# cue_wm_ts.1D, cue_csf_ts.1D, cue_nacc_ts.1D - 1d files containing time series for masks of white matter, CSF, and NAcc ROI
	

#########################################################################
########################## DEFINE VARIABLES #############################
#########################################################################

# dataDir is the parent directory of subject-specific directories
# path should be relevant to where this script file sits
cd ../data
dataDir=$(pwd)


# subject ids to process
subjects='ga181112'  # e.g. 'aa190123'

# threshold for determining which volumes should be censored due to "bad" motion 
# (I use a threshold of 1 which seems good)
censor_thresh=1

# filepaths to ROI masks 
wmMaskFile=$dataDir/ROIs/wm_func.nii
csfMaskFile=$dataDir/ROIs/csf_func.nii
naccMaskFile=$dataDir/ROIs/nacc_func.nii

#########################################################################
############################# RUN IT ###################################
#########################################################################

for subject in $subjects
do
	
	echo WORKING ON SUBJECT $subject

	# subject input & output directories
	inDir=$dataDir/$subject/raw
	outDir=$dataDir/$subject/func_proc


	# make outDir & cd to it: 
	mkdir $outDir
	cd $outDir


	# drop the first 6 volumes to allow longitudinal magentization (t1) to reach steady state
	3dTcat -output cue1.nii.gz $inDir/cue1.nii.gz[6..$]


	# correct for slice time differences
	3dTshift -prefix tcue1.nii.gz -slice 0 -tpattern altplus cue1.nii.gz


	# clear out any pre-existing concatenated motion files 
	rm cue_vr.1D; rm cue_censor.1D; rm cue_enorm.1D


	# motion correction & saves out the motion parameters in file, 'cue1_vr.1D' 
	3dvolreg -Fourier -twopass -zpad 4 -dfile cue_vr.1D -base 4 -prefix mtcue1.nii.gz tcue1.nii.gz


	# create a “censor vector” that denotes bad movement volumes with a 0 and good volumes with a 1
	# to be used later for glm estimation and making timecourses
	1d_tool.py -infile vr_cue.1D[1..6] -show_censor_count -censor_prev_TR -censor_motion $censor_thresh cue
	rm cue_CENSORTR.txt
	

	# smooth data with a 4 mm full width half max gaussian kernel
	3dmerge -1blur_fwhm 4 -doall -quiet -prefix smtcue1.nii.gz mtcue1.nii.gz


	# calculate the mean timeseries for each voxel
	3dTstat -mean -prefix mean_cue1.nii.gz smtcue1.nii.gz


	# convert voxel values to be percent signal change
	cmd="3dcalc -a smtcue1.nii.gz -b mean_cue1.nii.gz -expr \"((a-b)/b)*100\" -prefix psmtcue1.nii.gz -datum float"
	echo $cmd	# print it out in terminal 
	eval $cmd	# execute the command


	# high-pass filter the data 
	3dFourier -highpass 0.011 -prefix fpsmtcue1.nii.gz psmtcue1.nii.gz


	# re-name pre=processed data "pp_cue.nii.gz"
	3dTcat -output pp_cue.nii.gz fpsmtcue1.nii.gz 


	# transform fmri data to tlrc space
	3dAllineate -base t1_tlrc_afni.nii.gz -1Dmatrix_apply xfs/cue2tlrc_xform_afni -prefix pp_cue_tlrc_afni -input pp_cue.nii.gz -verb -master BASE -mast_dxyz 2.9 -weight_frac 1.0 -maxrot 6 -maxshf 10 -VERB -warp aff -source_automask+4 -onepass
	3dAFNItoNIFTI -prefix pp_cue_tlrc_afni.nii.gz pp_cue_tlrc_afni+tlrc
	rm pp_cue_tlrc_afni+tlrc*


	# dump out WM, CSF, and nacc time series into separate files
	3dmaskave -mask $csfMaskFile -quiet -mrange 1 2 pp_cue_tlrc_afni.nii.gz > cue_csf_ts.1D
	3dmaskave -mask $wmMaskFile -quiet -mrange 1 2 pp_cue_tlrc_afni.nii.gz > cue_wm_ts.1D
	3dmaskave -mask $naccMaskFile -quiet -mrange 1 2 pp_cue_tlrc_afni.nii.gz > cue_nacc_ts.1D


	# remove intermediate files 
	# NOTE: ONLY DO THIS ONCE YOU'RE CONFIDENT THAT THE PIPELINE IS WORKING! 
	# (because you may want to view intermediate files to troubleshoot the pipeline)
	rm *cue1*



########################

done # subject loop



