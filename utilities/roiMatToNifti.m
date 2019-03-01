function niiRoi = roiMatToNifti(matRoiFile, niiRefFile,saveOut)
%
% converts a .mat roi to a nifti file. 

% if saving is desired, it will save out to the same directory as
% matRoiFile (if its given as a filepath), otherwise, it will save it out
% to the current directory.
%
% note: assumes this is called from a subject's main directory and that the
% nii ref file is in the current dir
%
%
% inputs: 
%   matRoiFile - .mat roi file to convert 
%   refFile - reference file for header info
%   saveOut - 1 to save out nii roi file, otherwise 0. Default is 0. If
%          saveOut=1 and the matRoiFile is a filepath, the nii roi will be
%          saved out to the same directory. If saveOut=1 and matRoiFile is
%          loaded, then it will save out to the current working directory.
%
% 
% outputs: Roi nifti file and (if desired) saved to the same directory as
%          roi mat file. 
%
% kjh 4/2011
%
% edited 4/2015 to be more flexible
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 

% check on matRoiFile
if notDefined('matRoiFile')
    error('matRoiFile must be given as input argument');
end

% if its a filepath, load it
if ischar(matRoiFile)
    [fp,~,~]=fileparts(matRoiFile); % fp gives filepath 
    load(matRoiFile);
    matRoiFile = roi;
else
    fp = '';   % set filepath to '' if not given
end

% checks on niiRefFile
if notDefined('niiRefFile')
    error('niiRefFile must be given as input argument');
end
if ischar(niiRefFile)
    niiRefFile = readFileNifti(niiRefFile);
end

outFName = matRoiFile.name;

% check whether to save or not
if notDefined('saveOut')
    saveOut = 0;
end


%% do it 

fprintf(['\n\n creating roi file ',outFName,'\n\n']);

% get roi img coordinates
imgCoords = round(mrAnatXformCoords(niiRefFile.qto_ijk, matRoiFile.coords));
coordIndx = sub2ind(niiRefFile.dim(1:3),imgCoords(:,1),imgCoords(:,2),imgCoords(:,3));

% define a new nifti file w/1 for roi voxels
niiRoi = niiRefFile;
niiRoi.data = zeros(niiRoi.dim(1:3));
niiRoi.data(coordIndx) = 1;
niiRoi.fname = fullfile(fp,[matRoiFile.name '.nii.gz']);
      

% save new nifti ROI file
if saveOut      
    writeFileNifti(niiRoi);
end
