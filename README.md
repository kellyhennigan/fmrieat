# Processing pipeline for fmrieat project 

This repository has code for processing functional mri (fmri) and diffusion mri (dmri) data collected for the fmrieat experiment. The pipelines are distinct and can be run in parallel. 


## Getting started


### Software requirements 

* [Python 2.7](https://www.python.org/)
* [Matlab](https://www.mathworks.com/products/matlab.html)
* [AFNI](https://afni.nimh.nih.gov/) (fmri pipeline only)
* [matlab package, VISTASOFT](https://github.com/vistalab/vistasoft) (dmri pipeline only)
* [spm as a VISTASOFT dependency](https://www.fil.ion.ucl.ac.uk/spm/) (dmri pipeline only)
* [AFQ](https://github.com/yeatmanlab/AFQ) (dmri pipeline only)
* [mrtrix 3.0](http://www.mrtrix.org/) (dmri pipeline only)
* [freesurfer](https://surfer.nmr.mgh.harvard.edu/) (dmri pipeline only)


### Permissions

make sure the user has permission to execute scripts. From a terminal command line, cd to the directory containing these scripts. Then type:
```
chmod 777 *sh
chmod 777 *py
```
to be able to execute them. This only needs to be run once. 


[fMRI pipeline](#fmri-pipeline)

- [Get raw mri data](#get-raw-mri-data)
- [Get behavioral data](#get-behavioral-data)
- [Estimate transforms from subject's native to standard space](#estimate-transforms-from-subject's-native-to-standard-space)
- [Pre-process fmri data](#pre-process-fmri-data)
- [Quality Assurance (QA)](#quality-assurance)
- [Get stimulus onset times and make regressors](#get-stimulus-onset-times-and-make-regressors)
- [Subject-level GLMs](#subject-level-glms)
- [Group-level whole brain analyses](#group-level-whole-brain-analyses)
- [Generate VOI timecourses](#generate-voi-timecourses)
- [Behavioral analyses](#behavioral-analyses)


[dMRI pipeline](#dmri-pipeline)

- [Acpc-align t1 data](#acpc-align-t1-data)
- [Run freesurfer recon](#run-freesurfer-recon)
- [Convert freesurfer files to nifti and save out ROI masks](#convert-freesurfer-files-to-nifti-and-save-out-roi-masks)
- [Convert midbrain ROI from standard > native space](#convert-midbrain-roi-from-standard->-native-space)
- [Pre-process diffusion data](#pre-process-diffusion-data)
- [Mrtrix pre-processing steps](#rtrix-pre-processing-steps)
- [Track fibers](#track-fibers)
- [Clean fiber bundles](#clean-fiber-bundles)
- [Save out measurements from fiber bundles cores](#save-out-measurements-from-fiber-bundles-cores)
- [Correlate diffusivity measures with behavioral and functional measures](#correlate-diffusivity-measures-with-behavioral-and-functional-measures)
- [Create density maps of fiber group endpoints](#create-density-maps-of-fiber-group-endpoints)



## fMRI pipeline


### Get raw mri data 
from a terminal command line, type:
```
./setup_raw_data.sh
```
this will copy over the raw MRI data from Flywheel into a BIDs-compatible directory structure.

#### output
this should create a directory, **fmrieat/rawdata_bids/subjid** where subjid is the subject id. This directory should contain: 
* func/cue1.nii.gz 		# fMRI data 
* anat/t1w.nii.gz 		# t1-weighted (anatomical) data 
* dwi/dwi.nii.gz		# diffusion MRI data
* dwi/bval				# b-values 
* dwi/bvec				# b-vectors 
* <i>(quantitative t1 scans are saved as well; pipeline for that to be added later)</i> 

### Get behavioral data 
In matlab, run:
```
setup_behavioral_data.m 
```
to save behavioral data (stim timing and ratings files) locally, then scp them to save them on vta server. (Or just manually scp them from Google drive folder to vta server)

#### output 
this should create the directory, **fmrieat/source/subjid/behavior**, which should contain:
* cue_matrix.csv	# stim timing file
* cue_ratings.csv 	# valence and arousal ratings



### Estimate transforms from subject's native to standard space
from a terminal command line, run: 
```
./preprocess_anat.sh
```
this script does the following using AFNI commands:
* skull strips t1 data using afni command "3dSkullStrip"
* aligns skull-stripped t1 data to t1 template in tlrc space using afni command @auto_tlrc, which allows for a 12 parameter affine transform
* pulls out the first volume of functional data to be co-registered to anatomy and skullstrips this volume using "3dSkullStrip"
* coregisters anatomy to functional data, and then calculates the transform from native functional space to standard group space (tlrc space)

#### output 
this should create the directory, **fmrieat/derivatives/subjid/func_proc**, which should contain: 		
* t1_ns.nii.gz 				# subject's t1 with no skull in native space
* t1_tlrc_afni.nii.gz		# " " in standard (tlrc) space
* vol1_cue_ns.nii.gz 		# 1st vol of fmri data with no skull in native space
* vol1_cue_tlrc_afni.nii.gz	# " " in standard space
* xfs 						# sub-directory containing all transforms 



### Pre-process fmri data
from a terminal command line, run:
```
./preprocess_cue.sh
```
this script does the following using AFNI commands:
* removes first 6 volumes from functional scan (to allow t1 to reach steady state)
* slice time correction
* motion correction (6-parameter rigid body)
* saves out a vector of which volumes have lots of motion (will use this to censor volumes in glm estimation step)
* spatially smooths data 
* converts data to be in units of percent change (mean=100; so a value of 101 means 1% signal change above that voxel's mean signal)
* highpass filters the data to remove low frequency fluctuations
* transforms pre-processed functional data into standard group (tlrc) space using transforms estimated in "preprocess_anat.sh" script
* saves out white matter, csf, and nacc VOI time series as single vector text files (e.g., 'cue_csf_ts.1D') 

#### output 
files saved out to directory **fmrieat/derivatives/subjid/func_proc** are: 
* pp_cue.nii.gz		# pre-processed fmri data in native space
* pp_cue_tlrc_afni.nii.gz		# " " in standard space
* cue_vr.1D			# volume-to-volume motion estimates (located in columns 2-7 of the file)
* cue_censor.1D 		# vector denoting which volumes to censor from glm estimation due to bad motion
* cue_enorm.1D 		# euclidean norm of volume-to-volume motion (combines x,y,z displacement and rotation)
* cue_[ROI]_ts.1D	# ROI time series 



### Quality Assurance (QA)
At this point, we should do some QA checks. The most common things that can go wrong are bad coregistration in group space and bad head motion. 

#### bad co-registration
In afni viewer, load subject's anatomy and functional volume in tlrc space (files "t1_tlrc_afni.nii.gz" and "vol1_cue_tlrc_afni.nii.gz"). These should be reasonably aligned. If they aren't, that means 1) the anatomical <-> functional alignment in native space messed up, 2) the subject's anatomical <-> tlrc template alignment messed up, or 3) both messed up. 

This can be done more efficiently for a lot of subjects by using the script `concatSubjVol.py`. Run that to concatanate all subjects' t1 and vol1 functional data in tlrc space, then flip through them in the afni viewer using the "index" option. 

Here's an example of decent coregistration: 
<p align="center">
  <img width="161" height="151" src="https://github.com/kellyhennigan/fmrieat/blob/master/coreg_examples/decent_coreg_y.jpg">
</p>

And here's an example of bad coregistration (where something went terribly wrong!)
<p align="center">
  <img width="161" height="151" src="https://github.com/kellyhennigan/fmrieat/blob/master/coreg_examples/bad_coreg_y.jpg">
</p>

To correct bad coregistration, follow instuctions outlined in `preprocess_anat_nudge.sh`, then run that instead of preprocess_anat.sh. If coregistration then looks fixed, run `preprocess_cue.sh` as usual. 

#### bad head motion
In matlab, run: 
```
doQA_subj_script.m
```
and then: 
```
doQA_group_script.m
```
to save out figures showing head motion. Figures saved out to **fmrieat/figures/QA/cue**. At this point, we've decided to exclude participants that have bad motion for 5% of more volumes of the fmri data, with bad motion being defined as .5mm or more. `doQA_group_script` will say if a subject is recommended to be excluded based on these parameters. 



### Get stimulus onset times and make regressors
In matlab, run: 
```
createRegs_script
```
this script loads behavioral data to get stimulus onset times and saves out regressors of interest. Saved out files each contain a single vector of length equal to the number of TRs in the task with mostly 0 entries, and than 1 to indicate when an event of interest occurs. These vectors are then convolved with an hrf using AFNI's waver command to model the hemodynamic response. 

Note that the output files from this script are used for estimating single-subject GLMs as well as for plotting VOI timecourses. 

#### output 
this should create directory **fmrieat/derivatives/subjid/regs** which should contain all the regressor and stimulus timing files. To check out regressor time series, from a terminal command line, cd to output "regs" directory, then type, e.g., `1dplot food_cue_cuec.1D`. 



### Subject-level GLMs
From terminal command line, run: 
```
python glm_cue.py
```
to specify GLM and fit that model to data using afni's 3dDeconvolve. There's excellent documentation on this command [here](https://afni.nimh.nih.gov/pub/dist/doc/manual/Deconvolvem.pdf). 

#### output 
saves out the following files to directory **fmrieat/derivatives/results_cue**:
* subjid_glm_B+tlrc 	# file containing only beta coefficients for each regressor in GLM
* subjid_glm+tlrc 		# file containing a bunch of GLM stats
To check out glm results, open these files in afni as an overlay (with, e.g., TT_N27.nii as underlay). You can also get info about these files using afni's 3dinfo command, e.g., from the terminal command line, `3dinfo -verb subjid_glm_B+tlrc`.



### Group-level whole brain analyses
From terminal command line, run: 
```
python ttest_cue.py
```
to use AFNI's command 3dttest++ to perform t-ttests on subjects' brain maps.

#### output 
Saves out resulting Z-maps to directory **fmrieat/derivatives/results_cue**. Check out results in afni viewer. 



### Generate VOI timecourses
In matlab, run: 
```
saveRoiTimeCourses_script
```
and then: 
```
plotRoiTimeCourses_script
```
to save out and plot VOI timecourses for events of interest.

#### output 
Saves out VOI timecourses to directory **fmrieat/derivatives/timecourses_cue** and saves out figures to **fmrieat/figures/timecourses_cue/**.



### Behavioral analyses
In matlab, run: 
```
analyzeBehavior_script & analyzeBehavior_singlesubject_script
```
to check out behavioral data. 



### TO DO: 
- qualtrics questionnaire analyses
- pipeline data collected on paper (weight, height, etc.)
- get follow-up data!



## dMRI pipeline

This pipeline is specifically designed for identifying the medial forebrain bundle. 

### Acpc-align t1 data
In matlab, run:
```
mrAnatAverageAcpcNifti
```
Use GUI to manually acpc-align t1 data 

#### output
Save out acpc-aligned nifti to **fmrieat/derivatives/anat_proc/t1_acpc.nii.gz**. 


### Run freesurfer recon
From terminal command line, cd to dir with subject's acpc-aligned t1 and run: 
```
recon-all -i t1_acpc.nii.gz -subjid subjid -all
```
This calls freesurfer's recon command to segment brain tissue

#### output
Saves out a bunch of files to directory, **/usr/local/freesurfer/subjects/subjid**.



### Convert freesurfer files to nifti and save out ROI masks
In matlab, run:
```
convertFsSegFiles_script.m
createRoiMasks_script.m
```
To convert freesurfer segmentation files to be in nifti format & save out desired ROI masks based on FS segmentation labels

#### output
Saves out files to directory, **fmrieat/derivatives/subjid/anat_proc**



### Convert midbrain ROI from standard > native space
From terminal command line, run:
```
t12mni_ANTS_script.py
```
and then in matlab, run:
```
xformROIs_script.m
```
To estimate the tranform (using ANTs) between subject's acpc-aligned native space and standard space and to apply the inverse transform to take a midbrain ROI in standard space > subject native space. 

We're currently trying out a midbrain ROI placed on the CIT168 atlas (Pauli et al., 2018) using these labels combined (all dopaminergic regions): VTA, SNc, and PBP. 

#### output
Saves out acpc-aligned<->standard space transforms to directory, **fmrieat/derivatives/subjid/anat_proc**, and saves out a midbrain ROI ("PauliAtlasDA.nii.gz") in directory: **fmrieat/derivatives/subjid/ROIs**



### dilate ROIs (if desired)
Following procedures in MacNiven et al (2020), at least for tracking between the midbrain and NAcc, dilate these ROIs by 2 voxels using an mrtrix command (e.g., "maskfilter -npass 2 naccL.nii.gz dilate naccL_dil2.nii.gz")

#### output
dilated ROI nifti files to directory, **fmrieat/derivatives/subjid/ROIs**



### Pre-process diffusion data
In Matlab, run:
```
dtiPreProcess_script
```
To do vistasoft standard pre-processing steps on diffusion data.

#### output
Saves out files to directory, **fmrieat/derivatives/subjid/dti96trilin**



### mrtrix pre-processing steps 
From terminal command line, run:
```
python mrtrix_proc.py
```
This script: 
* copies b_file and brainmask to mrtrix output dir
* make mrtrix tensor file and fa map (for comparison with mrvista maps and for QA)
* estimate response function using lmax of 8
* estimate fiber orientation distribution (FOD) (for tractography)

#### output
Saves out files to directory, **fmrieat/derivatives/subjid/dti96trilin/mrtrix**



### Track fibers
From terminal command line, run:
```
python mrtrix_fibertrack_mfb.py, 		 	 # for inferior NAcc tract
python mrtrix_fibertrack_mfb_aboveAC.py, or  # for superior NAcc tract
python mrtrix_fibertrack.py			 	     # for all other tracts
```
tracks fiber pathways between 2 ROIs with desired parameters. The "mfb" script includes an exclusionary ROI to not include any streamlines that go above the anterior commissure; the "...mfb_aboveAC" script has an exclusionary ROI to not include any streamlines that run below the anterior commissure.

##### output
Saves out files to directory, **fmrieat/derivatives/fibers/dti96trilin/mrtrix**



### Clean fiber bundles
In matlab:
```
cleanFibersMFB_script, 			# for inferior NAcc tract
cleanFibersAboveAC_script, or  	# for superior NAcc tract
cleanFibers_script 				# for all other tracts

```
uses AFQ software to iteratively remove errant fibers 

##### output
Saves out fiber group files to directory, **fmrieat/derivatives/subjid/fibers**



### Save out measurements from fiber bundles cores
In matlab:
```
dtiSaveFGMeasures_script & dtiSaveFGMeasures_csv_script
```
to save out summary tract measures 

##### output
Saves out .mat files with summary measures to directory, **fmrieat/derivatives/fgMeasures/mrtrix_fa/**



### Regression and correlation analyses to test relationships between tract coherence, personality, behavior, and/or fMRI measures












