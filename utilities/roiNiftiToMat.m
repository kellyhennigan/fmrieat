function roi = roiNiftiToMat(roiNii, saveOut)
%
% converts a nifti roi file to a .mat file
% of the same format as those generated
% with dtiFiberUI and saves it in the same directory
%
% uses the dtiNewRoi function to make the Roi
%
% inputs:
%   roiNii - file name of nii file (e.g., 'ROI.nii.gz')
%   saveOut - 1 to save out roi file, otherwise 0. Default is 0. If
%          saveOut=1 and the roiNii is a filepath, the roi will be
%          saved out to the same directory. If saveOut=1 and roiNii is
%          loaded, then it will save out to the current working directory.
%
% outputs:
%     matRoi - roi in .mat format with same name as roiNii. If saveOut is
%     set to 1, it will be saved out to same directory as roiNii (if given
%     as a filepath) or if roiNii was already loaded, will save out to the
%     current directory. 

%
% example usage:
%   roiNiftiToMat('path/to/nii/roi.nii.gz',1)     % roi.mat will be saved out to same dir as roiNii
%   roi = roiNiftiToMat(roiNii)                   % to get roi coords without saving it out
% 
%
% kjh 4/2011
%
% I took code from dtiConvertFreeSurferRoiToMat

% 3/15, edited to take more flexible inputs (i.e., string filenames, paths,
% or loaded roi niis)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% checks on roiNii input
if notDefined('roiNii')
    error('roiNii must be given as input argument');
end

% unless user says to save out the file, don't save it
if notDefined('saveOut')
    saveOut = 0;
end


% if roiNii is a filepath, load it 
if ischar(roiNii)
    roiNii = readFileNifti(roiNii);
end


% get roiStr to name .mat roi the same thing
[roiDir,roiStr]= fileparts(roiNii.fname);  
[~,roiStr]= fileparts(roiStr);   % repeat to take .nii off of string
    


%% do it

fprintf(['\ncreating roi ' roiStr '.mat\n']);

% get roi coords in img space
[i j k]=ind2sub(size(roiNii.data),find(roiNii.data));

% xform coords to acpc space
acpc_coords = mrAnatXformCoords(roiNii.qto_xyz,[i j k]);

% create a new roi with mrDiffusion structure
roi=dtiNewRoi(roiStr,[],acpc_coords); % name, color, coords


% if desired, save out .mat roi file 
if saveOut
    dtiWriteRoi(roi,fullfile(roiDir,roiStr), [],'acpc');  % roi, filename, versionNum, coordinateSpace, xform
end

