 #!/usr/bin/python

import os,sys

	
##################### fit glm using 3dDeconvolve #####################################################################
# EDIT AS NEEDED:

# this script is like glm_cue.py except that condition (alcohol, drugs, etc.) is modeled as a boxcar of the 
# whole trial (TRs 1-4), rather than just at the image onset period (TR 2). 


#########  get main data directory and subjects to process	
def getMainDir():

	# get full path for main project directory & return to current dir
	os.chdir('../')
	main_dir=os.getcwd()
	os.chdir('scripts')

	return main_dir


#########  get main data directory and subjects to process	
def whichSubs():

	from getFmrieatSubjects import getsubs
	subjects = getsubs()

	print(' '.join(subjects))

	input_subs = raw_input('subject id(s) (hit enter to process all subs): ')
	print('\nyou entered: '+input_subs+'\n')

	if input_subs:
		subjects=input_subs.split(' ')

	return subjects
	

def main(): 

	# get project directory
	main_dir=getMainDir()
	data_dir = main_dir+'/derivatives'

	afniStr = '_afni' # set this to '' if not using afni coreg version

	# get subject ids
	subjects = whichSubs()

	# pre-processed functional data to analyze
	func_dir = 'func_proc'  	# relative to subject-specific directory
	func_files = 'pp_cue_tlrc'+afniStr+'.nii.gz'

	out_dir = os.path.join(data_dir,'results_cue')  	# directory for out files 
	out_str = 'glm'					# string for output files


	##########################################################################################

	# make out directory if its not already defined
	if not os.path.exists(out_dir):
		os.makedirs(out_dir)

	# subjects = raw_input('subject id (s) to process: ')
	# print '\nyou entered: '+subjects+'\n'

	# subjects=subjects.split(' ')


	for subject in subjects:

		print '\n********** GLM FITTING FOR SUBJECT '+subject+' **********\n'

		this_out_str = subject+'_'+out_str

		# define subject-specific directories
		subj_dir = os.path.join(data_dir,subject) # subject dir
		os.chdir(subj_dir) 				 # cd to subj directory
		cdir = os.getcwd()
		print '\nCurrent working directory: '+cdir+'\n\n'
		# NOTE: all input file paths in the 3dDeconvolve command are relative to the subject's directory
		

		#-#-#-#-#-#-#-#-#-#-#-		Run 3dDeconvolve:		-#-#-#-#-#-#-#-#-#-#-#

		cmd = ('3dDeconvolve '		
			'-jobs 2 '
			'-input '+func_dir+'/'+func_files+' '
			'-censor '+func_dir+'/'+'cue_censor.1D '
			'-num_stimts 16 '
			'-polort 2 '
			'-dmbase '						# de-mean baseline regressors
			'-xjpeg '+os.path.join(out_dir,'Xmat')+' '
			'-stim_file 1 "'+func_dir+'/cue_vr.1D[1]" -stim_base 1 -stim_label 1 roll '
			'-stim_file 2 "'+func_dir+'/cue_vr.1D[2]" -stim_base 2 -stim_label 2 pitch '
			'-stim_file 3 "'+func_dir+'/cue_vr.1D[3]" -stim_base 3 -stim_label 3 yaw '
			'-stim_file 4 "'+func_dir+'/cue_vr.1D[4]" -stim_base 4 -stim_label 4 dS ' 
			'-stim_file 5 "'+func_dir+'/cue_vr.1D[5]" -stim_base 5 -stim_label 5 dL ' 
			'-stim_file 6 "'+func_dir+'/cue_vr.1D[6]" -stim_base 6 -stim_label 6 dP ' 
			'-stim_file 7 '+func_dir+'/cue_csf_ts.1D -stim_base 7 -stim_label 7 csf ' 
			'-stim_file 8 '+func_dir+'/cue_wm_ts.1D -stim_base 8 -stim_label 8 wm ' 
			'-stim_file 9 regs/cue_cuec.1D -stim_label 9 cue '
			'-stim_file 10 regs/img_cuec.1D -stim_label 10 img '
			'-stim_file 11 regs/choice_cuec.1D -stim_label 11 choice ' 
			'-stim_file 12 regs/choicert_cuec.1D -stim_label 12 choice_rt ' 
			'-stim_file 13 regs/alcohol_trial_cuec.1D -stim_label 13 alcohol ' 
			'-stim_file 14 regs/drugs_trial_cuec.1D -stim_label 14 drugs ' 
			'-stim_file 15 regs/food_trial_cuec.1D -stim_label 15 food ' 
			'-stim_file 16 regs/neutral_trial_cuec.1D -stim_label 16 neutral ' 
			'-num_glt 4 '					 # of contrasts
			'-glt_label 1 alcohol-neutral -gltsym "SYM: +alcohol -neutral" ' 
			'-glt_label 2 drugs-neutral -gltsym "SYM: +drugs -neutral" '
			'-glt_label 3 food-neutral -gltsym "SYM: +food -neutral" '
			'-glt_label 4 drugs-food -gltsym "SYM: +drugs -food" '
			'-tout ' 					# output the partial and full model F
	 		'-rout ' 					# output the partial and full model R2
	 		'-xout '						# print design matrix to the screen
	 		#'-errts errts '						# get error time series file
	 		'-bucket '+os.path.join(out_dir,this_out_str)+' ' 			# save out all info to filename w/prefix
	 		'-cbucket '+os.path.join(out_dir,this_out_str+'_B')+' ' 		# save out only regressor coefficients to filename w/prefix
			)
		
	# #############
	# # RUN IT
	# 
		print cmd+'\n'
		os.system(cmd)

		# z-score results
		# this_out_str_z = 'z_'+this_out_str
		# cmd = '3dmerge -doall -1zscore -prefix '+os.path.join(out_dir,this_out_str_z)+' '+os.path.join(out_dir,this_out_str+'+tlrc')
		# print cmd+'\n'
		# os.system(cmd)

		print '********** DONE WITH SUBJECT '+subject+' **********'

	print 'finished subject loop'


main()




