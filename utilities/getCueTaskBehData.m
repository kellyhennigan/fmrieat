function [Trial,TR,StartTime,Clock,Trial_Onset,Trial_Type,Cue_RT,Choice,Choice_Num,...
    Choice_Type,Choice_RT,ITI,Drift,Image_Names]=getCueTaskBehData(filepath,format)
% -------------------------------------------------------------------------
% usage: import behavioral data from cue fmri task
%
% INPUT:
%   filepath - string specifying the data file
%   format - string specifying short or long form (must be either 'short'
%             or 'long'; default is short)
%
% OUTPUT:
%   desribe output variables here
%
% author: Kelly, kelhennigan@gmail.com, 19-Nov-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% short or long form?

if notDefined('format')
    format = 'short';
end


%% Initialize variables.

delimiter = ',';

% output variables 
Trial=[];
TR=[];
StartTime=[];
Clock=[];
Trial_Onset=[];
Trial_Type=[];
Cue_RT=[];
Choice=[];
Choice_Num=[];
Choice_Type=[];
Choice_RT=[];
ITI=[];
Drift=[];
Image_Names=[];


%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filepath,'r');

% if fileID=-1, this means the file couldn't be opened. Return empty
% values.
if fileID==-1
    return
end

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);


%% make sure there isn't an extra header row, because that means trials from 
% another run are recorded

 try 
     cell2mat(dataArray{2}(2:end));
 catch 
     error(['check data file ' filepath ' - it probably contains trials from another run']);
end



%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,8,9,10,11]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end


%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [1,2,3,4,5,6,8,9,10,11]);
rawCellColumns = raw(:, [7,12]);


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names


Trial = cell2mat(rawNumericColumns(2:end, 1));
TR = cell2mat(rawNumericColumns(2:end, 2));

StartTime = rawNumericColumns(1,3); % very first clock entry is the scan start time

Clock = cell2mat(rawNumericColumns(2:end, 3));
Trial_Onset = cell2mat(rawNumericColumns(2:end, 4));
Trial_Type = cell2mat(rawNumericColumns(2:end, 5));
Cue_RT = cell2mat(rawNumericColumns(2:end, 6));
Choice = rawCellColumns(2:end, 1);
Choice_Type = cell2mat(rawNumericColumns(2:end, 7));
Choice_RT = cell2mat(rawNumericColumns(2:end, 8));
ITI = cell2mat(rawNumericColumns(2:end, 9));
Drift = cell2mat(rawNumericColumns(2:end, 10));
Image_Names = rawCellColumns(2:end, 2);

%% code want ratings as numeric

Choice_Num = zeros(numel(Choice),1);
Choice_Num(strcmp('Strongly do not want',Choice))=-3;
Choice_Num(strcmp('Somewhat do not want',Choice))=-1;
Choice_Num(strcmp('Somewhat want',Choice))=1;
Choice_Num(strcmp('Strongly want',Choice))=3;



%% short or long format?

% if short format is requested, return only 1 row entry per trial
if strcmp(format,'short')
    
    % get an index for rows w/new trial starts
    t_idx = [1;find(diff(Trial))+1];
    if any(isnan(Trial(t_idx)))
        t_idx(isnan(Trial(t_idx)))=[];
    end
    
    Trial = Trial(t_idx);
    TR = TR(t_idx);
    Clock = Clock(t_idx);
    Trial_Onset = Trial_Onset(t_idx);
    Trial_Type = Trial_Type(t_idx);
    Cue_RT = Cue_RT(t_idx);
    Choice = Choice(t_idx);
    Choice_Num = Choice_Num(t_idx);
    Choice_Type = Choice_Type(t_idx);
    Choice_RT = Choice_RT(t_idx);
    ITI = ITI(t_idx);
    Drift = Drift(t_idx);
    Image_Names = Image_Names(t_idx);
end

