% script to save out roi time courses. This script does the following:

% load event onset files: each file should be a text file with a column
% vector of 0s and 1s to signify an event onset. Length of the vector should be
% equal to the # of acquired TRs.

% load roi binary mask files: volumes w/value of 1 signifying which voxels
% are in the roi mask; otherwise 0 values

% load pre-processed functional data & get averaged roi time courses

% get stim-locked time series based on event onset files

% plot each trial separately (this should be noisy but potentially useful
% for diagnosing movement, something weird, etc.)

% for each subject, for each roi, for each event type, get the average time
% course & save out in text file


clear all
close all

%% define initial stuff

p=getFmrieatPaths;
task='cue';
subjects=getFmrieatSubjects();
subjects=subjects(1:3)
dataDir = p.derivatives;


% filepath to pre-processed functional data where %s is subject then task
funcFilePath = fullfile(dataDir, ['%s/func_proc/pp_' task '_tlrc_afni.nii.gz']);


% file path to file that says which volumes to censor due to head movement
censorFilePath = fullfile(dataDir, ['%s/func_proc/' task '_censor.1D']);


% file path to onset time files (1st %s is subject and 2nd %s is stimNames)
stims = {'drugs','food','neutral','alcohol'};
stimFilePath = fullfile(dataDir,'%s','regs','%s_cue_cue.1D');

% roi directory
roiDir = fullfile(dataDir,'ROIs');

% get list of rois to potentially process
roiNames = whichRois(roiDir,'_func.nii','_func.nii');

% name of dir to save to;  %s is task and then roiName
outDir = fullfile(dataDir,'%s/single_trial_cue_timecourses/%s');
% 
omitOTs=0; % 1 to omit outliers, otherwise 0
if omitOTs
    outDir = [outDir '_woOutliers'];
end


nTRs = 8; % # of TRs to extract
TR = 2; % 2 sec TR
t = 0:TR:TR*(nTRs-1); % time points (in seconds) to plot


% save out a large .csv file with trials in rows
saveBigFile = 1; %1 for yes, 0 for no

%% do it


% get roi masks
roiFiles = cellfun(@(x) [x '_func.nii'], roiNames,'UniformOutput',0);
rois = cellfun(@(x) niftiRead(fullfile(roiDir,x)), roiFiles,'uniformoutput',0);

if saveBigFile
    subjid = {}; % column of subject ids
    trial_cond = {}; % trial condition
    trial_onsetTR = []; % TR at the start of the trial
    d=cell(1,numel(roiFiles)); % data array
    colNames = {}; % column names for ROI TR data
end


i=1; j=1; k=1; 
for i=1:numel(subjects) % subject loop
    
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    % load pre-processed data
    func = niftiRead(sprintf(funcFilePath,subject));
    
    % load subject's motion_censor.1D file that says which volumes to
    % censor due to motion
    censorVols = find(dlmread(sprintf(censorFilePath,subject))==0);
  
    
    j=1;
    for j=1:numel(rois)
        
        % create out directory if it doesn't already exist
        thisOutDir = sprintf(outDir,subject,roiNames{j});
        if ~exist(thisOutDir,'dir')
            mkdir(thisOutDir);
        end
        
        % this roi time series
        roi_ts = roi_mean_ts(func.data,rois{j}.data);
        
        
        % nan pad the end in case there aren't enough TRs for the last
        % trial
        roi_ts = [roi_ts;nan(nTRs,1)];
        
        
        % set vols with abs(zscore > 4) to nan (assume this is due to
        % some non-bio noise)
        if omitOTs
            % temporarily assign censored vols due to head motion to nan
            temp = roi_ts; temp(censorVols)=nan;
            censorVols=[censorVols;find(abs(zscore(temp(~isnan(temp))))>4)];
        end
%     
        
        for k=1:numel(stims)
            
            
            % get stim onset times
            onsetTRs = find(dlmread(sprintf(stimFilePath,subject,stims{k})));
            
            % # of trials for this condition
            nTrials = numel(onsetTRs); 
            
            % get array of indices of which TRs to get data for
            this_stim_TRs = repmat(onsetTRs,1,nTRs)+repmat(0:nTRs-1,nTrials,1);
            
            % single trial time courses for this stim
            this_stim_tc=roi_ts(this_stim_TRs);
            
            % set TRs that should be censored to NaN
            censor_idx=find(ismember(this_stim_TRs,censorVols));
            this_stim_tc(censor_idx)=nan; 
            
             
            dlmwrite(fullfile(thisOutDir,stims{k}),this_stim_tc)
            
            if saveBigFile 
                if j==1
                    subjid = [subjid; repmat(subjects(i),nTrials,1)];
                    trial_cond = [trial_cond; repmat(stims(k),nTrials,1)];
                    trial_onsetTR = [trial_onsetTR;onsetTRs];
                end
                 d{j} = [d{j};this_stim_tc];
              
            end
                
        end % stims
    
        if i==1
            colNames = [colNames splitstring(sprintf([strrep(roiNames{j},'_','') '_TR%d\n'],1:nTRs))];
        end
        
    end % rois
    
end % subjects


%% % save out big csv file if desired

if saveBigFile
    %     T = array2table(cell2mat(d),'VariableNames',colNames);
    T = [table(subjid,trial_cond,trial_onsetTR) array2table(cell2mat(d),'VariableNames',colNames)];
    outPath = fullfile(dataDir,'timecourses_cue_singletrials',['singletrialdata_' datestr(now,'yymmdd') '.csv']);
    writetable(T,outPath);
end

