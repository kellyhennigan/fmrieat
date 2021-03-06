function [cue_type,pa,na] = getCueVARatings(filepath)
%% Import data from text file.
% Script for importing valence and arousal ratings from subjects in cue
% reactivity task, e.g.: 
%
%    /Users/Kelly/Google
%    Drive/cuefmri/cue/behavioral_data/vm151031_ratings.csv
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2015/11/19 14:50:08, light edits by Kelly

%% Initialize variables.

delimiter = ',';
startRow = 2;

% output variables
cue_type=cell(1,4);
pa=nan(1,4);
na=nan(1,4);

%% Format string for each line of text:
%   column1: text (%s)
%	column2: double (%f)
%   column3: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%f%f%[^\n\r]';

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
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names

cue_type = dataArray{:, 1}';
arousal = dataArray{:, 2}';
valence = dataArray{:, 3}';

% transform valence & arousal ratings to positive & negative arousal
[pa,na]=va2pana(valence,arousal);





