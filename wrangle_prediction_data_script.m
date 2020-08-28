% script to wrangle data for prediction analyses for fmrieat project.

% idea is to wrangle all data of interest for these analyses here, and save
% them out into a single csv file.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTCOME VARIABLES:

%%%%%%% FOOD:

% change in BMI
% change in body fat percentage
% change in waist-to-hip ratio
% change in waist
% change in hip

%%%%%%% ALCOHOL:

% past 30 day changes in drinking measures (based on TLFB):
%     # of drinks
%     # of drinking episodes
%     # of drinks/# of episodes

% past 6 month changes in drinking (based on Alcohol Consumption questions on Qualtrics):
%    # of drinks in a typical week (in the past 6 months)
%    # of drinking episodes in a typical month (in the past 6 months)
%    # of drinks typically consumed in an episode (in the past 6 months)

% changes binge drinking (defined as 4+ drinks for women and 5+ drinks for men,
% based on 30-day TLFB)

% negative consequences experienced from alcohol consumption (based on X
% questionnaire on Qualtrics)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PREDICTORS OF INTEREST:

% BRAIN:
% VOI X beta cofficients in response to food, alcohol
% VOI X beta cofficients in response to food, alcohol - neutral
% VOI TRs 3-7 with respect to trial onset


% SELF-REPORT:
% PA ratings for food, alcohol stim
% " " minus neutral
% preference ratings for food, alcohol stim
% " " minus neutral
% BIS (from BIS/BAS)
% neuroticism (from TIPI 5)


% DEMOGRAPHICS:
% ethnicity
% gender
% SES



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CONTROL VARIABLES:

% body image (ideal-subjective ratings)
% dieting status
% weight-loss (or gain) goals
% Michaela's 1-item fitness question
% motivation to exercise (1-10 scale)
% 3-factor eating: cognitive restraint, uncontrolled eating, emotional eating
% special diet considerations
% # of hours of exercise
% college athelete? (1 or 0)
% eating disorders (past history)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define variables, get paths

clear all
close all

p=getFmrieatPaths;
subjects=getFmrieatSubjects('cue');

baseDir=p.baseDir;
dataDir = p.derivatives;

outPath = fullfile(dataDir,'prediction_data',['data_' datestr(now,'yymmdd') '.csv']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OUTCOME VARS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%% FOOD:

% change in BMI
% change in body fat percentage
% change in waist-to-hip ratio
% change in waist
% change in hip

%%%%%%%% baseline BMI
docid = '1PzIMd1k6cHbOc4Xbww4yQnfMjPog9XY2vPbebHYRJug'; % doc id for google sheet w/relapse data

colnames={'BMI','fat %','waist (cm)','hip (cm)'}; % column names for variables of interest
subjci=2; % which column to look for subject ids in

d = getGSSData(docid,colnames,subjects,subjci);

BMI_1=d(:,1);
fat_1=d(:,2);
waist_1=d(:,3);
hip_1=d(:,4);

clear d

%%%%%%%% followup BMI
docid = '1XZoXx4oioBbnCR2nQHnkNyoyX0PGnodqGuTZO3OIWsw'; % doc id for google sheet w/relapse data

colnames={'BMI w/ B height','fat %','waist (cm)','hip (cm)'};  % column names for variables of interest
subjci=2; % which column to look for subject ids in

d = getGSSData(docid,colnames,subjects,subjci);

BMI_2=d(:,1); BMI_2(BMI_2<1)=nan;
fat_2=d(:,2);
waist_2=d(:,3);
hip_2=d(:,4);

clear d

%%%%%%%% waist-to-hip ratio
w2hr_1=waist_1./hip_1;
w2hr_2=waist_2./hip_2;


%%%%%%% post-pre change
BMI_delta=(BMI_2-BMI_1)./BMI_1;
BMI_21=BMI_2-BMI_1;
% BMI_delta_sqrt=sqrt(BMI_delta);

fat_delta=(fat_2-fat_1)./fat_1;
waist_delta=(waist_2-waist_1)./waist_1;
hip_delta=(hip_2-hip_1)./hip_1;
w2hr_delta=(w2hr_2-w2hr_1);


% table that has all food outcome variables
Toutcomefoodvars = table(BMI_1,BMI_2,BMI_delta,BMI_21,...
    fat_1,fat_2,fat_delta,...
    waist_1,waist_2,waist_delta,...
    hip_1,hip_2,hip_delta,...
    w2hr_1,w2hr_2,w2hr_delta);


%% alcohol measures

%%%%%%%% 30 day measures

% past 30 day changes in drinking measures (based on TLFB):
%     # of drinks
%     # of drinking episodes
%     # drinks/episode

% changes binge drinking (defined as 4+ drinks for women and 5+ drinks for men,
% based on 30-day TLFB)

docid = '1tPA-d3tay33Oc1eIAVE0Fo10ELg1yiyMI9S7IlzfZ2c'; % doc id for google sheet

% column names for variables of interest
colnames={'B # Drinks (Past 30 D)',...
    'F # Drinks (Past 30 D)',...
    'B # Drinking Episodes (Past 30 D)',...
    'F # Drinking Episodes (Past 30 D)',...
    'B # Binge Drinking Episodes (Past 30 D)',...
    'F # Binge Drinking Episodes (Past 30 D)'};
subjci=2; % which column to look for subject ids in

d = getGSSData(docid,colnames,subjects,subjci);

ndrinks30d_1=d(:,1);
ndrinks30d_2=d(:,2);
nepisodes30d_1=d(:,3);
nepisodes30d_2=d(:,4);
nbinge30d_1=d(:,5);
nbinge30d_2=d(:,6);

% square root
ndrinks30d_1_sqrt=sqrt(d(:,1));
ndrinks30d_2_sqrt=sqrt(d(:,2));
nepisodes30d_1_sqrt=sqrt(d(:,3));
nepisodes30d_2_sqrt=sqrt(d(:,4));
nbinge30d_1_sqrt=sqrt(d(:,5));
nbinge30d_2_sqrt=sqrt(d(:,6));


% log-transformed
ndrinks30d_1_ln=log(d(:,1)+1);
ndrinks30d_2_ln=log(d(:,2)+1);
nepisodes30d_1_ln=log(d(:,3)+1);
nepisodes30d_2_ln=log(d(:,4)+1);
nbinge30d_1_ln=log(d(:,5)+1);
nbinge30d_2_ln=log(d(:,6)+1);


clear d

%%%%%%% post-pre change
ndrinks30d_delta=ndrinks30d_2-ndrinks30d_1;
nepisodes30d_delta=nepisodes30d_2-nepisodes30d_1;
nbinge30d_delta=nbinge30d_2-nbinge30d_1;

% table that has 30-day alcohol outcome variables
% Toutcomealc30dvars = table(ndrinks30d_1,ndrinks30d_2,ndrinks30d_delta,...
%     nepisodes30d_1,nepisodes30d_2,nepisodes30d_delta,...
%     nbinge30d_1,nbinge30d_2,nbinge30d_delta);

% table that has 30-day alcohol outcome variables
Toutcomealc30dvars = table(ndrinks30d_1,ndrinks30d_2,ndrinks30d_delta,...
    nepisodes30d_1,nepisodes30d_2,nepisodes30d_delta,...
    nbinge30d_1,nbinge30d_2,nbinge30d_delta,...
    ndrinks30d_1_ln,ndrinks30d_2_ln,nepisodes30d_1_ln,nepisodes30d_2_ln,nbinge30d_1_ln,nbinge30d_2_ln,...
    ndrinks30d_1_sqrt,ndrinks30d_2_sqrt,nepisodes30d_1_sqrt,nepisodes30d_2_sqrt,nbinge30d_1_sqrt,nbinge30d_2_sqrt);


%%%%%%%% 6 month measures

% past 6 month changes in drinking (based on Alcohol Consumption questions on Qualtrics):
%    # of drinks in a typical week (in the past 6 months)
%    # of drinking episodes in a typical month (in the past 6 months)
%    # of drinks typically consumed in an episode (in the past 6 months)

% negative consequences experienced from alcohol consumption (based on X
% questionnaire on Qualtrics)

%%%%%%%%
docid1 = '1E0bmGIt_2PwCO6RxdMVG9eR0SCQeVgBPuHR87s9kkMc'; % doc id for google sheet for BASELINE
docid2 = '1qo1-FZcauGImZJgKth6-2XradwdwuUKiiObO0RwQFQY'; % doc id for google sheet for FOLLOWUP

% column names for variables of interest
colnames={'Averaging over the past 6 months, how many times in a TYPICAL month do you drink ALCOHOL?',...
    'Averaging over the past 6 months, how many drinks do you have in a TYPICAL WEEK?',...
    'Averaging over the past 6 months, how many drinks do you TYPICALLY have at ONE TIME?',...
    'RAPI: Total neg consequences experienced - Past 6m'};

subjci=1; % which column to look for subject ids in

d = getGSSData(docid1,colnames,subjects,subjci); % baseline

nepisodespermonth6m_1=d(:,1);
ndrinksperweek6m_1=d(:,2);
ndrinksperepisode6m_1=d(:,3);
negconsequences6m_1=d(:,4);

clear d

d = getGSSData(docid2,colnames,subjects,subjci); % followup

nepisodespermonth6m_2=d(:,1);
ndrinksperweek6m_2=d(:,2);
ndrinksperepisode6m_2=d(:,3);
negconsequences6m_2=d(:,4);

clear d


%%%%%%% post-pre change
nepisodespermonth6m_delta=nepisodespermonth6m_2-nepisodespermonth6m_1;
ndrinksperweek6m_delta=ndrinksperweek6m_2-ndrinksperweek6m_1;
ndrinksperepisode6m_delta=ndrinksperepisode6m_2-ndrinksperepisode6m_1;
negconsequences6m_delta=negconsequences6m_2-negconsequences6m_1;

% table that has 30-day alcohol outcome variables
Toutcomealc6mvars = table(nepisodespermonth6m_1,nepisodespermonth6m_2,nepisodespermonth6m_delta,...
    ndrinksperweek6m_1,ndrinksperweek6m_2,ndrinksperweek6m_delta,...
    ndrinksperepisode6m_1,ndrinksperepisode6m_2,ndrinksperepisode6m_delta,...
    negconsequences6m_1,negconsequences6m_2,negconsequences6m_delta);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PREDICTORS OF INTEREST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BRAIN:
% VOI X beta cofficients in response to food, alcohol
% VOI X beta cofficients in response to food, alcohol - neutral
% VOI TRs 3-7 with respect to trial onset


%% brain data


bd = [];  % array of brain data values
bdNames = {};  % brain data predictor names


% roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai','caudate','dlpfc_sarahj','dlpfcL_sarahj','dlpfcR_sarahj'};
% roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acc','ains','caudate','dlpfc','dlpfcL','dlpfcR'};
roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai','caudate'};
roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acc','ains','caudate'};

stims = {'alcohol','drugs','food','neutral'};
% stims = {'alcohol','drugs','food','neutral'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%  ROI TRs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tcPath = fullfile(dataDir,['timecourses_cue_woOutliers'],'%s','%s.csv'); %s is roiNames, stims
% % tcPath = fullfile(dataDir,['timecourses_' task '_woOutliers'],'%s','%s.csv'); %s is roiNames, stims
%
TRs = [3:7];
% aveTRs = [3:5]; % ***this is an index of var TRs**, so the mean will be taken of TRs(aveTRs)
aveTRs = [];
%
for j=1:numel(roiNames)
    
    for k = 1:numel(stims)
        
        % if there's a minus sign, assume desired output is stim1-stim2
        if strfind(stims{k},'-')
            stim1 = stims{k}(1:strfind(stims{k},'-')-1);
            stim2 = stims{k}(strfind(stims{k},'-')+1:end);
            tcfile1=sprintf(tcPath,roiNames{j},stim1);
            tcfile2=sprintf(tcPath,roiNames{j},stim2);
            thistc1=loadRoiTimeCourses(tcfile1,subjects,TRs);
            thistc2=loadRoiTimeCourses(tcfile2,subjects,TRs);
            thistc=thistc1-thistc2;
            
            
            % otherwise just load stim timecourses
        else
            tcfile=sprintf(tcPath,roiNames{j},stims{k});
            thistc=loadRoiTimeCourses(tcfile,subjects,TRs);
            
        end
        bd = [bd thistc];
        
        % update var names
        for ti = 1:numel(TRs)
            bdNames{end+1} = [roiVarNames{j} '_' strrep(stims{k},'-','') '_TR' num2str(TRs(ti))];
        end
        
        % if averaging over TRs is desired, include it
        if ~isempty(aveTRs)
            bd = [bd mean(thistc(:,aveTRs),2)];
            bdNames{end+1} = [roiVarNames{j} '_' strrep(stims{k},'-','') '_TR' strrep(num2str(TRs(aveTRs)),' ','') 'mean'];
        end
        
    end % stims
    
end % rois


%%%%%%%%%%%%%%%%%%%%%%%%%%%  ROI BETAS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai','caudate','singlevox322424','gust8mm_Porubska','gust8mm_Simmons','gust8mm_Simon','gust8mm_Veldhuizen'};
roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acc','ains','caudate','singlevox','gust8mm_Porubska','gust8mm_Simmons','gust8mm_Simon','gust8mm_Veldhuizen'};

stims = {'alcohol','drugs','food','neutral','alcohol-neutral','food-neutral'};
% stims = {'alcohol','drugs','food','neutral'};

betaPath = fullfile(dataDir,['results_cue'],'roi_betas','%s','%s.csv'); %s is roiName, stim

for j=1:numel(roiNames)
    
    for k = 1:numel(stims)
        
        % if there's a minus sign, assume desired output is stim1-stim2
        if strfind(stims{k},'-')
            stim1 = stims{k}(1:strfind(stims{k},'-')-1);
            stim2 = stims{k}(strfind(stims{k},'-')+1:end);
            B1=loadRoiTimeCourses(sprintf(betaPath,roiNames{j},stim1),subjects);
            B2=loadRoiTimeCourses(sprintf(betaPath,roiNames{j},stim2),subjects);
            B=B1-B2;
            
            % otherwise just load stim betas
        else
            this_bfile = sprintf(betaPath,roiNames{j},stims{k}); % this beta file path
            B = loadRoiTimeCourses(this_bfile,subjects);
            
        end
        
        bd = [bd B];
        bdNames = [bdNames [roiVarNames{j} '_' strrep(stims{k},'-','') '_beta']];
        
        
    end % stims
    
end % roiNames


%%%%%%%%%%%%%%%%%%  ROI SELFREPORT X BRAIN BETAS  %%%%%%%%%%%%%%%%%%%%%%%%%

roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai','caudate'};
roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acc','ains','caudate'};

stims = {'pa','pa_v2','na','pref'};

betaPath = fullfile(dataDir,['results_cue'],'roi_betas','%s','%s.csv'); %s is roiName, stim

for j=1:numel(roiNames)
    
    for k = 1:numel(stims)
        
        % if there's a minus sign, assume desired output is stim1-stim2
        if strfind(stims{k},'-')
            stim1 = stims{k}(1:strfind(stims{k},'-')-1);
            stim2 = stims{k}(strfind(stims{k},'-')+1:end);
            B1=loadRoiTimeCourses(sprintf(betaPath,roiNames{j},stim1),subjects);
            B2=loadRoiTimeCourses(sprintf(betaPath,roiNames{j},stim2),subjects);
            B=B1-B2;
            
            % otherwise just load stim betas
        else
            this_bfile = sprintf(betaPath,roiNames{j},stims{k}); % this beta file path
            B = loadRoiTimeCourses(this_bfile,subjects);
            
        end
        
        bd = [bd B];
        bdNames = [bdNames [roiVarNames{j} '_' strrep(stims{k},'-','') '_beta']];
        
        
    end % stims
    
end % roiNames


% brain data
Tbrain = array2table(bd,'VariableNames',bdNames);


%% SELF-REPORT

% PA ratings for food, alcohol stim
% " " minus neutral

[valence, arousal, pa, na, familiarity, image_types] = getQualtricsData(subjects);
conds = {'alcohol','drugs','food','neutral'};

for j=1:numel(conds)
    condpa(:,j) = nanmean(pa(:,image_types==j),2);
    condna(:,j) = nanmean(na(:,image_types==j),2);
    condfamil(:,j) = nanmean(familiarity(:,image_types==j),2);
end

varnames=[cellfun(@(x) ['pa_' x ], conds,'uniformoutput',0) cellfun(@(x) ['na_' x ], conds,'uniformoutput',0) cellfun(@(x) ['familiarity_' x ], conds,'uniformoutput',0)];
Tratings = array2table([condpa condna condfamil],'VariableNames',varnames);


% preference ratings for food, alcohol stim
fp=fullfile(baseDir,'source','%s','behavior','cue_matrix.csv'); % filepath
fpc = cellfun(@(x) sprintf(fp,x), subjects, 'uniformoutput',0); % filepath as cell array w/subject ids
[trial,tr,starttime,clock,trial_onset,trial_type,cue_rt,choice,choice_num,...
    choice_type,choice_rt,iti,drift,image_name]=cellfun(@(x) getCueTaskBehData(x,'short'), fpc, 'uniformoutput',0);
ci = trial_type{1}; % condition trial index (should be the same for every subject)

% get mean pref ratings by condition w/subjects in rows
pref = cell2mat(choice_num')'; % subjects x items pref ratings
mean_pref = [];
for j=1:numel(conds) % # of conds
    mean_pref(:,j) = nanmean(pref(:,ci==j),2);
end
varnames=cellfun(@(x) ['pref_' x ], conds,'uniformoutput',0);
Tpref = array2table(mean_pref,'VariableNames',varnames);



%% BIS (from BIS/BAS)

docid = '1Ra-JM2JyLnqYyFnfnwr8mTrcesAG94tz-REDeCNMaG8'; % doc id for google sheet

colnames = {'BIS','BASDrive','BASFunSeeking','BASRewardResponse'}; % column names for variables of interest
subjci=1; % which column to look for subject ids in

d = getGSSData(docid,colnames,subjects,subjci);

BIS_BISBAS=d(:,1);
BASDrive=d(:,2);
BASFunSeeking=d(:,3);
BASRewardResponse=d(:,4);

Tbisbas = table(BIS_BISBAS,BASDrive,BASFunSeeking,BASRewardResponse);


%% demographics


docid = '1fBiZ8TGVOuH9W9i16wnjG1Pcuu7Md1LgkPkq8I48b_s'; % doc id for google sheet

colnames = {'Sex','Community subj status'};
subjci=1; % which column to look for subject ids in

d = getGSSData(docid,colnames,subjects,subjci);

sex=d(:,1);
comm_status= d(:,2);

Tdemo = table(sex,comm_status);

%% alexithymia

%%%%%%%%  TAS score
docid = '1EnopBGes6n_TyFvGKjd6GxJHoPjbIajHh5QEOBrA4RY'; % doc id for google sheet w/relapse data

colnames={'TAS Total'};  % column names for variables of interest
subjci=1; % which column to look for subject ids in

d = getGSSData(docid,colnames,subjects,subjci);

tas=d;

clear d

Ttas=table(tas);


%% more to variables to add:

% neuroticism (from TIPI 5)


% DEMOGRAPHICS:
% ethnicity
% ??

% CONTROL VARIABLES:

% body image (ideal-subjective ratings)
% dieting status
% weight-loss (or gain) goals
% Michaela's 1-item fitness question
% motivation to exercise (1-10 scale)
% 3-factor eating: cognitive restraint, uncontrolled eating, emotional eating
% special diet considerations
% # of hours of exercise
% college athelete? (1 or 0)
% eating disorders (past history)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% concatenate all variables into 1 table


% subject ids
Tsubj = table(subjects);


% concatenate all data into 1 table
T=table();
% T = [Tsubj Trelapse Tdem Tbeh Tbrain Totherdruguse];
T = [Tsubj Toutcomefoodvars Toutcomealc30dvars Toutcomealc6mvars Tdemo Tbisbas Tratings Tpref Tbrain Ttas];

% save out
writetable(T,outPath);

% done














