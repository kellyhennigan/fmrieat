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


tcDir = ['timecourses_' task ];
% tcDir = ['timecourses_' task '_woOutliers' ];

tcPath = fullfile(dataDir,tcDir);


% which rois to process?
roiNames = whichRois(tcPath);


nTRs = 8; % # of TRs to plot
TR = 2; % 2 sec TR
t = 0:TR:TR*(nTRs-1); % time points (in seconds) to plot
xt = t; %  xticks on the plotted x axis

useSpline = 0; % if 1, time series will be upsampled by TR*10

omitSubs={''}; % any subjects to omit? If so, enter their ids here

plotStats = 1; % 1 to note statistical signficance on figures

saveFig = 1; % 1 to save out figures

numberFigs = 0; % 1 to number the figs' outnames (useful for viewing in Preview)

outDir_suffix = '_bygroup';

plotColorSet = 'color'; % 'grayscale' or 'color'

plotErr = 'bar'; % 'bar' or 'shaded'

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

% [plotStims,plotStimStrs]=getTCPlotSpec(task);

% [plotGroups,plotStims,plotStimStrs]=getTCPlotSpec(task);

plotGroups={'past30daydrinkers_2 nonpast30daydrinkers_2';
    'past30daybingers_2 nonpast30daybingers_2'};

plotGroupStrs = {
    'past30drinkers_T2';
    'past30bingers_T2'};


plotStims = {'alcohol-neutral';
    'alcohol-neutral'};

plotStimStrs=plotStims;



nFigs = numel(plotStimStrs); % number of figures to be made


%% ROI LOOP
r=1;
for r = 1:numel(roiNames)
    
    roiName = roiNames{r};
    
    inDir = fullfile(dataDir,tcDir,roiName); % time courses dir for this ROI
    
    
    %% FIGURE LOOP
    f=1;
    for f = 1:nFigs
        
        % get the plot name and stims & groups to plot for this figure
        groups = splitstring(plotGroups{f});
        stims = splitstring(plotStims{f});
        stimStr = plotStimStrs{f};
        
        tc = {}; % time course cell array
        
        for g=1:numel(groups)
            
            % get subject IDs for this group
            subjects = getFmrieatSubjects(task,groups{g});
            subjects(ismember(subjects,omitSubs))=[];  % omit subjects?
            n(g) = numel(subjects); % n subjects for this group
            
            for c = 1:numel(stims)
                
                % if there's a minus sign, assume desired plot is stim1-stim2
                if strfind(stims{c},'-')
                    stim1 = stims{c}(1:strfind(stims{c},'-')-1);
                    stim2 = stims{c}(strfind(stims{c},'-')+1:end);
                    tc1=loadRoiTimeCourses(fullfile(inDir,[stim1 '.csv']),subjects,1:nTRs);
                    tc2=loadRoiTimeCourses(fullfile(inDir,[stim2 '.csv']),subjects,1:nTRs);
                    tc{g,c}=tc1-tc2;
                else
                    stimFile = fullfile(inDir,[stims{c} '.csv']);
                    tc{g,c}=loadRoiTimeCourses(stimFile,subjects,1:nTRs);
                end
                
            end % stims
            
        end % groups
        
        
        % make sure all the time courses are loaded
        if any(cellfun(@isempty, tc))
            tc
            error('\hold up - time courses for at least one stim/group weren''t loaded.')
        end
        
        mean_tc = cellfun(@nanmean, tc,'uniformoutput',0);
        se_tc = cellfun(@(x) nanstd(x)./sqrt(size(x,1)), tc,'uniformoutput',0);
        
        %  upsample time courses
        if (useSpline)
            t_orig = t;
            t = t(1):diff(t(1:2))/10:t(end); % upsampled x10 time course
            mean_tc = cellfun(@(x) spline(t_orig,x,t), mean_tc, 'uniformoutput',0);
            se_tc =  cellfun(@(x) spline(t_orig,x,t), se_tc, 'uniformoutput',0);
        end
        
        
        
        %% set up all plotting params
        
        % fig title
        figtitle = [strrep(roiName,'_',' ') ' to ' stimStr ' in ' strrep(groups{1},'_',' ') ' (n=' num2str(n(1)) ')'];
        if numel(groups)>1
            for g=2:numel(groups)
                figtitle = [figtitle ', ' strrep(groups{g},'_',' ') ' (n=' num2str(n(g)) ')'];
            end
        end
        
        % x and y labels
        xlab = 'time (s)';
        ylab = '%\Delta BOLD';
        
        
        % labels for each line plot (goes in the legend)
        lineLabels = cell(numel(groups),numel(stims));
        if numel(stims)>1
            lineLabels = repmat(stims,numel(groups),1); lineLabels = strrep(lineLabels,'_',' ');
        end
        if numel(groups)>1
            for g=1:numel(groups)
                lineLabels(g,:) = cellfun(@(x) [x strrep(groups{g},'_',' ') ], lineLabels(g,:), 'uniformoutput',0);
            end
        end
        
        
        % line colors & line specs
        cols=reshape(cellfun(@(x) getCueExpColors(x,plotColorSet),lineLabels,'uniformoutput',0),size(tc,1),[]);
        cols{1}=[  0.9922    0.1725    0.0784];     % red
        cols{2}=[0.1647    0.6275    0.4706];       % green
        cols{end}=[  0.0078    0.4588    0.7059];   % blue
        
        lspec = reshape(getCueLineSpec(lineLabels),size(tc,1),[]);
        
        % get stats, if plotting
        p=[];
        if plotStats
            if numel(groups)>1
                p = getPValsGroup(tc); % one-way ANOVA
            else
                p = getPValsRepMeas(tc); % repeated measures ANOVA
            end
        end
        
        
        % filepath, if saving
        savePath = [];
        if saveFig
            % nomenclature: roiName_stimStr_groupStr
            outDir = fullfile(figDir,tcDir,[roiName outDir_suffix]);
            if ~exist(outDir,'dir')
                mkdir(outDir)
            end
            if numel(groups)==1
                outName = [roiName '_' stimStr '_' groups{1}];
            else
                outName = [roiName '_' stimStr '_by' plotGroupStrs{f}];
            end
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
        
        
          %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  EXTRA FORMATTING HAPPENS HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%% ROI specific y params
    % get y-axis params that are roi specific
    if strcmpi(roiName,'mpfc')
        
        
        YL = [-.2 .17]; % YL is ylim
        YT = -.2:.05:.15; % YT determines YTicks
        
        
    elseif strcmpi(roiName,'naccL_desai')
        
        YL = [-.1 .12]; % YL is ylim
        YT = -.1:.05:.1; % YT determines YTicks
        
    elseif strcmpi(roiName,'naccR_desai')
        
        YL = [-.1 .12]; % YL is ylim
        YT = -.1:.05:.1; % YT determines YTicks
        
    elseif strcmpi(roiName,'nacc_desai')
        
        YL = [-.1 .12]; % YL is ylim
        YT = -.1:.05:.1; % YT determines YTicks
        
        
    elseif strcmpi(roiName,'vta')
        
        YL = [-.15 .12]; % YL is ylim
        YT = -.15:.05:.1; % YT determines YTicks
        
        
    else
        
          YL = [-.2 .17]; % YL is ylim
            YT = -.2:.05:.15; % YT determines YTicks
        
    end
    
    
    %%%%%%% manually change y axis here:
    if ~notDefined('YT')
        set(gca,'YTick',YT)
    end
    
    if ~notDefined('YL')
        ylim([YL(1) YL(2)])
    end
    
    
    %%%%%%% grayed out rectangles
    yl = ylim;
    
    gxs = [5 13]; % x-axis limits for graying out
    
    % vertices
    v = [t(1) yl(1);
        t(1) yl(2);
        gxs(1) yl(2);
        gxs(1) yl(1);
        gxs(2) yl(1);
        gxs(2) yl(2);
        t(end) yl(2);
        t(end) yl(1)];
    
    patch('Faces',[1:4;5:8],'Vertices',v,'FaceColor',[.5 .5 .5],'EdgeColor','none','FaceAlpha',.5)
    
    
    %%%%%%% make lines thicker
    lw=4;
    ch=get(gca,'Children');
    set(ch(:),'LineWidth',lw)
    
    
    % ylim
    ylim([yl(1) yl(2)])
    
    % xlim and xtick
    xlim([t(1) t(end)])
    set(gca,'xtick',t)
    
    
    %%%%%%%%%% save a version that has the title and outside legend
    set(leg,'Location','EastOutside')
    print(gcf,'-dpng','-r300',[savePath '_leg']);
%       print(gcf,'-depsc','-r300',[savePath '_leg']);
%     saveas(gcf,[savePath '_leg'],'pdf');
    
    % title and legend off
    legend(gca,'off')
    title('')
    
    %%%%%%%%%% change font sizes
    fsize = 26;
    set(gca,'fontName','Helvetica','fontSize',fsize)
    %         title('NAc response to drugs-neutral trials','fontName','Helvetica','fontSize',fsize)
    
    % xlabel
    xlabel(xlab,'fontName','Helvetica','FontSize',fsize)
    %       xlabel([],'fontName','Helvetica','FontSize',fsize)
    %        xticklabels('')
    
    % y label
    ylabel(ylab,'fontName','Helvetica','FontSize',fsize)
    
    
    % re-save fig
%     print(gcf,'-dpng','-r300',savePath);
% saveas(gcf,savePath,'pdf');
%       print(gcf,'-depsc','-r300',savePath);
     print(gcf,'-dpng','-r300',savePath);
     
    fprintf('done.\n\n')
    
    
        
    end % figures
    
end %roiNames


