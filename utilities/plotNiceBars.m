function [fig,leg] = plotNiceBars(d,dName,condNames,groupNames,cols,plotSig,titleStr,plotLeg,savePath)
% [fig,leg] = plotNiceBars(d,dName,condNames,groupNames,cols,plotSig,savePath)
% niceBarPlot
% -------------------------------------------------------------------------
% usage: use this function to make nice looking bar plots
%
% INPUT:
%   d - cell array with data to plot. Data should be organized as:
%       { subjects x conditions } w/groups in different cells.
%   dName - name of measure (e,g., 'preference ratings')
%   condNames - cell array of with names for each condition (e.g.,
%       {'alcohol','drugs',food','neutral'}
%   groupNames - cell array of names for each group (e.g.,
%       {'controls','patients'}
%   cols - rgb values for bar plots
%   plotSig - 1x2 vector of 1s or 0s: first val is whether to plot * above
%       sig group differences, 2nd val is whether to write out ANOVA
%       results to the right of the plot. Default is to not plot either.
%   titleStr - title string
%   plotLeg - 1 to plot legend, otherwise 0
%   savePath - filepath to save out figure to; if not given, it won't be
%      saved.

% OUTPUT:
%   h - figure handle
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 02-Jul-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% if d isn't a cell, put it into a cell & assume this is a single group
if ~iscell(d)
    d = {d};
end

nConds = size(d{1},2); % # of conditions
nGroups = numel(d); % # of groups


% assign default values for variables if they're not defined

if notDefined('dName')
    dName = 'measure';
end

if notDefined('condNames')
    condNames = strcat('cond ',splitstring(num2str(1:nConds)));
end

if notDefined('groupNames')
    groupNames = strcat('group ',splitstring(num2str(1:nGroups)));
end

if notDefined('cols')
    cols = solarizedColors(nGroups);
end

if notDefined('plotSig')
    plotSig = [0 0]; % don't plot * or ANOVA results by default
end
if numel(plotSig)==1
    plotSig = [plotSig plotSig];
end

if notDefined('titleStr')
    titleStr = ''; % don't save out fig unless savePath is given
end

if notDefined('plotLeg')
    plotLeg = 0; % dont plot legend by default
end



if notDefined('savePath')
    savePath = ''; % don't save out fig unless savePath is given
end


% remove subjects with any NaN values
[ri,cj]=cellfun(@(x) find(isnan(x)), d, 'uniformoutput',0);

fprintf(['\n excluding ' ...
    num2str(numel(cell2mat(cellfun(@(x) unique(x), ri,'uniformoutput',0)'))) ...
    ' subjects from analysis due to nan values...\n']);

if ~isempty(ri)
    for i=1:nGroups
        d{i}(ri{i},:) = [];
    end
end


%% get mean/sd of data

% group mean ratings by condition
mean_d = cell2mat(cellfun(@nanmean, d,'uniformoutput',0)')';
se_d = cell2mat(cellfun(@(x) nanstd(x)./sqrt(size(x,1)), d,'uniformoutput',0)')';


%% plot it

fontName = 'Helvetica';
fontSize = 12;
% fontSize = 18;

fig=figure;
%hold on

% if there are a lot of bars to plot, make the figure wider
nBars = nConds*nGroups;
if nBars > 6
    pos=get(fig,'Position');
    set(fig,'Position',[pos(1)-(nBars-6).*40, pos(2), pos(3)+(nBars-6).*40, pos(4)])
    %     ss = get(0,'Screensize'); % screen size
    %     set(fig,'Position',[ss(3)-800 ss(4)-420 800 420]) % make figure 800 x 420 pixels
end

set(fig,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');

set(gca,'fontName',fontName,'fontSize',fontSize)

h = barwitherr(se_d,mean_d)

set(h,'EdgeColor','w')

set(gca,'box','off');

colormap(cols)

% try to rotate the xlabels by 30 degrees, but if that doesnt work, no prob
try
    set(gca,'XTickLabel',condNames)
    xtickangle(30)
catch ME
    try
        xticklabel_rotate(1:numel(condNames),30,condNames)
    catch ME
        set(gca,'XTickLabel',condNames)
    end
end

% y axis
ylabel(dName)
% ylim([ -2 3])


% title
title(titleStr)


% legend
leg = [];
if plotLeg
    for i=1:numel(d)
        leg_text{i} = [groupNames{i} ' (n=' num2str(size(d{i},1)) ')'];
        %  leg_text{i} = [groupNames{i}];
    end
    leg=legend(leg_text{:},'location','NorthEastOutside');
    legend(gca,'boxoff')
    
    % % shift legend over to the right to avoid smushing the plot
    % % lpos=get(leg,'position');
    % % set(leg,'position',[1-(lpos(3).*1.3),lpos(2:4)])
end

%% plot statistics?


if numel(groupNames)==1
    
    % plot asterisks over sig group differences?
    if plotSig(1)==1
        y_ast = max(mean_d(:)+se_d(:))+max(se_d(:)); % y-level for asterisks
        
        p = anova_rm(d{1},'off');
        if p<.001, a = '***';
        elseif p<.01, a = '**';
        elseif p<.05, a = '*';
        else a = '';
        end
        text(.5+size(d{1},2)./2,y_ast,a,'FontName','Times','FontSize',20,'HorizontalAlignment','center','color','k')
    end
    
    if plotSig(2)==1
        
        [p,tab]=anova_rm(d,'off');  % [p(cond) p(group) p(subjs) p(group*cond)]
        
        % get F stats
        Fc=tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'F')}; % time is within subjects measure (e.g., time or condition)
        
        % corresponding degrees of freedom
        df_c = tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'df')};
        df_e = tab{strcmpi(tab(:,1),'Error'),strcmpi(tab(1,:),'df')}; % error df
        
        anova_res = sprintf(repmat('%s:\nF(%d,%d) = %.1f; p = %.3f\n\n',1,1),...
            'condition',df_c,df_e,Fc,p(1));
        
        text(max(xlim)+.1,mean(ylim),anova_res,'FontSize',fontSize,'FontName',fontName,'VerticalAlignment','top')
        
    end
    
else
    
    % plot asterisks over sig group differences?
    if plotSig(1)==1
        y_ast = max(mean_d(:)+se_d(:))+max(se_d(:)); % y-level for asterisks
        for ci=1:nConds
            p = anova_rm(cellfun(@(x) x(:,ci), d,'uniformoutput',0),'off');
            p = p(~isnan(p)); % p-val for this comparison
            if p<.001, a = '***';
            elseif p<.01, a = '**';
            elseif p<.05, a = '*';
            else a = '';
            end
            text(ci,y_ast,a,'FontName','Times','FontSize',20,'HorizontalAlignment','center','color','k')
        end
    end
    
    
    if plotSig(2)==1 % write out ANOVA results?
        
        [p,tab]=anova_rm(d,'off');  % [p(cond) p(group) p(subjs) p(group*cond)]
        
        % get F stats
        Fc=tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'F')}; % time is within subjects measure (e.g., time or condition)
        Fg=tab{strcmp(tab(:,1),'Group'),strcmp(tab(1,:),'F')}; % group
        Fi=tab{strcmp(tab(:,1),'Interaction'),strcmp(tab(1,:),'F')}; % cond x group interaction
        
        % corresponding degrees of freedom
        df_c = tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'df')};
        df_g = tab{strcmp(tab(:,1),'Group'),strcmp(tab(1,:),'df')}; % group
        df_i=tab{strcmp(tab(:,1),'Interaction'),strcmp(tab(1,:),'df')}; % cond x group interaction
        
        df_e = tab{strcmpi(tab(:,1),'Error'),strcmpi(tab(1,:),'df')}; % error df
        
        anova_res = sprintf(repmat('%s:\nF(%d,%d) = %.1f; p = %.3f\n\n',1,3),...
            'condition',df_c,df_e,Fc,p(1),...
            'group',df_g,df_e,Fg,p(2),...
            'group x cond interaction',df_i,df_e,Fi,p(4));
        
        text(max(xlim)+.1,mean(ylim),anova_res,'FontSize',fontSize,'FontName',fontName,'VerticalAlignment','top')
    end
    
end % # of groups


%
% % plot asterisks over sig group differences?
% if plotSig(1)==1
%     y_ast = max(mean_d(:)+se_d(:))+mean(se_d(:))./2; % y-level for asterisks
%     for ci=1:nConds
%         p = anova_rm(cellfun(@(x) x(:,ci), d,'uniformoutput',0),'off');
%         p = p(~isnan(p)); % p-val for this comparison
%         if p<.001, a = '***';
%         elseif p<.01, a = '**';
%         elseif p<.05, a = '*';
%         else a = '';
%         end
%         text(ci,y_ast,a,'FontName','Times','FontSize',20,'HorizontalAlignment','center','color','k')
%     end
% end
%
%
% % write out ANOVA results?
% if plotSig(2)==1
%
%       [p,tab]=anova_rm(d,'off');  % [p(cond) p(group) p(subjs) p(group*cond)]
%
%     if numel(groupNames)==1
%
%         % get F stats
%         Fc=tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'F')}; % time is within subjects measure (e.g., time or condition)
%
%         % corresponding degrees of freedom
%         df_c = tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'df')};
%         df_e = tab{strcmpi(tab(:,1),'Error'),strcmpi(tab(1,:),'df')}; % error df
%
%         anova_res = sprintf(repmat('%s:\nF(%d,%d) = %.1f; p = %.3f\n\n',1,1),...
%             'condition',df_c,df_e,Fc,p(1));
%
%         text(max(xlim)+.1,mean(ylim),anova_res,'FontSize',fontSize,'FontName',fontName,'VerticalAlignment','top')
%
%     else
%         [p,tab]=anova_rm(d,'off');  % [p(cond) p(group) p(subjs) p(group*cond)]
%
%         % get F stats
%         Fc=tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'F')}; % time is within subjects measure (e.g., time or condition)
%         Fg=tab{strcmp(tab(:,1),'Group'),strcmp(tab(1,:),'F')}; % group
%         Fi=tab{strcmp(tab(:,1),'Interaction'),strcmp(tab(1,:),'F')}; % cond x group interaction
%
%         % corresponding degrees of freedom
%         df_c = tab{strcmp(tab(:,1),'Time'),strcmp(tab(1,:),'df')};
%         df_g = tab{strcmp(tab(:,1),'Group'),strcmp(tab(1,:),'df')}; % group
%         df_i=tab{strcmp(tab(:,1),'Interaction'),strcmp(tab(1,:),'df')}; % cond x group interaction
%
%         df_e = tab{strcmpi(tab(:,1),'Error'),strcmpi(tab(1,:),'df')}; % error df
%
%         anova_res = sprintf(repmat('%s:\nF(%d,%d) = %.1f; p = %.3f\n\n',1,3),...
%             'condition',df_c,df_e,Fc,p(1),...
%             'group',df_g,df_e,Fg,p(2),...
%             'group x cond interaction',df_i,df_e,Fi,p(4));
%
%         text(max(xlim)+.1,mean(ylim),anova_res,'FontSize',fontSize,'FontName',fontName,'VerticalAlignment','top')
%     end
%
% end

%% save out fig?

% save figure if desired
if savePath
    print(fig,'-dpng','-r600',savePath)
end

end


function colors = solarizedColors(nColors,colorNum)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this function generates rgb values for nColors by interpolating from
% the color scheme found here: http://ethanschoonover.com/solarized

% INPUTS:
%   nColors  - # of colors to interpolate
%   colorNum - index of the nColors to return (can be a vector or scalar)

% OUTPUTS
%   colors - rgb values for nColors, or colorNum index of nColors if
%            colorNum is given as input argument


% EXAMPLES:

% solarizedColors(4) returns a 4 x 3 matrix w/rgb values for 4 colors
% listed in rows

% solarizedColors() returns a 64 rgb values (listed in rows)

% solarizedColors(4,2) generates 4 rgb colors (same as above) and returns
% only the 2nd one


% kjh, 2012

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ~exist('nColors','var') || isempty(nColors)
    nColors = 64;
end

if ~exist('colorNum','var') || isempty(colorNum)
    colorNum = 1:nColors;
end


baseColors = [
    220  50  47
    203  75  22
    181 137   0
    133 153  0
    42 161 152
    38 139 210
    108 113 196
    211  54 130]./255;

x = linspace(0,1,length(baseColors));

xi = linspace(0,1,nColors);

for c = 1:3 % r, g, b columns
    colors(:,c) = interp1(x,baseColors(:,c),xi);
end
colors = abs(colors); % in case there's a negative value

colors = colors(colorNum,:); % colors to return


end

