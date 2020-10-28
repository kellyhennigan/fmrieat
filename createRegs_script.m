% createRegs_script

% script to make regressors for all cue exp subjects
%
% will save out separate base and stress regressors for each stim
% listed below, a separate regressor time series will be modeled for onsets
% occurring during the baseline and stress contexts.


clear all
close all


p=getFmrieatPaths;

subjects=getFmrieatSubjects('cue');

%subjects={'ts190110'};


% hard code # of TRs bc behavioral log file doesn't match # of actual TRs acquired
nTRs = 436;


% stim file, where %s will be subject id
stimfilepath = [p.source '/%s/behavior/cue_matrix.csv'];

% this corresponds to trial types 1-4, respectively
conds = {'alcohol','drugs','food','neutral'};


% labels to be used for reg filenames for pref ratings
pref_idx = [-3 -1 1 3];
pref_labels = {'strongdontwant','somewhatdontwant',...
    'somewhatwant','strongwant'};


% file path to post-scan qualtrics ratings
%qualtricsfilepath = [dataDir '/qualtrics_data/Post_Scan_Survey_180319.csv'];

hrf = 'waver'; % choices are spm or 'waver'

% subject stim file will have a TR column where TR indexes the following
% parts of each trial:
%   1 - cue onset
%   2 - image onset
%   3 & 4 - choice period
%   5,6 & 7 - iti period


%%%%% this script makes the following (unconvolved regressors):
% cue onset by condition (alcohol, drugs. etc.)
% img onset by condition
% choice onset by condition
% choice period by condition
% cue rt
% choice rt
% pref ratings at image onset
% pref ratigns at choice period onset



%%

% get PA & NA ratings
pa=readtable(fullfile(p.derivatives,'PANAratings','pa.csv'));
na=readtable(fullfile(p.derivatives,'PANAratings','na.csv'));

%[qd,PA,NA,famil,qimage_type]=getQualtricsData(qualtricsfilepath,subjects);


for s=1:numel(subjects)
    
    subject = subjects{s};
    
    fprintf(['\n\nSaving regressor time series for subject ' subject '...\n\n']);
    
    % define output directory for regressors
    regDir =  fullfile(p.derivatives,subject,'regs');
    
    % if reg dir doesn't exist, create it
    if ~exist(regDir,'dir')
        mkdir(regDir)
    end
    
    
    [trial,tr,starttime,clock,trial_onset,trial_type,cue_rt,choice,choice_num,...
        choice_type,choice_rt,iti,drift,image_name]=getCueTaskBehData(sprintf(stimfilepath,subject),'long');
    
 
    
    % if numel(tr) is zero, then behavioral data for this subject wasn't loaded
    if numel(tr)==0
        fprintf(['\n behavioral data not loaded for subject ' subject ', so skipping...\n'])
    else
        
        
        %% make reg time series
        
        
        %%%%%%%%%%%%%%%%%%% cue onset period: tr=1
        [reg,regc]=createRegTS(find(tr==1),1,nTRs,hrf,[regDir '/cue_cue.1D']);
        
        
        %%%%%%%%%%%%%%%%%%% img onset period: tr=2
        [reg,regc]=createRegTS(find(tr==2),1,nTRs,hrf,[regDir '/img_cue.1D']);
        
        
        %%%%%%%%%%%%%%%%%%% choice onset period: tr=3
        [reg,regc]=createRegTS(find(tr==3),1,nTRs,hrf,[regDir '/choice_cue.1D']);
        
        
        %%%%%%%%%%%%%%%%%%% choice period: tr=3 & tr=4
        [reg,regc]=createRegTS(find(tr==3 | tr==4),1,nTRs,hrf,[regDir '/choice2_cue.1D']);
        
        
        %%%%%%%%%%%%%%%%%%% cue onset by trial type
        for i=1:4
            [reg,regc]=createRegTS(find(tr==1 & trial_type==i),1,nTRs,hrf,[regDir '/' conds{i} '_cue_cue.1D']);
        end
        
        
        %%%%%%%%%%%%%%%%%%% image onset by trial type
        for i=1:4
            [reg,regc]=createRegTS(find(tr==2 & trial_type==i),1,nTRs,hrf,[regDir '/' conds{i} '_img_cue.1D']);
        end
        
        
%         %%%%%%%%%%%%%%%%%%% cue & image by trial type
%         for i=1:4
%             [reg,regc]=createRegTS(find(trial_type==i & (tr==1 | tr==2)),1,nTRs,hrf,[regDir '/' conds{i} '_cueimg_cue.1D']);
%         end
%         
        
        %%%%%%%%%%%%%%%%%%% choice onset by trial type
        for i=1:4
            [reg,regc]=createRegTS(find(tr==3 & trial_type==i),1,nTRs,hrf,[regDir '/' conds{i} '_choice_cue.1D']);
        end
        
        
        %%%%%%%%%%%%%%%%%%% choice period by trial type
        for i=1:4
            [reg,regc]=createRegTS(find(trial_type==i & (tr==3 | tr==4)),1,nTRs,hrf,[regDir '/' conds{i} '_choice2_cue.1D']);
        end
        
        
        %%%%%%%%%%%%%%%%%% model whole trial by type
        for i=1:4
            [reg,regc]=createRegTS(find(trial_type==i & (tr==1 | tr==2 | tr==3 | tr==4)),1,nTRs,hrf,[regDir '/' conds{i} '_trial_cue.1D']);
        end
        [reg,regc]=createRegTS(find(tr==1 | tr==2 | tr==3 | tr==4),1,nTRs,hrf,[regDir '/trial_cue.1D']);
        
        
        %%%%%%%%%%%%%%%%%%% model just subset of food trials where PA is greater than some value
        food_idx=find(trial_type==3 & (tr==1 | tr==2 | tr==3 | tr==4));
        ri=find(strcmp(subject,pa.subjects));
        subject_pa=table2array(pa(ri,2:end));
            food_trial_idx=trial(trial_type==3 & tr==1);
            food_pa=subject_pa(food_trial_idx); % this subjects positive arousal ratigns for food trials
            
            top_pa_idx=find(food_pa>=median(food_pa));
            food_top_pa_trial_idx=food_trial_idx(top_pa_idx);
            
            % keep track of the # of trials in this reg for each subject
            n_toppa_trials(s,1)=numel(food_top_pa_trial_idx);
            
            % get just subset of trials with high pa        
            [reg,regc]=createRegTS(find(ismember(trial,food_top_pa_trial_idx) & (tr==1 | tr==2 | tr==3 | tr==4)),1,nTRs,hrf, [regDir '/food_topPA_trial_cue.1D']);
            
               % get just subset of trial ONSETs with high pa        
            [reg,regc]=createRegTS(find(ismember(trial,food_top_pa_trial_idx) & (tr==1)),1,nTRs,0, [regDir '/food_topPA_cue_cue.1D']);
         
               bottom_pa_idx=find(food_pa<median(food_pa));
            food_bottom_pa_trial_idx=food_trial_idx(bottom_pa_idx);
            
            % keep track of the # of trials in this reg for each subject
            n_bottompa_trials(s,1)=numel(food_bottom_pa_trial_idx);
            
            % get just subset of trials with high pa        
            [reg,regc]=createRegTS(find(ismember(trial,food_bottom_pa_trial_idx) & (tr==1 | tr==2 | tr==3 | tr==4)),1,nTRs,hrf, [regDir '/food_lowPA_trial_cue.1D']);
         
               % get just subset of trial ONSETs with high pa        
            [reg,regc]=createRegTS(find(ismember(trial,food_bottom_pa_trial_idx) & (tr==1)),1,nTRs,0, [regDir '/food_lowPA_cue_cue.1D']);
            
             %%%%%%%%%%%%%%%%%%% model just subset of alcohol trials where PA is greater than some value
        alcohol_idx=find(trial_type==1 & (tr==1 | tr==2 | tr==3 | tr==4));
        ri=find(strcmp(subject,pa.subjects));
        subject_pa=table2array(pa(ri,2:end));
            alcohol_trial_idx=trial(trial_type==1 & tr==1);
            alcohol_pa=subject_pa(alcohol_trial_idx); % this subjects positive arousal ratings for alcohol trials
            
            top_pa_idx=find(alcohol_pa>=median(alcohol_pa));
            alcohol_top_pa_trial_idx=alcohol_trial_idx(top_pa_idx);
            
            % keep track of the # of trials in this reg for each subject
            n_toppa_trials(s,1)=numel(alcohol_top_pa_trial_idx);
            
            % get just subset of trials with high pa        
            [reg,regc]=createRegTS(find(ismember(trial,alcohol_top_pa_trial_idx) & (tr==1 | tr==2 | tr==3 | tr==4)),1,nTRs,hrf, [regDir '/alcohol_topPA_trial_cue.1D']);
            
               % get just subset of trial ONSETs with high pa        
            [reg,regc]=createRegTS(find(ismember(trial,alcohol_top_pa_trial_idx) & (tr==1)),1,nTRs,0, [regDir '/alcohol_topPA_cue_cue.1D']);
         
               bottom_pa_idx=find(alcohol_pa<median(alcohol_pa));
            alcohol_bottom_pa_trial_idx=alcohol_trial_idx(bottom_pa_idx);
            
            % keep track of the # of trials in this reg for each subject
            n_bottompa_trials(s,1)=numel(alcohol_bottom_pa_trial_idx);
            
            % get just subset of trials with high pa        
            [reg,regc]=createRegTS(find(ismember(trial,alcohol_bottom_pa_trial_idx) & (tr==1 | tr==2 | tr==3 | tr==4)),1,nTRs,hrf, [regDir '/alcohol_lowPA_trial_cue.1D']);
         
               % get just subset of trial ONSETs with high pa        
            [reg,regc]=createRegTS(find(ismember(trial,alcohol_bottom_pa_trial_idx) & (tr==1)),1,nTRs,0, [regDir '/alcohol_lowPA_cue_cue.1D']);
            
             %%%%%%%%%%%%%%%%%%% model just subset of food trials where NA is greater than some value
        food_idx=find(trial_type==3 & (tr==1 | tr==2 | tr==3 | tr==4));
        ri=find(strcmp(subject,na.subjects));
        subject_na=table2array(na(ri,2:end));
            food_trial_idx=trial(trial_type==3 & tr==1);
            food_na=subject_na(food_trial_idx); % this subjects positive arousal ratigns for food trials
            
            top_na_idx=find(food_na>=median(food_na));
            food_top_na_trial_idx=food_trial_idx(top_na_idx);
            
            % keep track of the # of trials in this reg for each subject
            n_topna_trials(s,1)=numel(food_top_na_trial_idx);
            
            % get just subset of trials with high na        
            [reg,regc]=createRegTS(find(ismember(trial,food_top_na_trial_idx) & (tr==1 | tr==2 | tr==3 | tr==4)),1,nTRs,hrf, [regDir '/food_topNA_trial_cue.1D']);
            
               % get just subset of trial ONSETs with high na        
            [reg,regc]=createRegTS(find(ismember(trial,food_top_na_trial_idx) & (tr==1)),1,nTRs,0, [regDir '/food_topNA_cue_cue.1D']);
         
               bottom_na_idx=find(food_na<median(food_na));
            food_bottom_na_trial_idx=food_trial_idx(bottom_na_idx);
            
            % keep track of the # of trials in this reg for each subject
            n_bottomna_trials(s,1)=numel(food_bottom_na_trial_idx);
            
            % get just subset of trials with high na        
            [reg,regc]=createRegTS(find(ismember(trial,food_bottom_na_trial_idx) & (tr==1 | tr==2 | tr==3 | tr==4)),1,nTRs,hrf, [regDir '/food_lowNA_trial_cue.1D']);
         
               % get just subset of trial ONSETs with high na        
            [reg,regc]=createRegTS(find(ismember(trial,food_bottom_na_trial_idx) & (tr==1)),1,nTRs,0, [regDir '/food_lowNA_cue_cue.1D']);
            
             %%%%%%%%%%%%%%%%%%% model just subset of alcohol trials where NA is greater than some value
        alcohol_idx=find(trial_type==1 & (tr==1 | tr==2 | tr==3 | tr==4));
        ri=find(strcmp(subject,na.subjects));
        subject_na=table2array(na(ri,2:end));
            alcohol_trial_idx=trial(trial_type==1 & tr==1);
            alcohol_na=subject_na(alcohol_trial_idx); % this subjects positive arousal ratigns for alcohol trials
            
            top_na_idx=find(alcohol_na>=median(alcohol_na));
            alcohol_top_na_trial_idx=alcohol_trial_idx(top_na_idx);
            
            % keep track of the # of trials in this reg for each subject
            n_topna_trials(s,1)=numel(alcohol_top_na_trial_idx);
            
            % get just subset of trials with high na        
            [reg,regc]=createRegTS(find(ismember(trial,alcohol_top_na_trial_idx) & (tr==1 | tr==2 | tr==3 | tr==4)),1,nTRs,hrf, [regDir '/alcohol_topNA_trial_cue.1D']);
            
               % get just subset of trial ONSETs with high na        
            [reg,regc]=createRegTS(find(ismember(trial,alcohol_top_na_trial_idx) & (tr==1)),1,nTRs,0, [regDir '/alcohol_topNA_cue_cue.1D']);
         
               bottom_na_idx=find(alcohol_na<median(alcohol_na));
            alcohol_bottom_na_trial_idx=alcohol_trial_idx(bottom_na_idx);
            
            % keep track of the # of trials in this reg for each subject
            n_bottomna_trials(s,1)=numel(alcohol_bottom_na_trial_idx);
            
            % get just subset of trials with high na        
            [reg,regc]=createRegTS(find(ismember(trial,alcohol_bottom_na_trial_idx) & (tr==1 | tr==2 | tr==3 | tr==4)),1,nTRs,hrf, [regDir '/alcohol_lowNA_trial_cue.1D']);
         
               % get just subset of trial ONSETs with high na        
            [reg,regc]=createRegTS(find(ismember(trial,alcohol_bottom_na_trial_idx) & (tr==1)),1,nTRs,0, [regDir '/alcohol_lowNA_cue_cue.1D']);
                
        
%           %%%%%%%%%%%%%%%%%%% cue onset by pref ratings (for VOIs)
        for i=1:4
            [reg,~]=createRegTS(find(tr==1 & choice_num==pref_idx(i)),1,nTRs,0, [regDir '/' pref_labels{i} '_cue_cue.1D']);
        end
     
%         %%%%%%%%%%%%%%%%%%% image onset by pref ratings
%         for i=1:4
%             [reg,regc]=createRegTS(find(tr==2 & choice_num==pref_idx(i)),1,nTRs,hrf, [regDir '/' pref_labels{i} '_img_cue.1D']);
%         end
%         
%         %%%%%%%%%%%%%%%%%%% choice onset by pref ratings
%         for i=1:4
%             [reg,regc]=createRegTS(find(tr==3 & choice_num==pref_idx(i)),1,nTRs,hrf, [regDir '/' pref_labels{i} '_choice_cue.1D']);
%         end
%         
        
        %%%%%%%%%% cue rt - model stick function w/RT as height at cue onset (tr=1)
        [reg,regc]=createRegTS(find(tr==1),cue_rt(tr==1),nTRs,hrf,[regDir '/cuert_cue.1D']);
        
        
        %%%%%%%%%% choice rt - model stick function w/RT as height at choice onset (tr=1)
        [reg,regc]=createRegTS(find(tr==3),choice_rt(tr==1),nTRs,hrf,[regDir '/choicert_cue.1D']);
        
        
        %%%%%%%%% whole-trial parametric regressor modulated by pref ratings
        pref=choice_num(find(tr==1 | tr==2 | tr==3 | tr==4));
        pref=pref-mean(pref);
        [reg,regc]=createRegTS(find(tr==1 | tr==2 | tr==3 | tr==4),pref,nTRs,hrf,[regDir '/pref_trial_cue.1D']);
        [reg,regc]=createRegTS(find(tr==1 | tr==2 | tr==3 | tr==4),1,nTRs,hrf,[regDir '/trial_cue.1D']);
        
        
%         %%%%%%%%% whole-trial parametric regressor modulated by pref by cond
%         for i=1:4
%             pref=choice_num(find(trial_type==i & (tr==1 | tr==2 | tr==3 | tr==4)));
%             pref=pref-mean(pref);
%             [reg,regc]=createRegTS(find(trial_type==i & (tr==1 | tr==2 | tr==3 | tr==4)),pref,nTRs,hrf,[regDir '/pref' conds{i} '_trial_cue.1D']);
%         end
%         
%         
%         %%%%%%%%%% whole-trial parametric regressor modulated by pa ratings
%         pa=getCueData(subjects{s},'pa_stim_trials');
%         if any(isnan(pa))
%             pa=choice_num(find(tr==1))';
%         end
%         pa=pa-nanmean(pa);
%         pa=reshape(repmat(pa,4,1),[],1);
%         pa(isnan(pa))=0;
%         [reg,regc]=createRegTS(find(tr==1 | tr==2 | tr==3 | tr==4),pa,nTRs,hrf,[regDir '/pa_trial_cue.1D']);
        
        
        
        %%%%%%%%%% whole-trial parametric regressor modulated by pa ratings by cond
%         for i=1:4
%             pa=getCueData(subjects{s},['pa_' conds{i} '_trials']);
%             if any(isnan(pa)) || var(pa)<.05
%                 pa=choice_num(find(trial_type==i & tr==1))';
%             end
%             pa=pa-mean(pa);
%             pa=reshape(repmat(pa,4,1),[],1);
%             [reg,regc]=createRegTS(find(trial_type==i & (tr==1 | tr==2 | tr==3 | tr==4)),pa,nTRs,hrf,[regDir '/pa' conds{i} '_trial_cue.1D']);
%         end
        
        
        
        %%%%%%%%%% whole-trial parametric regressor modulated by pa ratings
%         na=getCueData(subjects{s},'na_stim_trials');
%         if any(isnan(na))
%             na=choice_num(find(tr==1))'; na=na.*-1;
%         end
%         na=na-mean(na);
%         na=reshape(repmat(na,4,1),[],1);
%         [reg,regc]=createRegTS(find(tr==1 | tr==2 | tr==3 | tr==4),na,nTRs,hrf,[regDir '/na_trial_cue.1D']);
%         
%         
%         %%%%%%%%%% whole-trial parametric regressor modulated by na ratings by cond
%         for i=1:4
%             na=getCueData(subjects{s},['na_' conds{i} '_trials']);
%             if any(isnan(na))
%                 na=choice_num(find(trial_type==i & tr==1))'; na=na.*-1;
%             end
%             na=na-mean(na);
%             na=reshape(repmat(na,4,1),[],1);
%             [reg,regc]=createRegTS(find(trial_type==i & (tr==1 | tr==2 | tr==3 | tr==4)),na,nTRs,hrf,[regDir '/na' conds{i} '_trial_cue.1D']);
%         end
%         
%         
        
        %%%%%%%%%% whole-trial parametric regressor modulated by pa ratings for food and neutral trials only
%         pa=PA(s,qimage_type==3 | qimage_type==4)';
%         if any(isnan(pa))  || var(pa)<.05
%             pa=choice_num(find(tr==1 & (trial_type==3 | trial_type==4))');
%         end
%         pa=pa-nanmean(pa);
%         pa=reshape(repmat(pa,4,1),[],1);
%         pa(isnan(pa))=0;
%         [reg,regc]=createRegTS(find((trial_type==3 | trial_type==4) & (tr==1 | tr==2 | tr==3 | tr==4)),pa,nTRs,hrf,[regDir '/pafoodneutral_trial_cue.1D']);
        
        
        %%%%%%%%%% whole-trial parametric regressor modulated by pa ratings for drugs and alcohol trials only
%         pa=PA(s,qimage_type==1 | qimage_type==2)';
%         if any(isnan(pa))  || var(pa)<.05
%             pa=choice_num(find(tr==1 & (trial_type==1 | trial_type==2))');
%         end
%         pa=pa-nanmean(pa);
%         pa=reshape(repmat(pa,4,1),[],1);
%         pa(isnan(pa))=0;
%         [reg,regc]=createRegTS(find((trial_type==1 | trial_type==2) & (tr==1 | tr==2 | tr==3 | tr==4)),pa,nTRs,hrf,[regDir '/paalcoholdrugs_trial_cue.1D']);
        
        
%         %%%%%%%%%%%%%%%%%% model whole trial by alc/drugs & food/neutral
%         [reg,regc]=createRegTS(find((trial_type==1 | trial_type==2) & (tr==1 | tr==2 | tr==3 | tr==4)),1,nTRs,hrf,[regDir '/alcoholdrugs_trial_cue.1D']);
%         [reg,regc]=createRegTS(find((trial_type==3 | trial_type==4) & (tr==1 | tr==2 | tr==3 | tr==4)),1,nTRs,hrf,[regDir '/foodneutral_trial_cue.1D']);
%         
%         
%         %%%%%%%%%%%%%%%%%%% cue onset by trial type
%         for i=1:4
%             [reg,regc]=createRegTS(find(tr==1 & trial_type==i),1,nTRs,hrf,[regDir '/' conds{i} '_cue_cue.1D']);
%         end
%         
%         %%%%%%%%%%%%%%%%% cue onset for healthy food trials
%         [reg,regc]=createRegTS(find(tr==1 & strcmp(image_name,'Food_10.bmp')),1,nTRs,hrf,[regDir '/sushi_cue_cue.1D']);
%         [reg,regc]=createRegTS(find(tr==1 & strcmp(image_name,'Food_6.bmp')),1,nTRs,hrf,[regDir '/salad_cue_cue.1D']);
%         [reg,regc]=createRegTS(find(tr==1 & strcmp(image_name,'Food_17.bmp')),1,nTRs,hrf,[regDir '/fruit_cue_cue.1D']);
%         healthy_idx=[121 255 393];
%         [reg,regc]=createRegTS(healthy_idx,1,nTRs,hrf,[regDir '/healthyfood_cue_cue.1D']);
%         food_idx=find(tr==1 & trial_type==3);  food_idx(17)=[]; food_idx(10)=[]; food_idx(6)=[];
%         [reg,regc]=createRegTS(food_idx,1,nTRs,hrf,[regDir '/unhealthyfood_cue_cue.1D']);
%         
%         %%%%%%%%%%%%%%% cue onset for first and second half of trials (for reliability test)
%         for i=1:4
%             idx=find(tr==1 & trial_type==i);
%             [reg,regc]=createRegTS(idx(1:9),1,nTRs,hrf,[regDir '/' conds{i} '_firsthalf_cue_cue.1D']);
%             [reg,regc]=createRegTS(idx(10:end),1,nTRs,hrf,[regDir '/' conds{i} '_secondhalf_cue_cue.1D']);
%         end
        
%         %%%%%%%%%%%%%%%%%% model whole trial by type
%         for i=1:4
%             idx=find(trial_type==i & (tr==1 | tr==2 | tr==3 | tr==4));
%             [reg,regc]=createRegTS(idx(1:9),1,nTRs,hrf,[regDir '/' conds{i} '_firsthalf_trial_cue.1D']);
%             [reg,regc]=createRegTS(idx(10:end),1,nTRs,hrf,[regDir '/' conds{i} '_secondhalf_trial_cue.1D']);
%         end
%         
        
        
        
        fprintf(['\n\ndone with subject ' subject '.\n']);
        
    end
    
end % subjects



