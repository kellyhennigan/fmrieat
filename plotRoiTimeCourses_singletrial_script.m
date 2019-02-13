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


p=getCuePaths();
task=whichCueTask(); 

task_subjects = getCueSubjects(task);
fprintf('\n');
subj_list=cellfun(@(x) [x ' '], task_subjects, 'UniformOutput',0)';
disp([subj_list{:}]);
fprintf('\nwhich subjects to process? \n');
subjects = input('enter sub ids, or hit return for all subs above: ','s');
if isempty(subjects)
    subjects = task_subjects;
else
    subjects = splitstring(subjects)';
end

dataDir = p.data;


afniStr = '_afni';
%      afniStr = '';


% filepath to pre-processed functional data where %s is subject then task
funcFilePath = fullfile(dataDir, ['%s/func_proc/pp_%s_tlrc' afniStr '.nii.gz']);


% file path to file that says which volumes to censor due to head movement
censorFilePath = fullfile(dataDir, ['%s/func_proc/%s_censor.1D']);


% directory w/regressor time series (NOT convolved)
% file path to onset time files (1st %s is subject and 2nd %s is stimNames)
stimFilePath = fullfile(dataDir,'%s','regs','cue_cue.1D');


% roi directory
roiDir = fullfile(dataDir,'ROIs');

% get list of rois to potentially process
roiNames = whichRois(roiDir,'_func.nii','_func.nii');


% name of dir to save to where %s is task
outDir = fullfile(dataDir,['timecourses_' task afniStr ]);

nTRs = 8; % # of TRs to extract
TR = 2; % 2 sec TR
t = 0:TR:TR*(nTRs-1); % time points (in seconds) to plot


%% do it


% get roi masks
roiFiles = cellfun(@(x) [x '_func.nii'], roiNames,'UniformOutput',0);
rois = cellfun(@(x) niftiRead(fullfile(roiDir,x)), roiFiles,'uniformoutput',0);


i=1; j=1;
for i=1:numel(subjects) % subject loop
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    % load pre-processed data
    func = niftiRead(sprintf(funcFilePath,subject,task));
    
    % load subject's motion_censor.1D file that says which volumes to
    % censor due to motion
    censorVols = find(dlmread(sprintf(censorFilePath,subject,task))==0);
    
    
    % get stim onset times
    onsetTRs = find(dlmread(sprintf(stimFilePath,subject)));
    
    
    % matrix of TR indices for each trial
    stim_TRs = repmat(onsetTRs,1,nTRs)+repmat(0:nTRs-1,numel(onsetTRs),1);
    
    
    for j=1:numel(rois)
        
        % this roi time series
        roi_ts = roi_mean_ts(func.data,rois{j}.data);
        
        
        % identify outlier TRs (not including those already censored due to
        % motion)
        temp = roi_ts; temp(censorVols)=mean(roi_ts);
        otVols=find(abs(zscore(temp))>4);
        
        
        % nan pad the end in case there aren't enough TRs for the last
        % trial
        roi_ts = [roi_ts;nan(nTRs,1)];
        
        
        % single trial time courses
        stim_tc=roi_ts(stim_TRs);
        
        % identify trials with censored motion & outlier TRs
        [censor_idx,~]=find(ismember(stim_TRs,censorVols));
        censor_idx = unique(censor_idx);
        censored_tc = stim_tc(censor_idx,:);
        [ot_idx,~]=find(ismember(stim_TRs,otVols));
        ot_idx = unique(ot_idx);
        ot_tc = stim_tc(ot_idx,:);
        
        
        % keep count of the # of censored & outlier trials
        nBadTrials(i,1) = numel(censor_idx)+numel(ot_idx);
        
        
        %% plot single trials
        
        h = figure('Visible','off');
        hold on
        set(gca,'fontName','Arial','fontSize',12)
        
        % plot all single trial timecourses
        plot(t,stim_tc','linewidth',1.5,'color',[.15 .55 .82])
        
        % plot timecourses with outlier and censored TRs
        if ~isempty(ot_tc)
            plot(t,ot_tc','linewidth',1.5,'color',[.8 .3 .08])
        end
        if ~isempty(censored_tc)
            plot(t,censored_tc','linewidth',1.5,'color',[.83 .21 .51])
        end
        xlim([t(1) t(end)])
        set(gca,'XTick',t)
        xlabel('time (in seconds) relative to cue onset')
        ylabel('%\Delta BOLD')
        set(gca,'box','off');
        set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');
        
        title(gca,subject)
        
        % save out plot
        thisOutDir = fullfile(outDir,roiNames{j},'single_trial_plots');
        if ~exist(thisOutDir,'dir')
            mkdir(thisOutDir);
        end
        print(gcf,'-dpng','-r300',fullfile(thisOutDir,subject));
        
        
    end % rois
    
end % subject loop

