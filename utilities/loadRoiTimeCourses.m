function tc=loadRoiTimeCourses(filepath,subjects,TRs)
% usage: import time course data for cuefmri experiment
%
% INPUT:
%   filepath - string specifying path to csv file
%   subjects - cell array of subject id strings specifying which subjects
%              to return data for; If not
%              defined, all subjects will be returned.
%   TRs (optional) - integer specifying which TRs to return (e.g., [1:4]
%   will return TRs 1,2,3, and 4. Default is all TRs from each row (12).

% OUTPUT:
%   tc - roi time course data


% note that if there isn't time course data for a specified subject, a row
% of NaNs will be returned.

% author: Kelly, kelhennigan@gmail.com, 30-Nov-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 

if notDefined('filepath') || ~exist(filepath,'file')
    error('either filepath isnt defined or it doesnt exist as a file...');
end

% load time courses
T=readtable(filepath);

% all subjects listed in timecourse data file
tc_subs = table2array(T(:,1)); 

% all timecourse data  ***ASSUMES THAT the 1st TRs is TR 1, etc. 
tc = table2array(T(:,2:end));

% if TRs aren't given, then return all TRs in the file
if notDefined('TRs')
    TRs = 1:size(tc,2); 
end


% figure out what subjects are desired 
if notDefined('subjects')
    subjects = tc_subs;
end
if ~iscell(subjects)
    subjects = {subjects};
end


%% return timecourses for desired subjects

% get index of which rows have data for desired subjects
idx=cellfun(@(x) find(strcmp(x,tc_subs)), subjects,'uniformoutput',0);
empty_idx=find(cellfun(@isempty, idx)); % there's no data in stimfile for subjects{empty_idx}
idx = cell2mat(idx);


% return data for only desired subjects & desired TRs
tc = tc(idx,TRs); 


% in the unlikely event that a subject is specified and there's not
% timecourse data for them in the stimfile, this ugly code will make sure
% there are nan values in the corresponding row of returned data
for i=1:numel(empty_idx)
    tc=[tc(1:empty_idx(i)-1,:);
        nan(1,numel(TRs));
        tc(empty_idx(i):end,:)];
end


