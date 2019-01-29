#!/usr/bin/python

# filename: subj_loop.py
# script to loop over subjects to perform some command



import os,sys



##########################################################################################
##########################################################################################

	
def printDirections():	
	print('Enter desired commands to perform *relative to each subjects directory*.')
	print('Dont worry about cd-ing into the right directory when done.')
	print('type "end" after the last desired command.')



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
	

#########  get task 
def whichDir():
	
	potential_dirs = ['rawdata_bids','derivatives','source']

	print('loop over subjects in which sub-directory?\n')
	print('\t1) '+potential_dirs[0])
	print('\t2) '+potential_dirs[1])
	print('\t3) '+potential_dirs[2]+'\n')
	dir_idx = raw_input('enter 1,2, or 3: ') # task index

	print('\n\ndir_idx: '+dir_idx+'\n\n')

	this_dir = [potential_dirs[int(dir_idx)-1]]

	print('\n\nthis_dir: '+this_dir[0]+'\n\n')
	return this_dir[0]


def getSubCommands():
	cmd_list = []	
	cmd = ''
	while cmd != 'end':
		cmd = raw_input('enter command to perform on each subject: ')
		print('the input command was '+cmd)
		cmd_list.append(cmd)
		if cmd.lower()[0:3]=='cd ':
			os.chdir(cmd[3:])
			print('Current working directory: '+os.getcwd())
		else:
			os.system(cmd)
	return cmd_list
		
		
def performSubCommands(data_dir,subjects,cmd_list):
	for subject in subjects: 		# now loop through subjects
		print('WORKING ON SUBJECT '+subject)
		os.chdir(data_dir+'/'+subject) # cd to subjects dir
		for cmd in cmd_list[0:len(cmd_list)-1]:
			if cmd.lower()[0:3]=='cd ':
				os.chdir(cmd[3:])
			else:
				os.system(cmd)
			
		
def main(): 
	
	printDirections()						# print directions
	
	
	# main directory
	main_dir=getMainDir()

	print('Current working directory: '+os.getcwd())

	# which directory?
	this_dir=whichDir()
	data_dir=main_dir+'/'+this_dir


	# get subject ids
	subjects = whichSubs()

	os.chdir(data_dir+'/'+subjects[0]) 		# cd to first subject's dir
	print('Current working directory: '+os.getcwd())
	
	cmd_list = getSubCommands() 			# have user input commands to perform
	
	print(cmd_list)
	
	del subjects[0] 			# remove first sub from list bc commands already executed
	
	performSubCommands(data_dir,subjects,cmd_list)  # now perform commands on all subs 
	
	print('done')


main()