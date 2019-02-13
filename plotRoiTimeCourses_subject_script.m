% plot roi time courses by subject 

% this will produce a figure with a timecourse line for each subject

clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% DEFINE VARIABLES (EDIT AS NEEDED) %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



p=getFmrieatPaths;
dataDir = p.derivatives;
figDir = p.figures;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% EDIT AS DESIRED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
task = 'cue';


[subjects,gi]=getFmrieatSubjects(task);
subjects=subjects(1:3);

stim = 'food'; % stim to plot

stimStr = stim; % stim name 

roiName = 'nacc_desai'; % roi to process

tcDir = ['timecourses_' task ];
% tcDir = ['timecourses_' task '_afni_woOutliers' ];

% color scheme for plotting: 'rand' for random colors, 
% 'mean' to plot mean of subjects, etc.
colorScheme = 'rand'; 
% colorScheme = 'relapse'; 


plotLegend=1; % 1 to include plot legend, otherwise 0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nTRs = 8; % # of TRs to plot
TR = 2; % 2 sec TR
t = 0:TR:TR*(nTRs-1); % time points (in seconds) to plot
xt = t; %  xticks on the plotted x axis

saveFig = 1; % 1 to save out figures

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%r
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it



% get ROI time courses
inDir = fullfile(dataDir,tcDir,roiName); % time courses dir for this ROI

     
if strfind(stim,'-')
    stim1 = stim(1:strfind(stim,'-')-1);
    stim2 = stim(strfind(stim,'-')+1:end);
    tc1=loadRoiTimeCourses(fullfile(inDir,[stim1 '.csv']),subjects,1:nTRs);
    tc2=loadRoiTimeCourses(fullfile(inDir,[stim2 '.csv']),subjects,1:nTRs);
    tc=tc1-tc2;
else
    stimFile = fullfile(inDir,[stim '.csv']);
    tc=loadRoiTimeCourses(stimFile,subjects,1:nTRs);
end

% calculate mean and se of time courses
mean_tc = nanmean(tc);
se_tc = nanstd(tc)./sqrt(size(tc,1));
   
%%%%%%
% put each subjects time course into its own cell in an array 
tc=mat2cell(tc,[ones(size(tc,1),1)],[size(tc,2)]); 


% make sure all the time courses are loaded
if any(cellfun(@isempty, tc))
    tc
    error('\hold up - time courses for at least one stim/group weren''t loaded.')
end

n = numel(subjects);


%% set up all plotting params

% fig title
figtitle = [strrep(roiName,'_',' ') ' response to ' strrep(stim,'_',' ') ' by subject'];

% x and y labels
xlab = 'time (s) relative to cue onset';
ylab = '%\Delta BOLD';


% labels for each line plot (goes in the legend)
if plotLegend
    lineLabels = subjects;
else
    lineLabels='';
end

%%%%%% colors: 
if strcmp(colorScheme,'rand') % random colors
    cols = solarizedColors(n); % line colors - Nx3 matrix of rgb vals (1 row/subject)
    cols = cols(randperm(n),:);

elseif strcmp(colorScheme,'mean') % each line is gray and mean is blue
    cols=repmat([.6 .6 .6],n,1);
    mean_col= [0.1490    0.5451    0.8235]; % color to plot mean timecourse
    
else
    cols = solarizedColors(n); % line colors - Nx3 matrix of rgb vals (1 row/subject)
end


% filename, if saving
savePath = [];
if saveFig
  
    outDir = fullfile(figDir,tcDir,roiName);
    if ~exist(outDir,'dir')
        mkdir(outDir)
    end
    % nomenclature: roiName_stimStr_groupStr
    outName = [roiName '_' stimStr '_by_subj'];
    savePath = fullfile(outDir,outName);
end


%% finally, plot the thing!

fprintf(['\n\n plotting figure: ' figtitle '...\n\n']);

   
[fig,leg]=plotNiceLines(t,tc,{},cols,[],lineLabels,xlab,ylab,figtitle,savePath);
set(leg,'Location','EastOutside')

if strcmp(colorScheme,'mean')
    plot(t,mean_tc,'color',mean_col,'Linewidth',5)
end

if savePath
    print(gcf,'-dpng','-r300',savePath);
end

fprintf('done.\n\n')


%% plot single subject(s) in black

% gcf
% hold on
% subjects
% plot(t,tc{30},'color','k','linewidth',2)
