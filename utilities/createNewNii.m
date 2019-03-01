function outNii = createNewNii(refNii, varargin)
% -------------------------------------------------------------------------
% usage: use this function to create a new nifti for a volume(s) that have
% the same dimensions/space as a given template nifti file
% 
% 
% INPUT:
%   refNii - reference nifti to get all header info (xform, voxel
%            dimensions, etc.)
% 
%   varargin - can be any number of volumes, and/or an outName and 
%              description of the new nifti file. 
% 
%             If no volumes are given, outNii will be returned with a
%             volume of all zeros. 
% 
%             If strings are given, the first one will be defined as the
%             fname for the new nifti file and the second one will be
%             placed in the descrip field.
% 
% 
% OUTPUT:
%   outNii - nifti struct containing info/data specified by input
% 
% 
%
% kelly 2012; 
% revised 4/2015 to be more flexible

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% make sure a refNii is given 
if notDefined('refNii')
    error('refNii must be given')
end


% if refNii is a string, load it
if ischar(refNii)
    refNii = readFileNifti(refNii);
end


% define outNii based on refNii
outNii = refNii; 
outNii.data=zeros(outNii.dim(1:3)); % replace data w/ a volume of zeros
outNii.fname = 'outNii.nii.gz';     % if an outName is given, this will be replaced below



% fill in data if given (will either be numeric or logical)
vol_idx = find(cellfun(@(x) isnumeric(x), varargin)+cellfun(@(x) islogical(x), varargin));
if ~isempty(vol_idx)
    outNii.data=cat(4,varargin{vol_idx});
end


% fill in outNii.fname if given
str_idx = find(cellfun(@(x) ischar(x), varargin));
if ~isempty(str_idx)
    outName=varargin{str_idx(1)};
    outNii.fname = [strrep(strrep(outName,'.nii',''),'.gz','') '.nii.gz']; % this ensures .nii.gz extension is good
end

% fill in outNii.descrip if given
if numel(str_idx)>1
    outNii.descrip=varargin{str_idx(2)};
end


outNii.dim = size(outNii.data);

