function roi_ts = roi_mean_ts(data,roi_vol)

% takes in a 4d functional data set and a 3d roi file and returns the mean
% time series averaged across all voxels with non-zero values in the roi
% file. In most cases, the roi volume will be a binary mask of ones and
% zeros, and the returned time series will be the average across voxels
% within the mask. The values in the rol volume will be used to weight the
% averaged time series.

% returns the mean time series of the voxels within the roi mask

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\ncalculating roi mean time series...\n\n');

dim = size(data);

if dim(1:3) ~= size(roi_vol)
    error('func data and roi volume dimensions must agree\n\n');
end

vox_ts=reshape(data,prod(dim(1:3)),[]);

vox_ts=vox_ts(logical(roi_vol),:); % extract just roi voxel time series

% average across non-zero (roi) voxels. Mean is weighted by the values in roi_vol
if size(vox_ts,1)~=1
    roi_ts= sum(repmat(roi_vol(roi_vol~=0),1,size(vox_ts,2)).*vox_ts)./sum(roi_vol(roi_vol~=0));
else
    roi_ts=vox_ts;
end
roi_ts = roi_ts';

fprintf('\ndone\n\n');

end