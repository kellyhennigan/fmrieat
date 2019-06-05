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

% baseline BMI, % fat, waist and hip measures

%%%%%%%% baseline BMI
docid = '1PzIMd1k6cHbOc4Xbww4yQnfMjPog9XY2vPbebHYRJug'; % doc id for google sheet w/relapse data

% try to load data from google spreadsheet
try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'Using offline values that may not be the most updated...'])
    d={}; % ADD OFFLINE VALS HERE...
end


% if data is loaded, compute scores
if isempty(d)
    BMI1 = [];
    fat1 = [];
    waist1 = [];
    hip1 = [];
else
    ciBMI = find(strcmp(d(1,:),'BMI')); % column with BMI scores
    cifat = find(strcmp(d(1,:),'fat %')); % column with BMI scores
    ciwaist = find(strcmp(d(1,:),'waist (cm)')); % column with BMI scores
    cihip = find(strcmp(d(1,:),'hip (cm)')); % column with BMI scores
    
    for i=1:numel(subjects)
        idx=find(strncmp(d(:,2),subjects{i},numel(subjects{i}))); % find row index for this subject
        if isempty(idx)
            BMI1(i,1) = nan;
            fat1(i,1) = nan;
            waist1(i,1) = nan;
            hip1(i,1) = nan;
        else
            BMI1(i,1) = str2double(d{idx,ciBMI});
            fat1(i,1) = str2double(d{idx,cifat});
            waist1(i,1) = str2double(d{idx,ciwaist});
            hip1(i,1) = str2double(d{idx,cihip});
        end
    end
end

%%%%%%%% followup BMI
docid = '1XZoXx4oioBbnCR2nQHnkNyoyX0PGnodqGuTZO3OIWsw'; % doc id for google sheet w/relapse data

% try to load data from google spreadsheet
try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'Using offline values that may not be the most updated...'])
    d={}; % ADD OFFLINE VALS HERE...
end


% if data is loaded, compute scores
if isempty(d)
    BMI2 = [];
    fat2 = [];
    waist2 = [];
    hip2 = [];
else
    ciBMI = find(strcmp(d(1,:),'BMI w/ B height')); % column with BMI scores
    cifat = find(strcmp(d(1,:),'fat %')); % column with BMI scores
    ciwaist = find(strcmp(d(1,:),'waist (cm)')); % column with BMI scores
    cihip = find(strcmp(d(1,:),'hip (cm)')); % column with BMI scores
    
    for i=1:numel(subjects)
        idx=find(strncmp(d(:,2),subjects{i},numel(subjects{i}))); % find row index for this subject
        if isempty(idx)
            BMI2(i,1) = nan;
            fat2(i,1) = nan;
            waist2(i,1) = nan;
            hip2(i,1) = nan;
        else
            BMI2(i,1) = str2double(d{idx,ciBMI});
            fat2(i,1) = str2double(d{idx,cifat});
            waist2(i,1) = str2double(d{idx,ciwaist});
            hip2(i,1) = str2double(d{idx,cihip});
        end
    end
end


w2hr1=waist1./hip1;
w2hr2=waist2./hip2;
deltaBMI=BMI2-BMI1;
deltafat=fat2-fat1;
deltawaist=waist2-waist1;
deltahip=hip2-hip1;
deltaw2hr=w2hr2-w2hr1;

Toutcomefoodvars = table(BMI1,BMI2,deltaBMI,fat1,fat2,deltafat,...
    waist1,waist2,deltawaist,hip1,hip2,deltahip,w2hr1,w2hr2,deltaw2hr);



%% alcohol measures


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

%%%%%%%%
docid = '1tPA-d3tay33Oc1eIAVE0Fo10ELg1yiyMI9S7IlzfZ2c'; % doc id for google sheet

% try to load data from google spreadsheet
try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'Using offline values that may not be the most updated...'])
    d={}; % ADD OFFLINE VALS HERE...
end


% if data is loaded, compute scores
if isempty(d)
    ndrinks30d_1=[];
    nepisodes30d_1=[];
    ndrinks30d_2=[];
    nepisodes30d_2=[];
    nbinge30d_1=[];
    nbinge30d_2=[];
    
else
    ciNdrinks1 = find(strcmp(d(1,:),'B # Drinks (Past 30 D)')); % column with BMI scores
    ciNdrinks2 = find(strcmp(d(1,:),'F # Drinks (Past 30 D)')); % column with BMI scores
    ciNepisodes1 = find(strcmp(d(1,:),'B # Drinking Episodes (Past 30 D)')); % column with BMI scores
    ciNepisodes2 = find(strcmp(d(1,:),'F # Drinking Episodes (Past 30 D)')); % column with BMI scores
    ciBinge1 = find(strcmp(d(1,:),'B # Binge Drinking Episodes (Past 30 D)')); % column with BMI scores
    ciBinge2 = find(strcmp(d(1,:),'F # Binge Drinking Episodes (Past 30 D)')); % column with BMI scores
    
    for i=1:numel(subjects)
        idx=find(strncmp(d(:,2),subjects{i},numel(subjects{i}))); % find row index for this subject
        if isempty(idx)
            ndrinks30d_1(i,1)=nan;
            nepisodes30d_1(i,1)=nan;
            ndrinks30d_2(i,1)=nan;
            nepisodes30d_2(i,1)=nan;
            nbinge30d_1(i,1)=nan;
            nbinge30d_2(i,1)=nan;
        else
            ndrinks30d_1(i,1) = str2double(d{idx,ciNdrinks1});
            ndrinks30d_2(i,1) = str2double(d{idx,ciNdrinks2});
            nepisodes30d_1(i,1) = str2double(d{idx,ciNepisodes1});
            nepisodes30d_2(i,1) = str2double(d{idx,ciNepisodes2});
            nbinge30d_1(i,1) = str2double(d{idx,ciBinge1});
            nbinge30d_2(i,1) = str2double(d{idx,ciBinge2});
        end
    end
end


deltandrinks30d=ndrinks30d_2-ndrinks30d_1;
deltanepisodes30d=nepisodes30d_2-nepisodes30d_1;
deltanbinge30d=nbinge30d_2-nbinge30d_1;

Toutcomealc30dvars = table(ndrinks30d_1,ndrinks30d_2,deltandrinks30d,...
    nepisodes30d_1,nepisodes30d_2,deltanepisodes30d,...
    nbinge30d_1,nbinge30d_2,deltanbinge30d);
    

%%%%% qualtrics alc

%%%%%%%%
docid = '1E0bmGIt_2PwCO6RxdMVG9eR0SCQeVgBPuHR87s9kkMc'; % doc id for google sheet

% try to load data from google spreadsheet
try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'Using offline values that may not be the most updated...'])
    d={}; % ADD OFFLINE VALS HERE...
end


% if data is loaded, compute scores
if isempty(d)
    
    nepisodespermonth6m_1=[];
    ndrinksperweek6m_1=[];
    ndrinksperepisode6m_1=[];
    nNegConsequences6m_1=[];
    
else
    ciNepisodes = find(strcmp(d(1,:),'Averaging over the past 6 months, how many times in a TYPICAL month do you drink ALCOHOL?')); % column with BMI scores
    ciNdrinks = find(strcmp(d(1,:),'Averaging over the past 6 months, how many drinks do you have in a TYPICAL WEEK?')); % column with BMI scores
    cidrinksperep = find(strcmp(d(1,:),'Averaging over the past 6 months, how many drinks do you TYPICALLY have at ONE TIME?'));
    cinegcon = find(strcmp(d(1,:),'Total neg consequences experienced - Past 6m'));
    
    for i=1:numel(subjects)
        idx=find(strncmp(d(:,1),subjects{i},numel(subjects{i}))); % find row index for this subject
        if isempty(idx)
            
            nepisodespermonth6m_1(i,1)=nan;
            ndrinksperweek6m_1(i,1)=nan;
            ndrinksperepisode6m_1(i,1)=nan;
            nNegConsequences6m_1(i,1)=nan;
            
        else
            
            nepisodespermonth6m_1(i,1)=str2double(d{idx,ciNepisodes});
            ndrinksperweek6m_1(i,1)=str2double(d{idx,ciNdrinks});
            ndrinksperepisode6m_1(i,1)=str2double(d{idx,cidrinksperep});
            nNegConsequences6m_1(i,1)=str2double(d{idx,cinegcon});
            
        end
    end
end



%%%%%% followup

%%%%%%%%
docid = '1qo1-FZcauGImZJgKth6-2XradwdwuUKiiObO0RwQFQY'; % doc id for google sheet

% try to load data from google spreadsheet
try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'Using offline values that may not be the most updated...'])
    d={}; % ADD OFFLINE VALS HERE...
end


% if data is loaded, compute scores
if isempty(d)
    
    nepisodespermonth6m_2=[];
    ndrinksperweek6m_2=[];
    ndrinksperepisode6m_2=[];
    nNegConsequences6m_2=[];
    
else
    ciNepisodes = find(strcmp(d(1,:),'Averaging over the past 6 months, how many times in a TYPICAL month do you drink ALCOHOL?')); % column with BMI scores
    ciNdrinks = find(strcmp(d(1,:),'Averaging over the past 6 months, how many drinks do you have in a TYPICAL WEEK?')); % column with BMI scores
    cidrinksperep = find(strcmp(d(1,:),'Averaging over the past 6 months, how many drinks do you TYPICALLY have at ONE TIME?'));
    cinegcon = find(strcmp(d(1,:),'Total neg consequences experienced - Past 6m'));
    
    for i=1:numel(subjects)
        idx=find(strncmp(d(:,1),subjects{i},numel(subjects{i}))); % find row index for this subject
        if isempty(idx)
            
            nepisodespermonth6m_2(i,1)=nan;
            ndrinksperweek6m_2(i,1)=nan;
            ndrinksperepisode6m_2(i,1)=nan;
            nNegConsequences6m_2(i,1)=nan;
            
        else
            
            nepisodespermonth6m_2(i,1)=str2double(d{idx,ciNepisodes});
            ndrinksperweek6m_2(i,1)=str2double(d{idx,ciNdrinks});
            ndrinksperepisode6m_2(i,1)=str2double(d{idx,cidrinksperep});
            nNegConsequences6m_2(i,1)=str2double(d{idx,cinegcon});
            
        end
    end
end

deltanepisodesermonth6m=nepisodespermonth6m_2-nepisodespermonth6m_1;
deltandrinksperweek6m=ndrinksperweek6m_2-ndrinksperweek6m_1;
deltandrinksperepisode6m=deltandrinksperepisode6m_2-deltandrinksperepisode6m_1;
deltanNegConsequences6m=nNegConsequences6m_2-nNegConsequences6m_1;

Toutcomealc6mvars = table(nepisodespermonth6m_2,nepisodespermonth6m_1,deltanepisodesermonth6m,...
    ndrinksperweek6m_2,ndrinksperweek6m_1,deltandrinksperweek6m,...
    deltandrinksperepisode6m_2,deltandrinksperepisode6m_1,deltandrinksperepisode6m,...
    nNegConsequences6m_2,nNegConsequences6m_1,deltanNegConsequences6m);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PREDICTORS OF INTEREST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BRAIN:
% VOI X beta cofficients in response to food, alcohol
% VOI X beta cofficients in response to food, alcohol - neutral
% VOI TRs 3-7 with respect to trial onset


%% brain data


roiNames = {'nacc_desai','naccL_desai','naccR_desai','mpfc','VTA','acing','ins_desai','caudate'};
roiVarNames = {'nacc','naccL','naccR','mpfc','vta','acc','ains','caudate'};


% stims = {'drugs','food','neutral','drugs-neutral','drugs-food'};
stims = {'alcohol','drugs','food','neutral'};


bd = [];  % array of brain data values
bdNames = {};  % brain data predictor names


%%%%%%%%%%%%%%%%%%%%%%%%%%%  ROI TRs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tcPath = fullfile(dataDir,['timecourses_' task ],'%s','%s.csv'); %s is roiNames, stims
% % tcPath = fullfile(dataDir,['timecourses_' task '_woOutliers'],'%s','%s.csv'); %s is roiNames, stims
% 
TRs = [3:7];
aveTRs = [3:5]; % ***this is an index of var TRs**, so the mean will be taken of TRs(aveTRs)
% 
for j=1:numel(roiNames)
         
    for k = 1:numel(stims)
        
        % if there's a minus sign, assume desired output is stim1-stim2
        if strfind(stims{k},'-')
            stim1 = stims{k}(1:strfind(stims{k},'-')-1);
            stim2 = stims{k}(strfind(stims{k},'-')+1:end);
            thistc1=loadRoiTimeCourses(sprintf(tcPath,roiNames{j},stim1),subjects,TRs);
            thistc2=loadRoiTimeCourses(sprintf(tcPath,roiNames{j},stim2),subjects,TRs);
            thistc=thistc1-thistc2;
        
        % otherwise just load stim timecourses
        else
            thistc=loadRoiTimeCourses(sprintf(tcPath,roiNames{j},stims{k}),subjects,TRs);
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
 
betaPath = fullfile(dataDir,['results_' task],'roi_betas','%s','%s.csv'); %s is roiName, stim

for j=1:numel(roiNames)

      for k = 1:numel(stims)
          
          this_bfile = sprintf(betaPath,roiNames{j},stims{k}); % this beta file path
          if exist(this_bfile,'file')
              B = loadRoiTimeCourses(this_bfile,subjects);
              bd = [bd B];
              bdNames = [bdNames [roiVarNames{j} '_' strrep(stims{k},'-','') '_beta']];
          end
            
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
Tratings = array2table([condpa condna condfamiliarity],'VariableNames',varnames);


% preference ratings for food, alcohol stim
fp=fullfile(baseDir,'source','%s','behavior','cue_matrix.csv'); % filepath
fpc = cellfun(@(x) sprintf(fp,x), subjects, 'uniformoutput',0); % filepath as cell array w/subject ids
[trial,tr,starttime,clock,trial_onset,trial_type,cue_rt,choice,choice_num,...
    choice_type,choice_rt,iti,drift,image_name]=cellfun(@(x) getCueTaskBehData(x,'short'), fpc, 'uniformoutput',0);

% get mean pref ratings by condition w/subjects in rows
pref = cell2mat(choice_num')'; % subjects x items pref ratings
mean_pref = [];
for j=1:numel(conds) % # of conds
    mean_pref(:,j) = nanmean(pref(:,ci==j),2);
end
varnames=cellfun(@(x) ['pref_' x ], conds,'uniformoutput',0);
Tpref = array2table(mean_pref,'VariableNames',varnames);


% BIS (from BIS/BAS)
% neuroticism (from TIPI 5)
% 
% docid = '1Ra-JM2JyLnqYyFnfnwr8mTrcesAG94tz-REDeCNMaG8'; % doc id for google sheet
% 
% colname = {'BIS'};
% 
% subjids=getFmrieatSubjects('cue');
% 
% subjci=1;
% 
% if ~iscell(colname)
%     colname={colname};
% end


% DEMOGRAPHICS:
% ethnicity
% gender
% SES






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% concatenate all variables into 1 table



% subject ids
Tsubj = table(subjects);


% concatenate all data into 1 table
T=table();
% T = [Tsubj Trelapse Tdem Tbeh Tbrain Totherdruguse];
T = [Tsubj Toutcomefoodvars Toutcomealc30dvars Toutcomealc6mvars Tbrain Tratings Tpref]; 

% save out
writetable(T,outPath);

% done














