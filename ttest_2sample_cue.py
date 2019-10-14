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

	justPrint = 0 # 1 to just print, 0 to print and execute


	doClustSim = 0 # 1 to do clustsim, otherwise 0 (it takes a while)


	in_str = '_glm_B+tlrc'  # identify file string of coefficients file 

	
#	out_str = '_past30daydrinkersVnot'  # add a string to output files? 
	out_str = '_past30daybingeVnot'  # add a string to output files? 

	# get project directory
	main_dir=getMainDir()
	data_dir = main_dir+'/derivatives'
	res_dir = data_dir+'/results_cue'

	# get subject ids
	# subjects = whichSubs()
	
	# ever drinkers (based on TLFB at timepoint 1)
	# subjsA = ['ag190107','am190125','an190106','bc190118','em181211','fc190124','fh181203','ga181112','gm181112','gr190124','hs190128','id181126','ip190130','jk190114','km190114','ks181114','kt190110','lg190117','mm190115','ms190110','mx190114','oo190130','pc181210','pm181126','rk181206','rs181219','sa190128','sb190122','se190106','sg190121','sk190110','sr190128','ss190122','st181128','tr181126','ts190110','zl190124']
	# subjsB = ['aa190115','ak190110','ap181126','ar181204','as190111','bg190114_1','bg190114_2','er190106','hb190109','ih190111','ja181214','js181128','js190106','kl181210','ky190106','nh190110','sa181203','sl190114','ty190109','va190114']

	# binge drinkers (based on TLFB at timepoint 1)
	subjsA = ['am190125','em181211','fc190124','fh181203','gm181112','hs190128','ip190130','km190114','ks181114','lg190117','mx190114','oo190130','pm181126','rs181219','sb190122','se190106','sg190121','sk190110','st181128','ty190109']
	subjsB = ['aa190115','ag190107','ak190110','an190106','ap181126','ar181204','as190111','bc190118','bg190114_1','bg190114_2','er190106','ga181112','gr190124','hb190109','id181126','ih190111','ja181214','jk190114','js181128','js190106','kl181210','kt190110','ky190106','mm190115','ms190110','nh190110','pc181210','rk181206','sa181203','sa190128','sl190114','sr190128','ss190122','tr181126','ts190110','va190114','zl190124']
	
	# labels of sub-bricks to test
	sub_labels = ['cue#0',
	'img#0',
	'choice#0',
	'choice_rt#0',
	'alcohol#0',
	'drugs#0',
	'food#0',
	'neutral#0'] 

	# labels for out files 
	out_labels =  ['Zcue'+out_str,
	'Zimg'+out_str,
	'Zchoice'+out_str,
	'Zchoice_rt'+out_str,
	'Zalcohol'+out_str,
	'Zdrugs'+out_str,
	'Zfood'+out_str,
	'Zneutral'+out_str]

	# glt contrasts, arent in coeff bucket so get them from glm bucket: 
	in_str2 = '_glm+tlrc'

	sub_labels2 = ['Full_R^2',
	'Full_Fstat',
	'alcohol-neutral_GLT#0_Coef',
	'drugs-neutral_GLT#0_Coef',
	'food-neutral_GLT#0_Coef',
	'drugs-food_GLT#0_Coef']


	# labels for out files 
	out_labels2 =  ['ZFull_R^2'+out_str,
	'ZFull_Fstat'+out_str,
	'Zalc-neutral'+out_str,
	'Zdrug-neutral'+out_str,
	'Zfood-neutral'+out_str,
	'Zdrug-food'+out_str]

	# concatenate lists 
	in_str = np.append(np.tile(in_str,len(sub_labels)),np.tile(in_str2,len(sub_labels2)))
	sub_labels = sub_labels+sub_labels2
	out_labels = out_labels+out_labels2
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
		if subjsA:
			subjA_cmd = '-setA '
			for subj in subjsA:
				cmd = "3dinfo -label2index '"+sub_label+"' "+subj+in_str[i]
				vol_idx=int(os.popen(cmd).read())
				subjA_cmd+="'"+subj+in_str[i]+'['+str(vol_idx)+']'+"' " 
				#print(subjA_cmd)


		# get part of command for subjects in setB
		subjB_cmd = ''
		if subjsB:
			subjB_cmd = '-setB '
			for subj in subjsB:
				cmd = "3dinfo -label2index '"+sub_label+"' "+subj+in_str[i]
				vol_idx=int(os.popen(cmd).read())
				subjB_cmd+="'"+subj+in_str[i]+'['+str(vol_idx)+']'+"' " 


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

		cmd = '3dttest++ -prefix '+out_labels[i]+mask_cmd+' -toz '+clustsim_cmd+subjA_cmd+subjB_cmd
		print(cmd+'\n')
		if not justPrint:
			os.system(cmd)

		# 3dttest++ -prefix '+z_cue -toz -setA 'aa151010_glm+tlrc[2]' 'nd150921_glm+tlrc[2]' -setB 'ag151024_glm+tlrc[2]' 'si151120_glm+tlrc[2]' 

		

main()
	
	


