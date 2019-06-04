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

dataDir = p.derivatives;

outPath = fullfile(dataDir,'prediction_data',['data_' datestr(now,'yymmdd') '.csv']);



%% GET DATA

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
    ndrinks30_1=[];
    nepisodes30_1=[];
    ndrinks30_2=[];
    nepisodes30_2=[];
    binge30_1=[];
    binge30_2=[];

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
            ndrinks30_1(i,1)=nan;
            nepisodes30_1(i,1)=nan;
            ndrinks30_2(i,1)=nan;
            nepisodes30_2(i,1)=nan;
            binge30_1(i,1)=nan;
            binge30_2(i,1)=nan;
        else
            ndrinks30_1(i,1) = str2double(d{idx,ciNdrinks1});
            ndrinks30_2(i,1) = str2double(d{idx,ciNdrinks2});
            nepisodes30_1(i,1) = str2double(d{idx,ciNepisodes1});
            nepisodes30_2(i,1) = str2double(d{idx,ciNepisodes2});
            binge30_1(i,1) = str2double(d{idx,ciBinge1});
            binge30_2(i,1) = str2double(d{idx,ciBinge2});
        end
    end
end


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
    
    nepisodespermonth6_1=[];
    ndrinksperweek6_1=[];
    ndrinksperepisode6_1=[];
    
else
    ciNepisodes = find(strcmp(d(1,:),'Averaging over the past 6 months, how many times in a TYPICAL month do you drink ALCOHOL?')); % column with BMI scores
    ciNdrinks = find(strcmp(d(1,:),'Averaging over the past 6 months, how many drinks do you have in a TYPICAL WEEK?')); % column with BMI scores
    cidrinksperep = find(strcmp(d(1,:),'Averaging over the past 6 months, how many drinks do you TYPICALLY have at ONE TIME?'));
    
    for i=1:numel(subjects)
        idx=find(strncmp(d(:,1),subjects{i},numel(subjects{i}))); % find row index for this subject
        if isempty(idx)
            
            nepisodespermonth6_1(i,1)=nan;
            ndrinksperweek6_1(i,1)=nan;
            ndrinksperepisode6_1(i,1)=nan;
            
        else
            
            nepisodespermonth6_1(i,1)=str2double(d{idx,ciNepisodes});
            ndrinksperweek6_1(i,1)=str2double(d{idx,ciNdrinks});
            ndrinksperepisode6_1(i,1)=str2double(d{idx,cidrinksperep});
            
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
    
    nepisodespermonth6_2=[];
    ndrinksperweek6_2=[];
    ndrinksperepisode6_2=[];
    
else
    ciNepisodes = find(strcmp(d(1,:),'Averaging over the past 6 months, how many times in a TYPICAL month do you drink ALCOHOL?')); % column with BMI scores
    ciNdrinks = find(strcmp(d(1,:),'Averaging over the past 6 months, how many drinks do you have in a TYPICAL WEEK?')); % column with BMI scores
    cidrinksperep = find(strcmp(d(1,:),'Averaging over the past 6 months, how many drinks do you TYPICALLY have at ONE TIME?'));
    
    for i=1:numel(subjects)
        idx=find(strncmp(d(:,1),subjects{i},numel(subjects{i}))); % find row index for this subject
        if isempty(idx)
            
            nepisodespermonth6_2(i,1)=nan;
            ndrinksperweek6_2(i,1)=nan;
            ndrinksperepisode6_2(i,1)=nan;
            
        else
            
            nepisodespermonth6_2(i,1)=str2double(d{idx,ciNepisodes});
            ndrinksperweek6_2(i,1)=str2double(d{idx,ciNdrinks});
            ndrinksperepisode6_2(i,1)=str2double(d{idx,cidrinksperep});
            
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

Toutcomevars = table(BMI1,BMI2,fat1,fat2,waist1,waist2,hip1,hip2,w2hr1,w2hr2,...
    deltaBMI,deltafat,deltawaist,deltahip,deltaw2hr);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% concatenate relapse, demographic, behavioral, & brain data into 1 table

% subject ids
Tsubj = table(subjects);


% concatenate all data into 1 table
T=table();
% T = [Tsubj Trelapse Tdem Tbeh Tbrain Totherdruguse];
T = [Tsubj Toutcomevars]

% save out
writetable(T,outPath); 

% done 














