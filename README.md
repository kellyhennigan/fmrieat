# code for processing data for the fmrieat project

## software requirements 

These scripts require the following software: 

* [AFNI](https://afni.nimh.nih.gov/)
* [Python 2.7](https://www.python.org/)
* [Matlab](https://www.mathworks.com/products/matlab.html)
* [matlab package, VISTASOFT](https://github.com/vistalab/vistasoft)
* [mrtrix 3.0](http://www.mrtrix.org/)
* spm (VISTASOFT dependency)
* freesurfer

## before you start

make sure the user has permission to execute bash scripts. From a terminal command line, cd to the directory containing these scripts. Then type:
```
chmod 777 *sh
```
to be able to execute them. This only needs to be run once. 


## get raw data from flywheel: 

from a terminal command line, type:
```
./setup_raw_data.sh
```
this will copy over the data into a BIDs-compatible directory structure


## get raw behavioral data

<i>in matlab, run:</i> 
```
setup_behavioral_data.m
```
to copy over raw behavioral data files to your local computer and then manually transfer them to vta server. Alternatively, just copy over the behavioral files to vta into the "source" sub-directory. 


## to start pre-processing, Start with the following raw data files:

- cue_matrix.csv -behavioral data from the task
- t1_raw.nii.gz –subjects t1-weighted anatomical scan
- cue1.nii.gz –functional task data
- quantitative t1 nifti 



## pre-processing pipeline

(1) coregister subject's functional and anatomical data in native space and estimate the transform to bring subject's data into standard group space

<i>from a terminal command line, type:</i> 
```
./preprocess_anat.sh
```
this script does the following using AFNI commands:
* skull strips t1 data using afni command "3dSkullStrip"
* aligns skull-stripped t1 data to t1 template in tlrc space using afni command @auto_tlrc, which allows for a 12 parameter affine transform
* pulls out the first volume of functional data to be co-registered to anatomy and skullstrips this volume using "3dSkullStrip"
* coregisters anatomy to functional data, and then calculates the transform from native functional space to standard group space (tlrc space)

QUALITY CHECK:
in afni viewer, load subject's anatomy and functional volume in tlrc space (files "t1_tlrc_afni.nii.gz" and "vol1_cue_tlrc_afni.nii.gz"). These should be reasonably aligned. If they aren't, that means 1) the anatomical <-> functional alignment in native space messed up, 2) the subject's anatomical <-> tlrc template alignment messed up, or 3) both messed up. 



(2) run pre-processing steps on functional data 

<i>from a terminal command line, type:</i> 
```
./preprocess_cue.sh
```
this script does the following using AFNI commands:
* removes first 6 volumes from functional scan (to allow t1 to reach steady state)
* slice time correction
* motion correction 
* saves out a vector of which volumes have lots of motion (will use this to censor volumes in glm estimation step)
* spatially smooths data 
* converts data to be in units of percent change (mean=100; so a value of 101 means 1% signal change above that voxel's mean signal)
* highpass filters the data to remove low frequency fluctuations
* transforms pre-processed functional data into standard group (tlrc) space using transforms estimated in "preprocess_anat.sh" script
* saves out white matter, csf, and nacc VOI time series as single vector text files (e.g., 'cue_csf_ts.1D') 



(3) get stimulus onset times and make regressor time series 

<i>from matlab command line, type:</i> 
```
createRegs_script
```
this script loads behavioral data to get stimulus onset times and saves out regressors of interest. Saved out files each contain a single vector of length equal to the number of TRs in the task with mostly 0 entries, and than 1 to indicate when an event of interest occurs. These vectors are then convolved with an hrf using AFNI's waver command to model the hemodynamic response. 

Check out the output files: 
<i>from a terminal command line, cd to output "regs" directory, then type, e.g.,:</i> 
```
1dplot food_cue_cuec.1D
```

** Note that the output files from this script are used for estimating single-subject GLMs and for plotting VOI timecourses. 

# Processing pipeline for fmrieat project 

This repository has code for processing functional mri (fmri) and diffusion mri (dmri) data collected for the fmrieat experiment. The pipelines are distinct and can be run in parallel. 


## Getting started


### software requirements 

* [Python 2.7](https://www.python.org/)
* [Matlab](https://www.mathworks.com/products/matlab.html)
* [AFNI](https://afni.nimh.nih.gov/) (fmri pipeline only)
* [matlab package, VISTASOFT](https://github.com/vistalab/vistasoft) (dmri pipeline only)
* [spm as a VISTASOFT dependency](https://www.fil.ion.ucl.ac.uk/spm/) (dmri pipeline only)
* [mrtrix 3.0](http://www.mrtrix.org/) (dmri pipeline only)
* [freesurfer](https://surfer.nmr.mgh.harvard.edu/) (dmri pipeline only)


### permissions

make sure the user has permission to execute scripts. From a terminal command line, cd to the directory containing these scripts. Then type:
```
chmod 777 *sh
chmod 777 *py
```
to be able to execute them. This only needs to be run once. 


## get raw mri data 

from a terminal command line, type:
```
./setup_raw_data.sh
```
this will copy over the raw MRI data from Flywheel into a BIDs-compatible directory structure

#### OUTPUT

this should create the directory:

* fmrieat/rawdata_bids/subjid		# subject raw MRI data folder 

where subjid is the subject's id. This directory should contain:

* func/cue1.nii.gz 		# fMRI data 
* anat/t1w.nii.gz 		# t1-weighted (anatomical) data 
* dwi/dwi.nii.gz		# diffusion MRI data
* dwi/bval				# b-values 
* dwi/bvec				# b-vectors 
* <i>(quantitative t1 scans are saved as well; pipeline for that to be added later)</i> 

At this point, the fMRI and dMRI processing streams are separate and can be run in parallel. See links below to go to each pipeline:

[fMRI pipeline](#fmri-pipeline)

[dMRI pipeline](#dmri-pipeline)


## fMRI pipeline


### get behavioral data 

In matlab, run:
```
setup_behavioral_data.m 
```
to save behavioral data (stim timing and ratings files) locally, then scp them to save them on vta server. (Or just manually scp them from Google drive folder to vta server)

#### OUTPUT 

this should create the following directory: 

* fmrieat/source/subjid/behavior		# subject directory for behavioral data

which should contain: 

* cue_matrix.csv	# stim timing file
* cue_ratings.csv 	# valence and arousal ratings


### estimate transforms to align subject's fmri and anatomy to standard space 

from a terminal command line, run: 
```
./preprocess_anat.sh
```
this script does the following using AFNI commands:
* skull strips t1 data using afni command "3dSkullStrip"
* aligns skull-stripped t1 data to t1 template in tlrc space using afni command @auto_tlrc, which allows for a 12 parameter affine transform
* pulls out the first volume of functional data to be co-registered to anatomy and skullstrips this volume using "3dSkullStrip"
* coregisters anatomy to functional data, and then calculates the transform from native functional space to standard group space (tlrc space)

#### OUTPUT 

this should create the following directory: 

* fmrieat/derivatives/subjid/func_proc				# directory for subject's processed fmri data

which should contain: 

* t1_ns.nii.gz 			# subject's t1 with no skull in native space
* t1_tlrc_afni.nii.gz	# " " in standard (tlrc) space
* vol1_cue_ns.nii.gz 	# 1st vol of fmri data with no skull in native space
* vol1_cue_tlrc_afni.nii.gz	# " " in standard space
* xfs # sub-directory containing all transforms 


### pre-process fmri data

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

#### OUTPUT 

files saved out to fmrieat/derivatives/subjid/func_proc are: 

* pp_cue.nii.gz		# pre-processed fmri data in native space
* pp_cue_tlrc_afni.nii.gz		# " " in standard space
* cue_vr.1D			# volume-to-volume motion estimates (located in columns 2-7 of the file)
* cue_censor.1D 		# vector denoting which volumes to censor from glm estimation due to bad motion
* cue_enorm.1D 		# euclidean norm of volume-to-volume motion (combines x,y,z displacement and rotation)
* cue_[ROI]_ts.1D	# ROI time series 


### Quality Assurance (QA)

at this point, we should do some QA checks. The most common things that can go wrong are bad coregistration in group space and bad head motion. 

#### bad co-registration

In afni viewer, load subject's anatomy and functional volume in tlrc space (files "t1_tlrc_afni.nii.gz" and "vol1_cue_tlrc_afni.nii.gz"). These should be reasonably aligned. If they aren't, that means 1) the anatomical <-> functional alignment in native space messed up, 2) the subject's anatomical <-> tlrc template alignment messed up, or 3) both messed up. 

This can be done more efficiently for a lot of subjects by using the script `concatSubjVol.py`. Run that to concatanate all subjects' t1 and vol1 functional data in tlrc space, then flip through them in the afni viewer using the "index" option. 

Here's an example of decent coregistration: 
![decent coreg](https://github.com/kellyhennigan/fmrieat/blob/master/coreg_examples/decent_coreg_y.jpg)

Here's an example of bad coregistration (where something went terribly wrong!)
![bad coreg](https://github.com/kellyhennigan/fmrieat/blob/master/coreg_examples/bad_coreg_y.jpg)

To correct bad coregistration, follow instuctions outlined in `preprocess_anat_nudge.sh`, then run that instead of preprocess_anat.sh. If coregistration then looks fixed, run `preprocess_cue.sh` as usual. 

#### bad head motion

In matlab, run: 
```
doQA_subj_script.m
and 
doQA_group_script.m
```
to save out figures showing head motion. Figures saved out to <i>fmrieat/figures/QA/cue<\i>. At this point, we've decided to exclude participants that have bad motion for 5% of more volumes of the fmri data, with bad motion being defined as .5mm or more. `doQA_group_script` will say if a subject is recommended to be excluded based on these parameters. 


### Get stimulus onset times and make regressors

In matlab, run: 
```
createRegs_script
```
this script loads behavioral data to get stimulus onset times and saves out regressors of interest. Saved out files each contain a single vector of length equal to the number of TRs in the task with mostly 0 entries, and than 1 to indicate when an event of interest occurs. These vectors are then convolved with an hrf using AFNI's waver command to model the hemodynamic response. 

#### OUTPUT 

reg files saved out to: 

* fmrieat/derivatives/subjid/regs		# subject directory for behavioral data

To check out regressor time series, from a terminal command line, cd to output "regs" directory, then type, e.g.:
```
1dplot food_cue_cuec.1D
```

** Note that the OUTPUT files from this script are used for estimating single-subject GLMs and for plotting VOI timecourses. 


### fit single-subject GLMs

From terminal command line, run: 

```
python glm_cue.py

```
to specify GLM and fit that model to data using afni's 3dDeconvolve. There's excellent documentation on this command [here](https://afni.nimh.nih.gov/pub/dist/doc/manual/Deconvolvem.pdf). 

#### OUTPUT 

saves out files to this directory:

* fmrieat/derivatives/results_cue		

files saved out are: 

* subjid_glm_B+tlrc 	# file containing only beta coefficients for each regressor in GLM
* subjid_glm+tlrc 		# file containing a bunch of GLM stats

To check out glm results, open these files in afni as an overlay (with, e.g., TT_N27.nii as underlay). You can also get info about these files using afni's 3dinfo command, e.g., from the terminal command line, `3dinfo -verb subjid_glm_B+tlrc`.


### estimate group maps 
From terminal command line, run: 
```
python ttest_cue.py
```
to use AFNI's command 3dttest++ to perform t-ttests on subjects' brain maps


### To generate VOI timecourses: 
<i>from matlab command line, type:</i> 
```
saveRoiTimeCourses_script
```
and then: 
```
plotRoiTimeCourses_script
```
to save & plot ROI timecourses for events of interest


### check out behavior
<i>in matlab, run:</i> 
```
analyzeBehavior_script
& 
analyzeBehavior_singlesubject_script
```
to check out behavioral data



## dMRI pipeline


