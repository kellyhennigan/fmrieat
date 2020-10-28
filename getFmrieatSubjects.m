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
            
        case {'female','females'}
            subjects={'aa190115';'ak190110';'am190125';'ap181126';'as190111';'bc190118';'er190106';'fc190124';'fh181203';'ga181112';'gm181112';
                'gr190124';'ih190111';'ja181214';'jk190114';'js190106';'kt190110';'mm190115';'nh190110';'pc181210';'pm181126';'rs181219';'sb190122';'sk190110';'sr190128';
                'ss190122';'tr181126';'ty190109';'ts190110'};
            
        case {'male','males'}
            subjects={'ag190107';'an190106';'ar181204';'bg190114_1';'bg190114_2';'em181211';'hb190109';'hs190128';'id181126';'ip190130';'js181128';
                'kl181210';'km190114';'ky190106';'lg190117';'ms190110';'mx190114';'oo190130';'rk181206';'sa181203';'sa190128';'se190106';'sg190121';
                'sl190114';'st181128';'va190114';'zl190124';'ks181114'};
            
        case {'weightlossd'}
            subjects={'ga181112';'ks181114';'tr181126';'id181126';'pm181126';'js181128';'st181128';'sa181203';'ar181204';'rk181206';'m181211';'ja181214';'js190106';'an190106';
                'se190106';'ky190106';'ag190107';'hb190109';'ms190110';'nh190110';'ak190110';'as190111';'va190114';'km190114';'sl190114';'bg190114_2';'aa190115';'lg190117';
                'sg190121';'ss190122';'am190125';'sa190128';'sr190128';'oo190130';'ip190130'};
            
        case {'nweightlossd'}
            subjects={'gm181112';'ap181126';'fh181203';'kl181210';'pc181210';'rs181219';'er190106';'ty190109';'kt190110';'ts190110';'k190110';'ih190111';'mx190114';'jk190114';
                'bg190114_1';'mm190115';'bc190118';'sb190122';'gr190124';'fc190124';'zl190124';'hs190128'};
            
        case {'hungriest'}
            subjects={'js190106';'lg190117';'ss190122';'fh181203';'pc181210';'jk190114';'km190114';'ga181112';'ks181114';'rk181206';'kl181210';'em181211';'rs181219';
                'ky190106';'er190106';'ak190110';'as190111';'bg190114_1';'sl190114';'gr190124';'sa190128';'sr190128'};
        
        case {'lesshungry'}
            subjects={'tr181126';'id181126';'ap181126';'an190106';'se190106';'hb190109';'ty190109';'kt190110';'ms190110';'nh190110';'ih190111';'bg190114_2';'mm190115';
                'sb190122';'zl190124';'am190125';'hs190128';'ip190130'};
            
    end
    
end % ~isempty(group)



end % function





