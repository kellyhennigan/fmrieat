#!/bin/bash

##############################################

# usage: process anatomy for fmrieat project

# written by Kelly, Jan-2019 

# this script calculates the transforms to coregister 
# functional <-> anatomical (T1) data in native space, 
# anatomical data in native space <-> anatomical template in TLRC space, 
# and then these transforms are combined to get transform between 
# functional native space <-> TLRC space

# USE THIS SCRIPT IF YOU HAD TO MANUALLY NUDGE A T1W VOLUME TO MATCH ALIGNMENT OF FUNCTIONAL DATA

# to do that: 
# open afni, 
# > plugins> NUDGE
# > nudge t1 file to match functional volume 1
# > say "print" to print out nudge command and apply it to t1 data, eg: 
# 3drotate -quintic -clipit -rotate 0.00I 0.00R 0.00A -ashift 0.00S 0.00L 0.00P -prefix t1w.nii.gz t1w_nudge.nii.gz
# (resave nudged dataset as t1w_nudge)
# then mv new nudged file to anat raw dir




########## assumes the directory structure is: 

# fmrieat 					# main project dir
# fmrieat/scripts			# scripts dir
# fmrieat/dataDir 			# data dir
# fmrieat/data/subj1D 		# subject dir
# fmrieat/data/subj1D/raw 	# dir containing subject's raw data
# fmrieat/data/subj1D/func_proc # dir to contain subject's processed data (output dir)


######### assumes a subject's raw data is in a subject's "raw" directory and is named: 

# cue1.nii.gz 				# raw fmri data from cue reactivity task 
# t1w_nudge.nii.gz 			# raw t1-weighted data


######### output files are (all found in the output directory): 

	# t1_ns.nii.gz - skull-stripped anatomical volume 
	# t1_tlrc_afni.nii.gz - anatomical volume in tlrc space
	# vol1_cue_ns.nii.gz - 1st volume of functional data, skull-stripped
	# vol1_cue_tlrc_afni.nii.gz - 1st volume of functional data in tlrc space
	
	# the following transforms (saved in "xfs" subdirectory of output dir): 
		# cue2t1_xform_afni - functional > anatomical xform
		# cue2tlrc_xform_afni - functional > tlrc space xform
		# t12cue_xform_afni - anatomical > functional xform
		# t12tlrc_xform_afni - anatomical > tlrc space xform
		# t12tlrc_xform_afni.log - record of RMS for the co-registration

	

#########################################################################
########################## DEFINE VARIABLES #############################
#########################################################################

# dataDir is the parent directory of subject-specific directories
# path should be relevant to where this script file sits
cd ..
mainDir=$(pwd)

dataDir=$mainDir/rawdata_bids

t1_template=$mainDir/derivatives/templates/TT_N27.nii 

func_template=$mainDir/derivatives/templates/TT_N27_func_dim.nii 


cd $dataDir

# subject ids to process
#subjects='ga181112 tr181126 id181126 ap181126 pm181126 js181128 st181126 sa181203 fh181203 ar181204 rk181206 pc181210 as181210 ja181214 rs181219 js190106 an190106 se190106 ky190106'
#er190106 ag190107 hb190109 ty190109 kt190110 ms190110 ty190110 nh190110 sk190110 ak190110 as190111 ih190111 mx190114 km190114 bg190114_1 sl190114 bg190114_2 aa190115 mm190115 lg190117 ay190117'
subjects='hb190109'



#########################################################################
############################# RUN IT ###################################
#########################################################################

for subject in $subjects
do
	
	echo WORKING ON SUBJECT $subject

	# subject input directories
	inFuncDir=$dataDir/$subject/func
	inAnatDir=$dataDir/$subject/anat


	# subject output directories 
	outSubjDir=$mainDir/derivatives/$subject
	if [ ! -d "$outSubjDir" ]; then
		mkdir $outSubjDir
	fi 

	cd $outSubjDir

	outDir=func_proc
	if [ ! -d "$outDir" ]; then
		mkdir $outDir
	fi 	
	cd $outDir


	# also make a "xfs" directory to house all xform files
	mkdir xfs

	# remove skull from t1 anatomical data
	3dSkullStrip -prefix t1_ns.nii.gz -input $inAnatDir/t1w_nudge.nii.gz


	# estimate transform to put t1 in tlrc space
	@auto_tlrc -no_ss -base $t1_template -suffix _afni -input t1_ns.nii.gz


	# the @auto_tlrc command produces a bunch of extra files; clean them up 
	gzip t1_ns_afni.nii; 
	mv t1_ns_afni.nii.gz t1_tlrc_afni.nii.gz; 
	mv t1_ns_afni.Xat.1D xfs/t12tlrc_xform_afni; 
	mv t1_ns_afni.nii_WarpDrive.log xfs/t12tlrc_xform_afni.log; 
	rm t1_ns_afni.nii.Xaff12.1D


	# take first volume of raw functional data:
	3dTcat -output $inFuncDir/vol1_cue.nii.gz $inFuncDir/cue1.nii.gz[0]

	
	# skull-strip functional vol
	3dSkullStrip -prefix vol1_cue_ns.nii.gz -input $inFuncDir/vol1_cue.nii.gz


	# estimate xform between anatomy and functional data
	align_epi_anat.py -epi2anat -epi vol1_cue_ns.nii.gz -anat t1_ns.nii.gz -epi_base 0 -tlrc_apar t1_tlrc_afni.nii.gz -epi_strip None -anat_has_skull no

	
	# put in nifti format 
	3dAFNItoNIFTI -prefix vol1_cue_tlrc_afni.nii.gz vol1_cue_ns_tlrc_al+tlrc


	# clean up intermediate files
	rm vol1_cue_ns_tlrc_al+tlrc*
	mv t1_ns_al*aff12.1D xfs/t12cue_xform_afni; 
	mv vol1_cue_ns_al_mat.aff12.1D xfs/cue2t1_xform_afni; 
	mv vol1_cue_ns_al_tlrc_mat.aff12.1D xfs/cue2tlrc_xform_afni; 
	rm vol1_cue_ns_al_reg_mat.aff12.1D; 
	rm vol1_cue_ns_al+orig*


done # subject loop




