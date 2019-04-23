
clear all
close all


p=getFmrieatPaths;

dataDir = p.derivatives; 

subjects=getFmrieatSubjects('cue');


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
% qualtricsfilepath = [dataDir '/qualtrics_data/Post_Scan_Survey_180319.csv'];

hrf = 'waver'; % choices are spm or 'waver'

pafilepath = fullfile(dataDir,'PANAratings','pa.csv');

%%

% [qd,PA,NA,famil,qimage_type]=getQualtricsData(qualtricsfilepath,subjects);

PA = readtable(pafilepath);

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
        
        
        
        %%%%%%%%% whole-trial parametric regressor modulated by pref ratings
        pref=choice_num(find(tr==1 | tr==2 | tr==3 | tr==4));
        pref=pref-mean(pref);
        [reg,regc]=createRegTS(find(tr==1 | tr==2 | tr==3 | tr==4),pref,nTRs,hrf,[regDir '/pref_trial_cue.1D']);
        [reg,regc]=createRegTS(find(tr==1 | tr==2 | tr==3 | tr==4),1,nTRs,hrf,[regDir '/trial_cue.1D']);
        
        
        %%%%%%%%% whole-trial parametric regressor modulated by pref by cond
        for i=1:4
            pref=choice_num(find(trial_type==i & (tr==1 | tr==2 | tr==3 | tr==4)));
            pref=pref-mean(pref);
            [reg,regc]=createRegTS(find(trial_type==i & (tr==1 | tr==2 | tr==3 | tr==4)),pref,nTRs,hrf,[regDir '/pref' conds{i} '_trial_cue.1D']);
        end
        
        
        %%%%%%%%%% whole-trial parametric regressor modulated by pa ratings
        idx=find(strcmp(PA.subjects,subjects{s}));
        pa=table2array(PA(idx,2:end));
        if any(isnan(pa))
            pa=choice_num(find(tr==1))';
        end
        pa=pa-nanmean(pa);
        pa=reshape(repmat(pa,4,1),[],1);
        pa(isnan(pa))=0;
        [reg,regc]=createRegTS(find(tr==1 | tr==2 | tr==3 | tr==4),pa,nTRs,hrf,[regDir '/pa_trial_cue.1D']);
        
        
        
        %%%%%%%%% whole-trial parametric regressor modulated by pa ratings by cond
        for i=1:4
            pa=table2array(PA(idx,find([trial_type(tr==1)==i]')+1));
            if any(isnan(pa))
                pa=choice_num(find(trial_type==i & tr==1))';
            end
            if var(pa)>.1  
                pa=pa-mean(pa);
                pa=reshape(repmat(pa,4,1),[],1);
                [reg,regc]=createRegTS(find(trial_type==i & (tr==1 | tr==2 | tr==3 | tr==4)),pa,nTRs,hrf,[regDir '/pa' conds{i} '_trial_cue.1D']);
            end
        end
        
        
        
        

        fprintf(['\n\ndone with subject ' subject '.\n']);
        
    end
    
end % subjects



