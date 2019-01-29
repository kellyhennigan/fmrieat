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
        gi(strcmp(subjects,exc_subs{i}))=[];
        notes(strcmp(subjects,exc_subs{i}))=[];
        subjects(strcmp(subjects,exc_subs{i}))=[];
    end
    
end


% now get only subjects from one specific group, if desired
if ~isempty(group)
    
    % return controls
    if strcmpi(group,'controls') || isequal(group,0)
        subjects = subjects(gi==0);
        notes = notes(gi==0);
        gi = gi(gi==0);
        
        % return patients
    elseif strcmpi(group,'patients') || isequal(group,1)
        subjects = subjects(gi>0);
        notes = notes(gi>0);
        gi = gi(gi>0);
        
    % return patients with complete followup data (or confirmed relapse before then) 
    elseif strcmpi(group,'patients_complete') 
        ri=getCueData(subjects,'relapse');
        obs=getCueData(subjects,'observedtime');
        idx=find(ri==1 | obs>150); % either relapsed or followed up for >5 months
        subjects = subjects(idx); 
        notes = notes(idx);
        gi = gi(idx);
   
        % return patients with at least 3 months followup data (or confirmed relapse before then)
    elseif strcmpi(group,'patients_3months') 
        ri=getCueData(subjects,'relapse');
        obs=getCueData(subjects,'observedtime');
        idx=find(ri==1 | obs>=90); % either relapsed or followed up for >=3 months
        subjects = subjects(idx);
        notes = notes(idx);
        gi = gi(idx);
        
        % return relapsers
    elseif strcmpi(group,'relapsers')
        ri=getCueData(subjects,'relapse');
        subjects = subjects(ri==1);
        notes = notes(ri==1);
        gi = gi(ri==1);
        
        
        % return nonrelapsers
    elseif strcmpi(group,'nonrelapsers')
        ri=getCueData(subjects,'relapse');
        subjects = subjects(ri==0);
        notes = notes(ri==0);
        gi = gi(ri==0);
        
        % return those who relapsed within 3 mos
    elseif any(strcmpi(group,{'relapsers_3months','relapse_3months'}))
        ri=getCueData(subjects,'relapse_3months');
        subjects = subjects(ri==1);
        notes = notes(ri==1);
        gi = gi(ri==1);
        
        
        % return those who did not relapse within 3 mos
    elseif any(strcmpi(group,{'nonrelapsers_3months','nonrelapse_3months'}))
        ri=getCueData(subjects,'relapse_3months');
        subjects = subjects(ri==0);
        notes = notes(ri==0);
        gi = gi(ri==0);
        
             % return those who relapsed within 4 mos
    elseif any(strcmpi(group,{'relapsers_4months','relapse_4months'}))
        ri=getCueData(subjects,'relapse_4months');
        subjects = subjects(ri==1);
        notes = notes(ri==1);
        gi = gi(ri==1);
        
        
        % return those who did not relapse within 4 mos
    elseif any(strcmpi(group,{'nonrelapsers_4months','nonrelapse_4months'}))
        ri=getCueData(subjects,'relapse_4months');
        subjects = subjects(ri==0);
        notes = notes(ri==0);
        gi = gi(ri==0);
       
        % return those who relapsed within 6 mos
    elseif any(strcmpi(group,{'relapsers_6months','relapse_6months'}))
        ri=getCueData(subjects,'relapse_6months');
        subjects = subjects(ri==1);
        notes = notes(ri==1);
        gi = gi(ri==1);
        
        
        % return those who did not relapse within 6 mos
    elseif any(strcmpi(group,{'nonrelapsers_6months','nonrelapse_6months'}))
        ri=getCueData(subjects,'relapse_6months');
        subjects = subjects(ri==0);
        notes = notes(ri==0);
        gi = gi(ri==0);
 
     % return those who relapsed within 8 mos
    elseif any(strcmpi(group,{'relapsers_8months','relapse_8months'}))
        ri=getCueData(subjects,'relapse_8months');
        subjects = subjects(ri==1);
        notes = notes(ri==1);
        gi = gi(ri==1);
        
        
        % return those who did not relapse within 8 mos
    elseif any(strcmpi(group,{'nonrelapsers_8months','nonrelapse_8months'}))
        ri=getCueData(subjects,'relapse_8months');
        subjects = subjects(ri==0);
        notes = notes(ri==0);
        gi = gi(ri==0);
        
%         % return the first 15 to have relapsed
%     elseif any(strcmpi(group,{'early_relapse','early_relapsers'}))
%         ri=getCueData(subjects,'early_relapsers');
%         subjects = subjects(ri==1);
%         notes = notes(ri==1);
%         gi = gi(ri==1);
%         
%     elseif any(strcmpi(group,{'early_abstainers'}))
%         ri=getCueData(subjects,'early_relapsers');
%         subjects = subjects(ri==0);
%         notes = notes(ri==0);
%         gi = gi(ri==0);
%         
    end
    
end % if ~isempty(group)

end % function





