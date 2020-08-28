%% quick and dirty script to plot and save out an ROI mask in x,y, and z planes


clear all
close all

p = getFmrieatPaths();
dataDir = p.derivatives;
figDir = p.figures;

roiName = 'gust8mm_Porubska';
roiPath =  fullfile(dataDir,'ROIs',[roiName '.nii']);
t1Path = fullfile(dataDir,'templates','TT_N27.nii');
% t1Path = fullfile(dataDir,'templates','mni_icbm152_t1_tal_nlin_asym_09a_brain.nii');

outDir = fullfile(figDir,'ROIs');
if ~exist(outDir,'dir')
    mkdir(outDir)
end
    
saveViews = {'x','y','z'}; % x y z for sagittal, coronal, and axial views

% col = [1 0 0]; % color for ROI mask
col = [1 0 0]; % color for ROI mask

%% do it

roi = niftiRead(roiPath);
t1 = niftiRead(t1Path);


% determine x,y,z slices with the most roi coords
[i j k]=ind2sub(size(roi.data),find(roi.data));
sl = mode(round(mrAnatXformCoords(roi.qto_xyz,[i j k]))); % x,y and z slices to plot



for i=1:3
    [imgRgbs,~,~,h,acpcSlices{i}] = plotOverlayImage(roi,t1,col,[0 1],i,sl(i));
    outPath = fullfile(outDir,[roiName '_' saveViews{i} num2str(sl(i))]);
    print(h,'-dpng','-r300',outPath)
    saveas(h{1},[outPath '.png'])
%     imwrite(,'myMultipageFile.tif')
end

