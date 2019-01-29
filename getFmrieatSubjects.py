#!/usr/bin/python

# script to return subject ids for subjects in cue fmri experiment. To use in a python script, do: 

		# from getFmrieatSubjects import getsubs
		# subjects = getsubs()

# returns subjects as a list of subject id strings. Optional input of task string will return only subjects for that task (cue, dti, etc.), e.g.:

		# from getFmrieatSubjects import getsubs
		# subjects = getsubs('cue')

import os,sys


def getsubs(task=''):

	# get path for main project directory 
	os.chdir('../')
	main_dir=os.getcwd()
	os.chdir('scripts')

	# define path to subject file
	subjFile = main_dir+'/subjects_list/subjects'
	

	# define subjects and gi lists
	subjects = [] # list of subject ids
	
	# get all subject IDs
	f= open(subjFile, 'r')
	subjects=f.read().splitlines()

	
	# if a task string is given, return subset of subjects for that task
	if task: 

		omit_subs = [] # list of subjects to omit specific to this task
		
		omitSubjsFile = main_dir+'/subjects_list/omit_subs_'+task
	
		with open(omitSubjsFile, 'r') as f:
			next(f) # omit header line
			for line in f:	
				omit_subs.append(line[0:line.find(',')])
			
		for omit_sub in omit_subs:
			if omit_sub in subjects:
				subjects.remove(omit_sub)
	

	# return subjects 
	return subjects




#if __name__ == "__main__":
#	subjects,gi = getsubs(sys.argv[1])
#	print subjects
#	print gi


#	if __name__ == "__main__":
 #   	getsubs()
 # getsubs(int(sys.argv[1]))

