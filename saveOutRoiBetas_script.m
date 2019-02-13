% script for saving out roi betas

% this is basically to define the files, etc. to feed to the function,
% saveOutRoiBetas()



%% define variables:

clear all
close all

% get cue exp file paths, task, and subjects
[p,task,subjects,gi]=whichCueSubjects('stim');
% subjects(76:end)=[]; gi(76:end)=[];

dataDir = p.data;

% omit_subs = {'tj160529','rc170730','er171009'};
% omit_subs = {'at160601','as170730','rc170730',...
%     'er171009','vm151031','jw160316','jn160403','rb160407','yl160507',...
%     'kn160918','cs171002'};
% omit_idx=ismember(subjects,omit_subs);
% subjects(omit_idx)=[];
% gi(omit_idx)=[];



% ROIs
% roiNames = {'VTA','ins_desai','mpfc','vstriatumR_clust','vstriatumL_clust','VTA_clust'};
roiDir = fullfile(dataDir,'ROIs');
roiNames = whichRois(roiDir,'_func.nii','_func.nii');


% directory that contains glm results of interest
resultsDir = fullfile(dataDir,['results_' task '_afni']);
% resultsDir = fullfile(dataDir,['results_' task '_afni_reltest']);

%

switch task
    
    case 'cue'
        
        fileStr = 'glm_B+tlrc.HEAD'; % string identifying files w/single subject beta maps
%         volIdx = [15,16,17,18]; % index of which volumes are the beta maps of interest (first vol=0, etc.)
%         bNames = {'alcohol','drugs','food','neutral'}; % bNames should correspond to volumes in index volIdx

        volIdx = [15]; % index of which volumes are the beta maps of interest (first vol=0, etc.)
        bNames = {'alcohol'}; % bNames should correspond to volumes in index volIdx

%                 fileStr = 'glm+tlrc.HEAD'; % string identifying files w/single subject beta maps
%                 volIdx = [29,32,35]; % index of which volumes are the beta maps of interest (first vol=0, etc.)
%                 bNames = {'drugs-neutral','food-neutral','drugs-food'}; % bNames should correspond to volumes in index volIdx
%    
   
%         fileStr = 'glm_B+tlrc.HEAD'; % string identifying files w/single subject beta maps
%         volIdx = [15,16,17,18,19,20,21,22]; % index of which volumes are the beta maps of interest (first vol=0, etc.)
%         bNames = {'alcohol1','drugs1','food1','neutral1','alcohol2','drugs2','food2','neutral2'}; % bNames should correspond to volumes in index volIdx
     
    case 'mid'
        
        fileStr = 'glm_B+tlrc.HEAD'; % string identifying files w/single subject beta maps
        volIdx = [13,14,15,16]; % index of which volumes are the beta maps of interest (first vol=0, etc.)
        bNames = {'gvnant','lvnant','gvnout','nvlout'}; % bNames should correspond to volumes in index volIdx
        
        
    case 'midi'
        
end



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



