function subjects=whichFmrieatSubjects(task)
% -------------------------------------------------------------------------
% usage: % function to get user input to determine which subjects & task to
% process

% INPUT: 
%   task (optional) - string specifying task that determines subject subset
%   (i.e., 'cue' or 'dti')

% OUTPUT:
%   subjects - cell array of subjects to process
%   
% 
% author: Kelly, kelhennigan@gmail.com, 03-May-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 

if notDefined('task')
    task='';
end

getFmrieatPaths;

these_subjects = getFmrieatSubjects(task); % cell array of all subjects for a given task


% list out all subjects on command line 
fprintf('\n');
subj_list=cellfun(@(x) [x ' '], these_subjects, 'UniformOutput',0)';
disp([subj_list{:}]);

fprintf('\nwhich subjects to process? \n');
subjects = input('enter sub ids, or hit return for all subs above: ','s');

if isempty(subjects)
    subjects = these_subjects;
else
    subjects = splitstring(subjects)';
end





