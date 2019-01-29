function [subjects,exc_subj_notes] = getFmrieatSubjects(task)
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


end % function





