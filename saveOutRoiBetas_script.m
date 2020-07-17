% script for saving out roi betas

% this is basically to define the files, etc. to feed to the function,
% saveOutRoiBetas()


clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% DEFINE VARIABLES (EDIT AS NEEDED) %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


p=getFmrieatPaths;
dataDir = p.derivatives;
figDir = p.figures;

task = 'cue';

subjects=getFmrieatSubjects(task);


% ROIs
% roiNames = {'VTA','ins_desai','mpfc','vstriatumR_clust','vstriatumL_clust','VTA_clust'};
roiDir = fullfile(dataDir,'ROIs');
roiNames = whichRois(roiDir,'_func.nii','_func.nii');


% directory that contains glm results of interest
% resultsDir = fullfile(dataDir,['results_' task '_afni']);
% resultsDir = fullfile(dataDir,['results_' task '_afni_reltest']);
resultsDir = fullfile(dataDir,['results_' task '_na']);

% DOUBLE CHECK TO MAKE SURE THESE LABELS ARE ALIGNED TO THE VOLUMES IN THE
% GLM FILES
fileStr = 'glm_B+tlrc.HEAD'; % string identifying files w/single subject beta maps
volIdx = [12]; % index of which volumes are the beta maps of interest (first vol=0, etc.)
bNames = {'na'}; % bNames should correspond to volumes in index volIdx

% fileStr = 'glm+tlrc.HEAD'; % string identifying files w/single subject beta maps
% volIdx = [29,32,35]; % index of which volumes are the beta maps of interest (first vol=0, etc.)
% bNames = {'drugs-neutral','food-neutral','drugs-food'}; % bNames should correspond to volumes in index volIdx
%    
     


% out file path
outStrPath = fullfile(resultsDir,'roi_betas','%s','%s.csv'); %s is roiNames and bNames


%% do it

for j = 1:numel(roiNames)
    
    roiFilePath = fullfile(roiDir,[roiNames{j} '_func.nii']);
    
    for k = 1:numel(bNames)
        
        outFilePath = sprintf(outStrPath,roiNames{j},bNames{k});
        
        B = saveOutRoiBetas(roiFilePath,subjects,resultsDir,fileStr,volIdx(k),outFilePath);
        
    end % beta names
    
end % roiNames



