% script to do voxelwise analysis to look at relationship to outcomes 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define variables, get paths

clear all
close all

p=getFmrieatPaths;
subjects=getFmrieatSubjects('cue');

baseDir=p.baseDir;
dataDir = p.derivatives;

inDir = fullfile(dataDir,'results_cue');

outDir = fullfile(dataDir,'results_cue','voxelwise_outcomes_analysis');
if ~exist(outDir,'dir')
    mkdir(outDir)
end

stims = {'neutral','drugs'};

beta_fstr = '_glm+tlrc';

mask = niftiRead(fullfile(dataDir,'ROIs','bmask.nii')); % brain mask



%%  extract beta values of interest and save out as separate single volume nifti files
% 
% cd(inDir)
% for k=1:numel(stims)
%     
%     for i=1:numel(subjects)
%         
%         cmd = ['3dinfo -label2index ' stims{k} '#0_Coef ' subjects{i} beta_fstr]
%         [status,cmdout]=system(cmd);
%         si=strfind(cmdout,sprintf('\n')); % index number is between 2 line breaks
%         
%         outfile =  [outDir '/' subjects{i} '_' stims{k} '.nii']; % nifti filepath for saving out beta map
%         cmd = ['3dTcat ' subjects{i} beta_fstr '[' cmdout(si(1)+1:si(2)-1) '] -output ' outfile];
%         [status,cmdout]=system(cmd);
%         
%     end % subjects
%     
% end % stims


%% get outcomes data 
% 
% T=readtable(fullfile(dataDir,'prediction_data','data_200717.csv'));
% 
% relapse = getCueData(subjects,'relapse');
% obstime = getCueData(subjects,'observedtime');
% 
% % omit subjects without followup data from analysis
% nanidx = find(isnan(relapse));
% relapse(nanidx) = [];
% obstime(nanidx) = [];
% subjects(nanidx) = [];
% 
% censored = abs(relapse-1); % censored var is 1 for non-relapse, 0 for relapse
% 
% % k=1
% for k=1:numel(stims)
% 
% for i=1:numel(subjects)
%     
%     bfile =  [outDir '/' subjects{i} '_' stims{k} '.nii']; % nifti filepath for saving out beta map
%      ni = niftiRead(bfile);
%      X(i,:) = double(reshape(ni.data,1,[])); % all this subjects' voxels in the ith row
%    
% end
% 
% fprintf(['\nworking on survival analysis for ' stims{k} ' betas...\n'])
% 
% % there's prob a better/faster way to do this...
% Z = zeros(size(mask.data));
% 
% for vi = find(mask.data)'
%     
%     [b,logl,H,stats] = coxphfit(X(:,vi),obstime,'Censoring',censored);
%     Z(vi) = stats.z;
% 
% end % voxels in brain mask
% 
% outPath = fullfile(outDir,['Z' stims{k} '.nii.gz']); % out filepath
% Zni = createNewNii(mask,outPath,Z,['zscores for Cox regression on n=' num2str(numel(subjects)) ' patients']);     
%      
% writeFileNifti(Zni); % save out nifti volume
% cmd = ['3drefit -fbuc -sublabel 0 CoxZ -substatpar 0 fizt ' outPath];
% disp(cmd);
% system(cmd);
% 
% fprintf(['done.\n\n'])
% 
% end % stims
% 
% 
% 
% 
