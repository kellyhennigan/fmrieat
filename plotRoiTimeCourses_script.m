% plot roi time courses

% each plot will have time courses for a single ROI, with stims x groups
% lines. Eg, if stims='food' and groups={'controls','patients'}, separate
% time courses will be plotted for controls and patients to food trials.

clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% DEFINE VARIABLES (EDIT AS NEEDED) %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



p=getFmrieatPaths;
dataDir = p.derivatives;
figDir = p.figures;

task = 'cue';

subjects=getFmrieatSubjects(task);

tcDir = ['timecourses_' task ];
% tcDir = ['timecourses_' task '_woOutliers' ];

tcPath = fullfile(dataDir,tcDir);


% which rois to process?
roiNames = whichRois(tcPath);


nTRs = 10; % # of TRs to plot
TR = 2; % 2 sec TR
t = 0:TR:TR*(nTRs-1); % time points (in seconds) to plot
xt = t; %  xticks on the plotted x axis

useSpline = 0; % if 1, time series will be upsampled by TR*10

omitSubs={''}; % any subjects to omit? If so, enter their ids here

plotStats = 1; % 1 to note statistical signficance on figures

saveFig = 1; % 1 to save out figures

numberFigs = 1; % 1 to number the figs' outnames (useful for viewing in Preview)

outDir_suffix = '';

plotColorSet = 'color'; % 'grayscale' or 'color'

plotErr = 'shaded'; % 'bar' or 'shaded'

plotToScreen=1; % 1 to plot figures to screen, otherwise 0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%r
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get task specific conditions/groups to plot

% plotStims should be cell arrays specifying the desired stims to plot in
% figures. plotStimStrs gives a string that describes the stim in a given
% plot. Each row of the cell array should have info for a single figure,
% e.g.:

% % % plotStims = {'alcohol drugs food neutral';
%  'strong_dontwant somewhat_dontwant somewhat_want strong_want'}

% plotStimStrs = {'type';
%     'want'};

% would be for making 2 figures: the 1st would plot alc, drugs, etc. and
% the second would plot according to want ratings.

[plotStims,plotStimStrs]=getTCPlotSpec(task);


nFigs = numel(plotStimStrs); % number of figures to be made


subjects(ismember(subjects,omitSubs))=[];  % omit subjects?


%% ROI LOOP
r=1;
for r = 1:numel(roiNames)
    
    roiName = roiNames{r};
    
    inDir = fullfile(dataDir,tcDir,roiName); % time courses dir for this ROI
    
    
    %% FIGURE LOOP
    f=1;
    for f = 1:nFigs
        
        % get the plot name and stims & groups to plot for this figure
        stims = splitstring(plotStims{f});
        stimStr = plotStimStrs{f};
        
        tc = {}; % time course cell array
        
        
        %% get all timecourses to plot for this figure 
        for c = 1:numel(stims)
            
            % if there's a minus sign, assume desired plot is stim1-stim2
            if strfind(stims{c},'-')
                stim1 = stims{c}(1:strfind(stims{c},'-')-1);
                stim2 = stims{c}(strfind(stims{c},'-')+1:end);
                tc1=loadRoiTimeCourses(fullfile(inDir,[stim1 '.csv']),subjects,1:nTRs);
                tc2=loadRoiTimeCourses(fullfile(inDir,[stim2 '.csv']),subjects,1:nTRs);
                tc{c}=tc1-tc2;
            else
                stimFile = fullfile(inDir,[stims{c} '.csv']);
                tc{c}=loadRoiTimeCourses(stimFile,subjects,1:nTRs);
            end
            
        end % stims
        
        %  do this because loadRoiTimeCourses() returns NaN values for
        %  requested subjects if they don't have timecourses saved, and we
        %  want an accurate measure of n
        n = sum(~isnan(tc{1}(:,1))); 
        
        % make sure all the time courses are loaded
        if any(cellfun(@isempty, tc))
            tc
            error('\hold up - time courses for at least one stim wasn''t loaded.')
        end
        
        % get mean and standard error (across subjects) for all relevant timecourses to plot
        mean_tc = cellfun(@nanmean, tc,'uniformoutput',0);
        se_tc = cellfun(@(x) nanstd(x)./sqrt(n), tc,'uniformoutput',0);
        
        %  upsample time courses, if desired
        if (useSpline)
            t_orig = t;
            t = t(1):diff(t(1:2))/10:t(end); % upsampled x10 time course
            mean_tc = cellfun(@(x) spline(t_orig,x,t), mean_tc, 'uniformoutput',0);
            se_tc =  cellfun(@(x) spline(t_orig,x,t), se_tc, 'uniformoutput',0);
        end
        
        
        %% set up all plotting params
        
        % fig title
        figtitle = [strrep(roiName,'_',' ') ' response to ' stimStr ' (n=' num2str(n(1)) ')'];
        
        
        % x and y labels
        xlab = 'time (s)';
        ylab = '%\Delta BOLD';
        
        
        % labels for each line plot (goes in the legend)
        lineLabels = stims;
        
        
        % line colors & line specs
        cols = cellfun(@(x) getCueExpColors(x),stims,'uniformoutput',0);
        lspec = repmat({'-'},size(lineLabels)); % '-' will plot a straight line, '--' will plot a dotted liine
        
        
        % get stats, if plotting
        p=[];
        if plotStats
            p = getPValsRepMeas(tc); % repeated measures ANOVA
        end
        
        
        % filepath, if saving
        savePath = [];
        if saveFig
            % nomenclature: roiName_stimStr_groupStr
            outDir = fullfile(figDir,tcDir,[roiName outDir_suffix]);
            if ~exist(outDir,'dir')
                mkdir(outDir)
            end
            outName = [stimStr];
            if numberFigs==1
                outName = [num2str(f) ' ' outName];
            end
            savePath = fullfile(outDir,outName);
        end
        
        
        %% finally, plot the thing!
        
        fprintf(['\n\n plotting figure: ' figtitle '...\n\n']);
        
        switch plotErr
            case 'bar'
                [fig,leg]=plotNiceLinesEBar(t,mean_tc,se_tc,cols,p,lineLabels,xlab,ylab,figtitle,savePath,plotToScreen,lspec);
            case 'shaded'
                [fig,leg]=plotNiceLines(t,mean_tc,se_tc,cols,p,lineLabels,xlab,ylab,figtitle,savePath,plotToScreen,lspec);
        end
        
        
        fprintf('done.\n\n');
        
        
    end % figures
    
end %roiNames


