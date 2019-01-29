function roiNames = whichRois(roiDir,idStr,omitStr)
% -------------------------------------------------------------------------
% usage: use this to search for ROI nifti files in a directory (roiDir)
% that contain the string (idStr), propose them to the user, and take in
% user input for desired ROI names to return
% 
% INPUT:
%   roiDir - directory path containing roi nifti files
%   idStr - string to id roi files/dirs of potential interest
%   omitStr - return roiNames with omitStr removed from string 
% 
% OUTPUT:
%   roiNames - cell array of roi file names (sans the string, omitStr)
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 10-Aug-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if notDefined('idStr')
    idStr = '*';
end
if ~strcmp(idStr(1),'*')
    idStr = ['*' idStr];
end
if ~strcmp(idStr(end),'*')
    idStr = [idStr '*'];
end

if notDefined('omitStr')
    omitStr = '';
end

% find ROIs in directory roiDir
a=dir([roiDir '/' idStr ]);
while strcmp(a(1).name(1),'.') % remove '.' entries
    a(1)=[];
end
allRoiNames = cellfun(@(x) strrep(x,omitStr,''), {a(:).name},'uniformoutput',0);


% display all found ROIs & ask user which are desired
disp(allRoiNames');
fprintf('\nwhich ROIs to process? \n');
roiNames = input('enter roi name(s), or hit return for all ROIs above: ','s');
if isempty(roiNames)
    roiNames = allRoiNames;
else
    roiNames = splitstring(roiNames);
end

