function data = getGSSData(docid,colname,subjids,subjci)
% -------------------------------------------------------------------------
% usage: load in data from a google spreadsheet.
%
% INPUT:
%   docid - docid for the google spreadsheet

%   colname - variable name in column header. This should match EXACTLY
%   (ignoring case) what the column header is in the google spreadsheet

%   subjids - subject ids to return data for. If multiple columns are
%   desired this can be a cell array of strings.

%   subjci - (optional) column index that contains subjids. If not given,
%       this assumes its in column 1.


% OUTPUT:
%   data - desired data
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 05-Jun-2019

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%
% docid = '1Ra-JM2JyLnqYyFnfnwr8mTrcesAG94tz-REDeCNMaG8'; % doc id for google sheet
% 
% colname = {'BIS'};
% 
% subjids=getFmrieatSubjects('cue');
% 
% subjci=1;

if ~iscell(colname)
    colname={colname};
end

% assume subject ids are found in column 1 if subjidci is not given
if notDefined('subjci')
    subjci=1;
end



% try to load data from google spreadsheet
try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
catch
    warning(['\ngoogle sheet couldnt be accessed, maybe bc your offline.' ...
        'returning nothing...'])
    d={}; % ADD OFFLINE VALS HERE...
end


% if data is loaded, compute scores
if isempty(d)  
    data = [];
else
    for j=1:numel(colname)
        ci = find(strcmp(d(1,:),colname{j})); % get column index for desired variable
        for i=1:numel(subjids)
            idx=find(strncmp(d(:,subjci),subjids{i},numel(subjids{i}))); % find row index for this subject
            if isempty(idx)   
                data(i,j)=nan;
            else
                data(i,j)=str2double(d{idx,ci});
            end
        end
    end
end
