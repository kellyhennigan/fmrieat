function [subjects,exc_subj_notes] = getFmrieatSubjects(task,group)
% -------------------------------------------------------------------------
% [subjects,exc_subj_notes] = getFmrieatSubjects(task)
% usage: returns cell array with subject id strings for this experiment.

% INPUT:
%   task (optional) - string that must be either 'cue', 'dti' or ''
%         (Default is '').

%
% OUTPUT:
%   subjects - cell array of subject id strings for this experiment
%   exc_subj_notes - cell array showing subjects excluded and notes as to why

% notes:
%

% author: Kelly, kelhennigan@gmail.com, 09-Nov-2014


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% return all subjects if task isn't given as input
if notDefined('task')
    task = '';
end


% return all subjects if task isn't given as input
if notDefined('group')
    group = '';
end


p=getFmrieatPaths;


% filename that contains a list of all subjects
subject_filename = fullfile(p.subjlist,'subjects');


% load subject IDs as a cell array
subjects=table2cell(readtable(subject_filename,'ReadVariableNames',0));


% if task is defined, remove subjects to be excluded based on
% omit_subs_[task] file and get notes as to why they are being excluded
if isempty(task)
    exc_subj_notes = [];
    
else
    omit_subs_filename = fullfile(p.subjlist, ['omit_subs_' task]);
    
    fileID = fopen(omit_subs_filename,'r');
    d = textscan(fileID, '%s%s%s\n', 'Delimiter', ',', 'HeaderLines' ,1, 'ReturnOnError', false);
    fclose(fileID);
    
    % get subj ids and notes for subjects to be excluded
    exc_subs = d{1};
    exc_subj_notes=[d{1} d{2}];
    
    for i=1:numel(exc_subs)
        subjects(strcmp(subjects,exc_subs{i}))=[];
    end
    
end


%%%%% GROUPS


% now get group index corresponding to subject array, if desired
if ~isempty(group)
    
    docid = '1QFMl95r8QAvuziri_sBPWPCfc9eqq95HmUOBuS8zl4Y';  % doc id for google sheet w/fmrieat subject group assignments
    subjci=1; % which column to look for subject ids in
    
    switch lower(group)
        
        case 'everdrinkers'
            colname = 'ever_drinker_1_qualtrics';
            gi = getGSSData(docid,colname,subjects,subjci);
            subjects=subjects(gi==1);
        case 'noneverdrinkers'
            colname = 'ever_drinker_1_qualtrics';
            gi = getGSSData(docid,colname,subjects,subjci);
            subjects=subjects(gi==0);            
            
            
        case 'past30daydrinkers_1'
            colname = 'past30ddrinker_1_tlfb';
            gi = getGSSData(docid,colname,subjects,subjci);
            subjects=subjects(gi==1);
        case 'nonpast30daydrinkers_1'
            colname = 'past30ddrinker_1_tlfb';
            gi = getGSSData(docid,colname,subjects,subjci);
            subjects=subjects(gi==0);
           
            
        case 'past30daybingers_1'
            colname = 'bingestat30d_1_tlfb';
            gi = getGSSData(docid,colname,subjects,subjci);
            subjects=subjects(gi==1);
        case 'nonpast30daybingers_1'
            colname = 'bingestat30d_1_tlfb';
            gi = getGSSData(docid,colname,subjects,subjci);
            subjects=subjects(gi==0);
            
            
        case 'past30daydrinkers_2'
            colname = 'past30ddrink_2';
            gi = getGSSData(docid,colname,subjects,subjci);
            subjects=subjects(gi==1);
        case 'nonpast30daydrinkers_2'
            colname = 'past30ddrink_2';
            gi = getGSSData(docid,colname,subjects,subjci);
            subjects=subjects(gi==0);
            
            
        case 'past30daybingers_2'
            colname = 'bingestat30d_2_tlfb';
            gi = getGSSData(docid,colname,subjects,subjci);
            subjects=subjects(gi==1);
        case 'nonpast30daybingers_2'
            colname = 'bingestat30d_2_tlfb';
            gi = getGSSData(docid,colname,subjects,subjci);
            subjects=subjects(gi==0);
            
            
        case 'deltadrinks_positive'
            colname = 'ndrinks_delta';
            gi = getGSSData(docid,colname,subjects,subjci);
            subjects=subjects(gi==1);
       case 'deltadrinks_negative'
            colname = 'ndrinks_delta';
            gi = getGSSData(docid,colname,subjects,subjci);
            subjects=subjects(gi==-1);
       case 'deltadrinks_zero'
            colname = 'ndrinks_delta';
            gi = getGSSData(docid,colname,subjects,subjci);
            subjects=subjects(gi==0);
            
    end
    
end % ~isempty(group)



end % function





