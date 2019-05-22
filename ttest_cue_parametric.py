#!/usr/bin/python

# script to extract some single-subject parameter estimates and perform a simple t-test.
# "infiles" are assumed to contain results from fitting a glm to individual subject data.  

# Infile names should be in the form of: *_in_str, where * is a 
# specific subject id that will be included in the out file. 

# sub_labels provides the labels of the volumes to be extracted from the infiles, and 
# corresponding t-stats in outfiles will be named according to out_sub_labels.

import os,sys,re,glob,numpy as np

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
	subjects = getsubs('cue')

	print(' '.join(subjects))

	input_subs = raw_input('subject id(s) (hit enter to process all subs): ')
	print('\nyou entered: '+input_subs+'\n')

	if input_subs:
		subjects=input_subs.split(' ')

	return subjects
	


####### main function
def main(): 

	
	pv = raw_input('enter parametric variable string (pa, na or pref): ')
	# pv = 'pa' #  parametric variable? pa, na, or pref 


	justPrint = 0 # 1 to just print, 0 to print and execute


	doClustSim = 0 # 1 to do clustsim, otherwise 0 (it takes a while)


	in_str = '_glm_B+tlrc'  # identify file string of coefficients file 


	# get project directory
	main_dir=getMainDir()
	data_dir = main_dir+'/derivatives'
	res_dir = data_dir+'/results_cue_'+pv

	# get subject ids
	subjects = whichSubs()

	out_str = ''  # add a string to output files? 

		# labels of sub-bricks to test
	sub_labels = ['trial#0',
	pv+'_trial#0',
	'cue_rt#0',
	'choice_rt#0'] 

	# labels for out files 
	out_labels =  ['Ztrial'+out_str,
	'Z'+pv+'_trial'+out_str,
	'Zcue_rt'+out_str,
	'Zchoice_rt'+out_str]

	
	# concatenate lists 
	in_str = np.tile(in_str,len(sub_labels))
	# sub_labels = sub_labels+sub_labels2
	# out_labels = out_labels+out_labels2
	print('\n\n\nIN STR:\n\n\n')
	print(in_str)
	print('\n\n\n\n\n\n')


	# define mask file if masking is desired; otherwise leave blank
	mask_file = os.path.join(data_dir,'templates','tt29_bmask.nii')  
	#mask_file = ''


	##########################################################################################
	##########################################################################################
	

	os.chdir(res_dir) 		 			# cd to results dir 
	print(res_dir)


	for i, sub_label in enumerate(sub_labels): 
		#print i, sub_label
		
		# get part of command for subjects in setA
		subjA_cmd = ' '
		if subjects:
			subjA_cmd = '-setA '
			for subj in subjects:
				cmd = "3dinfo -label2index '"+sub_label+"' "+subj+in_str[i]
				vol_idx=int(os.popen(cmd).read())
				subjA_cmd+="'"+subj+in_str[i]+'['+str(vol_idx)+']'+"' " 
				#print(subjA_cmd)


		# define mask command, if desired
		if mask_file:
			mask_cmd = ' -mask '+mask_file
		else:
			mask_cmd = ''


		# clustsim command, if desired
		if doClustSim:
			clustsim_cmd = ' -Clustsim '
		else:
			clustsim_cmd = ''

		cmd = '3dttest++ -prefix '+out_labels[i]+mask_cmd+' -toz '+clustsim_cmd+subjA_cmd
		print(cmd+'\n')
		if not justPrint:
			os.system(cmd)

		# 3dttest++ -prefix '+z_cue -toz -setA 'aa151010_glm+tlrc[2]' 'nd150921_glm+tlrc[2]' -setB 'ag151024_glm+tlrc[2]' 'si151120_glm+tlrc[2]' 

		

main()
	
	


