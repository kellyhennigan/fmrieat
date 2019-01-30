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

<i>from a terminal command line, type:</i> 
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


## To generate VOI timecourses: 
<i>from matlab command line, type:</i> 
```
saveRoiTimeCourses_script
```
and then: 
```
plotRoiTimeCourses_script
```
to save & plot ROI timecourses for events of interest


## Make single-subject and group brain maps: 
<i>from a terminal command line, type:</i>
```
python glm_cue.py
```
this script calls AFNI's 3dDeconvolve command to fit a GLM to a subject's fMRI data. 


<i>from a terminal command line, type:</i>
```
python ttest_2sample_cue.py
```
to use AFNI's command 3dttest++ to perform t-ttests on subjects' brain maps


## QA
<i>from matlab command line, type:</i> 
```
doFuncQA_script
```
to save out some plots that display head motion


## check out behavior
<i>in matlab, run:</i> 
```
analyzeBehavior_script
& 
analyzeBehavior_singlesubject_script
```
to check out behavioral data

