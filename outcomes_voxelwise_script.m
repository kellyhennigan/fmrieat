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

% 
stim = 'food'

% ymeasure = 'BMI_2';
% ymeasure = 'BMI_2';
ymeasure = 'BMI_delta';


mask = niftiRead(fullfile(dataDir,'ROIs','bmask.nii')); % brain mask


%%  extract beta values of interest and save out as separate single volume nifti files

% betas = {'alcohol','food','neutral','drugs'};
% beta_fstr = '_glm+tlrc';

% cd(inDir)
% for k=1:numel(betas)
%     
%     for i=1:numel(subjects)
%         
%         cmd = ['3dinfo -label2index ' betas{k} '#0_Coef ' subjects{i} beta_fstr]
%         [status,cmdout]=system(cmd);
%         si=strfind(cmdout,sprintf('\n')); % index number is between 2 line breaks
%         
%         outfile =  [outDir '/' subjects{i} '_' betas{k} '.nii']; % nifti filepath for saving out beta map
%         cmd = ['3dTcat ' subjects{i} beta_fstr '[' cmdout(si(1)+1:si(2)-1) '] -output ' outfile];
%         [status,cmdout]=system(cmd);
%         
%     end % subjects
%     
% end % betas


%% get outcomes data 
% 
T=readtable(fullfile(dataDir,'prediction_data','data_200717.csv'));

% 
% omit subjects that dont have outcome data as defined above

eval(['T(isnan(T.' ymeasure '),:)=[];']);
y = eval(['T.' ymeasure]);

% get new subject list that includes only subjects with desired outcome data
subjects = T.subjects; 

% 
for i=1:numel(subjects)
%     
    bfile =  [outDir '/' subjects{i} '_' stim '.nii']; % nifti filepath for saving out beta map
     ni = niftiRead(bfile);
     X(i,:) = double(reshape(ni.data,1,[])); % all this subjects' voxels in the ith row
   
end

fprintf(['\nworking on ' stim ' betas X ' ymeasure ' analysis...\n'])
% 
% % there's prob a better/faster way to do this...
t = zeros(size(mask.data));
% 
for vi = find(mask.data)'
    
    res = fitglm(X(:,vi),y,'Distribution','normal');
    t(vi) = res.Coefficients.tStat(2);

end % voxels in brain mask
% 
df = numel(subjects)-2; 

outPath = fullfile(outDir,['T' stim 'X' ymeasure '.nii.gz']); % out filepath

tni = createNewNii(mask,outPath,t,['tstats for ' stim ' X ' ymeasure ' regression on n=' num2str(numel(subjects))]);     
%      
writeFileNifti(tni); % save out nifti volume

cmd = sprintf('3drefit -sublabel 0 %s -substatpar 0 fitt %d %s',[stim 'X' ymeasure '_tstat'],df,tni.fname);
disp(cmd);
system(cmd);
% 
fprintf(['done.\n\n'])
% 
% end % stims
% 
% 
% 
% 
