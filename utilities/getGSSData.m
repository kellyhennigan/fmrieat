function data = getGSSData(docid,colname,subjects,subjci,stringvec)
% -------------------------------------------------------------------------
% usage: load in data from a google spreadsheet.
%
% INPUT:
%   docid - docid for the google spreadsheet

%   colname - variable name in column header. This should match EXACTLY
%   (ignoring case) what the column header is in the google spreadsheet

%   subjects - subject ids to return data for. If multiple columns are
%   desired this can be a cell array of strings.

%   subjci - column index that contains subjects. If not given,
%       this assumes its in column 1. Number must correspond to
%       numel(colnames), or if just1 value (0 or 1), all colnames data will
%       inherit the desired format.

%  stringvec (optional) - 1 to specify that it should be a string vector;
%  otherwise will save out as a floating numbers. If not given, default is
%  0. All returned data will be either as number or string array

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
% subjects=getFmrieatSubjects('cue');
%
% subjci=1;

if ~iscell(colname)
    colname={colname};
end

% assume subject ids are found in column 1 if subjidci is not given
if notDefined('subjci')
    subjci=1;
end

% 1 if data shold be saved out as a string, otherwise
if notDefined('stringvec')
    stringvec=0;
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
    data = {};
else
    for j=1:numel(colname)
        j
        ci = find(strcmpi(colname{j},d(1,:))); % get column index for desired variable
        ci
        for i=1:numel(subjects)
            idx=find(strncmp(d(:,subjci),subjects{i},numel(subjects{i}))); % find row index for this subject
            
            %%%%%%% string output
            if stringvec
                
                % if no subject idx is found, set to nan
                if isempty(idx)
                    data{i,j}=nan;
                    
                    % if value for subject is empty, set to nan
                elseif isempty(d{idx,ci})
                    data{i,j}=nan;
                    
                    % save out string value
                else
                    data{i,j}=d{idx,ci};
                    
                end
                
                %%%%%%% numeric data output
            else
                
                % if no subject idx is found, set to nan
                if isempty(idx)
                    data(i,j)=nan;
                    
                    % if value for subject is empty, set to nan
                elseif isempty(d{idx,ci})
                    data(i,j)=nan;
                    
                    % save out numeric value
                else
                    data(i,j)=str2double(d{idx,ci});
                    
                end
                
            end % string or number
            
            
        end % subject loop
        
    end % colname loop

end % if isempty(d)