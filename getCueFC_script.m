% is reduced FA in MFB a sign of reduced coherence?

% supporting evidence for this view would be if functional connectivity
% between NAcc and VTA was positively correlated with FA. This would
% suggest that lower FA > less functional communication between VTA and
% NAcc


%

clear all
close all

%% define initial stuff


p=getFmrieatPaths;
task='cue';
subjects=getFmrieatSubjects(task);

dataDir = p.derivatives;

Xbasefname=['pp_' task '_tlrc_nuisance_designmat.txt'];

seed = 'vta';
seedtsfname=[task '_' seed '_ts.1D']; % seed ROI time series

target = 'nacc';
targettsfname=[task '_' target '_ts.1D']; % time series for target ROI

% conds = {'gain5','gain0','gainwin','gainmiss'}; % conditions to contrast
% conds = {'gainwin','gainmiss'}; % conditions to contrast
conds = {'alcohol','drugs','food','neutral'}; % conditions to contrast

regfileStr=fullfile(dataDir,'%s','regs',['%s_trial_' task '.1D']); %s is subject, conds

censorTRs=1; % 1 to censor out bad motion TRs, otherwise 0

censorFilePath = fullfile(dataDir, '%s','func_proc',[task '_censor.1D']);

TR=2;

fcTRs=[1:8]; % which TRs to use for func connectivity calculation?

% This should be relative to trial onset, e.g., TRs=[3 4]

% filepath for saving out table of variables
outDir=fullfile(dataDir,'funcconn_measures');
if ~exist(outDir,'dir')
    mkdir(outDir);
end

if ~censorTRs
    outPath = fullfile(outDir,[task '_' seed '_' target '_funcconn.csv']);
else
    outPath = fullfile(outDir,[task '_' seed '_' target '_censoredTRs_funcconn.csv']);
end

%% do it

cd(dataDir);

for s=1:numel(subjects)
    
    subject=subjects{s};
    
    cd(subject); cd func_proc;
    
    % load baseline model that includes all baseline regs
    Xbase=readtable(sprintf(Xbasefname,subject));
    baseNames = Xbase.Properties.VariableNames;
    Xbase=table2array(Xbase);
    
    seedts=dlmread(seedtsfname);
    targetts=dlmread(targettsfname);
    
    % regress out baseline regs
    seed_errts=glm_fmri_fit(seedts,Xbase,[],'err_ts');
    target_errts=glm_fmri_fit(targetts,Xbase,[],'err_ts');
    
    % if censoring TRs, set censored TRs to nan
    if censorTRs
        censorVols = find(dlmread(sprintf(censorFilePath,subject))==0);
        seedts(censorVols)=nan; seed_errts(censorVols)=nan;
        targetts(censorVols)=nan; target_errts(censorVols)=nan;
    end
    
    % method 1: straight up correlation
    r_restingstate(s,1)=nancorr(seedts,targetts);
    
    % method 2: correlation, partialling out nuisance regs
    %         note: this returns the same r as doing
    %         partialcorr(targets,seedts,Xbase), but nancorr() can handle nan
    %         values
    r_restingstate_partial(s,1)=nancorr(seed_errts,target_errts);
    
    
    %% contrast functional connectivity between gain5 vs gain0 trials
    
    for j=1:numel(conds)
        
        onsetTRs=find(dlmread(sprintf(regfileStr,subject,conds{j})));
        
        TRs=repmat(onsetTRs,1,fcTRs(end))+repmat(0:fcTRs(end)-1,size(onsetTRs,1),1);
        TRs=TRs(:,fcTRs);
        
        if ~censorTRs
            
            % correlation between seed and target during cond{j}
            r_cond{j}(s,:)=diag(corr(seedts(TRs),targetts(TRs)));
            
            % also do it on data with nuisance regs regressed out
            r_cond_partial{j}(s,:)=diag(corr(seed_errts(TRs),target_errts(TRs)));
            
        else
            
            % if censorVols, have to do this the slower way with a loop:
            for k=1:numel(fcTRs)
                r_cond{j}(s,k)=nancorr(seedts(TRs(:,k)),targetts(TRs(:,k)));
                r_cond_partial{j}(s,k)=nancorr(seed_errts(TRs(:,k)),target_errts(TRs(:,k)));
            end
            
        end % if censor TRs
        
        %% QA checks
        
        % keep track of the number of trials per cond for each subj
        ntrials(s,j)=numel(onsetTRs);
        
        % keep track of mean timecourses for each condition for subjects;
        % this can be used as a QA check to make sure the main effect data
        % looks as predicted
        d_cond_seed{j}(s,:)=nanmean(seedts(TRs));
        d_cond_target{j}(s,:)=nanmean(targetts(TRs));
            
    end % cond loop
    
    cd(dataDir);
    
end % subject loop


%% save everything out into a table

% first get variable names
varnames = {};
for j=1:numel(conds)
    for ti = 1:numel(fcTRs)
        varnames{end+1} = [conds{j} '_TR' num2str(fcTRs(ti))];
    end
end

for j=1:numel(conds)
    for ti = 1:numel(fcTRs)
        varnames{end+1} = ['partial_' conds{j} '_TR' num2str(fcTRs(ti))];
    end
end

% now put condition func conn data into a table
Ttask = array2table([r_cond{:} r_cond_partial{:}],'VariableNames',varnames);

% resting state func conn in a table
Trestingstate= array2table([r_restingstate r_restingstate_partial],'VariableNames',{'wholescan','partial_wholescan'});

subjid = cell2mat(subjects);
Tsubj = table(subjid);
Tgroupindex=table(gi);

% concatenate all data into 1 table
T=table();
T = [Tsubj Tgroupindex Ttask Trestingstate];
% T = [Tsubj Tgroupindex Tvars Tdti Tcontrollingagemotion];

% save out
writetable(T,outPath);





