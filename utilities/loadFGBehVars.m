function [fgMeasures,fgMLabels,scores,subjects,SuperFibers] = ...
    loadFGBehVars(fgMFile,scale,omit_subs)
% % 
% function [fgMeasures,fgMLabels,scores,subjects,gi,SuperFibers] = ...
%     loadFGBehVars(fgMFile,scale,group,omit_subs)

% [fgMeasures,fgMLabels,scores,subjects,gi] = loadFGBehVars(fullfile(fgMDir,[fgMatStr '.mat']),scale,group,omit_subs);
% -------------------------------------------------------------------------
% usage: function to load fiber group measures and other measures to correlate
% 
% INPUT:
%   var1 - integer specifying something
%   var2 - string specifying something
% 
% OUTPUT:
%   var1 - etc.
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 16-May-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
nargout

% set omit_subs to be an empty cell array if not given
if notDefined('omit_subs')
    omit_subs = {};
end

% no scale is default
if notDefined('scale')
    scale = '';
end


% load fiber group measures
load(fgMFile); 
% this loads vars: 
    % eigvals
    % err_subs (list of subjects w/problems)
    % fgMeasures
    % fgMLabels
    % fgName
    % gi
    % lr
    % nNodes
    % seed
    % subjects
    % SuperFibers
    % target

   
    
    
%% define a "keep index" of desired subjects to return data for

keep_idx = ones(numel(subjects),1);


% exclude omit_subs from keep index
keep_idx=logical(keep_idx.*~ismember(subjects,omit_subs));


% exclude any additional subjects that don't have diffusion data 
keep_idx(isnan(fgMeasures{1}(:,1)))=0;


% exclude any subjects that don't have scale data
if ~isempty(scale)
    keep_idx(isnan(getCueData(subjects,scale)))=0;
end


%%  get fg data for just the desired subjects

subjects = subjects(keep_idx);
fgMeasures = cellfun(@(x) x(keep_idx,:), fgMeasures,'uniformoutput',0);

if iscell(eigVals) % means l and r are saved separately
    eigVals{1}=eigVals{1}(keep_idx,:,:);
    eigVals{2}=eigVals{2}(keep_idx,:,:);
else
eigVals=eigVals(keep_idx,:,:);
end

if size(SuperFibers,2)==2 % means l and r are saved separately
    SuperFibers=SuperFibers(keep_idx,:);
else
    SuperFibers=SuperFibers(keep_idx);
end

% get scores 
if ~isempty(scale)
    scores = getCueData(subjects,scale);
else
    scores='';
end












