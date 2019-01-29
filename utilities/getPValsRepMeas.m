function p = getPValsRepMeas(tc)
% -------------------------------------------------------------------------
% usage: this function is to return p-values for multiple statistical
% tests; my intention is to use this for plotting sig differences on time
% course data for REPEATED MEASURES

% INPUT:
%   tc - timecourse data
%
% OUTPUT:
%   p - p values
%
% NOTES:
%
%
% author: Kelly, kelhennigan@gmail.com, 28-Mar-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% make sure data is shaped as 1 x NSTIM cell array
if ~iscell(tc)
    error('imput tc must be a cell array');
end
if size(tc,1)~=1
    tc = reshape(tc,1,[]);
end

%% do repeated measures anova (same as using repeated measures anova)

% loop over each time point
for i=1:size(tc{1},2)
    
    d = cell2mat(cellfun(@(x) x(:,i), tc,'UniformOutput',0));
    
    % eliminate any subjects that have NaN values
    if ~isempty(find(isnan(d)))
        [r,~]=find(isnan(d));
        d(r,:) = [];
    end
    
    p2= anova_rm(d,'off');
    p(i) = p2(1);
    
end






