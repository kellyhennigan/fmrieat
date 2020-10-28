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
def whichSubs(base_dir='fmrieat'):

	
	if base_dir=='fmrieat':
		from getFmrieatSubjects import getsubs 
		subjects = getsubs('dti')
	elif base_dir=='cueexp_claudia':
		from getCueSubjects import getsubs_claudia
		subjects,gi = getsubs_claudia()

	print(' '.join(subjects))

	input_subs = raw_input('subject id(s) (hit enter to process all subs): ')
	print('\nyou entered: '+input_subs+'\n')

	if input_subs:
		subjects=input_subs.split(' ')

	return subjects
	

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
			

#########  get main data directory and subjects to process	
def getMainDir():

	# get full path for main project directory & return to current dir
	os.chdir('../')
	main_dir=os.getcwd()
	os.chdir('scripts')

	return main_dir

		
def main(): 
	
	printDirections()						# print directions
	
	
	# main directory
	main_dir=getMainDir()

	
	# data directory
	data_dir=main_dir+'/derivatives'

	
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
