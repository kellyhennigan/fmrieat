function [fgMeasures,fgMLabels]=combineLRFgMeasures(fgMFileL,fgMFileR,savePath)
% -------------------------------------------------------------------------
% usage: function to combine left and right fiber group measures from .mat file saved using
% function dtiSaveFGMeasures_script
%
% INPUT:
%   fgMFileL - filepath to left fgMeasures .mat file
%   fgMFileR - " " right ""
%   savePath - if given, combined fgMeasures will be saved out to specified
%              filepath called savePath
%
% OUTPUT:
%   returns combined fgMeasures
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 12-Sep-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load left & right fg file
l=load(fgMFileL);
r=load(fgMFileR);

varnames = fieldnames(l);

% before combining, make sure that L & R strucural arrays have the same
% field names & have the same subjects
if ~isequal(varnames,fieldnames(r)) || ~isequal(l.subjects,r.subjects)
    error('L and R fg files either have unequal fields or non-matching subjects - check this before combining...');
end

% now combine (note: this should be smarter to automatically detect what
% fields are there instead of hard coding...)
subjects = l.subjects;
gi=l.gi;
seed = l.seed;
target = l.target;
lr = 'LR_mean';
fgName = {l.fgName,r.fgName};
nNodes = l.nNodes;
fgMLabels=l.fgMLabels;
err_subs{1} = l.err_subs; err_subs{2} = r.err_subs;
SuperFibers(:,1)=l.SuperFibers; SuperFibers(:,2)=r.SuperFibers;
eigVals{1} = l.eigVals; eigVals{2} = r.eigVals;

% combine fgMeasures
fgMeasures=cellfun(@(x,y) mean(cat(3,x,y),3), l.fgMeasures,r.fgMeasures,'uniformoutput',0);


if ~notDefined('savePath')
    save(savePath,'subjects','gi','seed','target','lr',...
        'fgName','nNodes','fgMeasures','fgMLabels','SuperFibers','eigVals','err_subs');
    
end

% if ~notDefined('savePath')
%     save(savePath,'subjects','gi','seed','target','lr',...
%         'fgName','nNodes','fgMeasures','fgMLabels','eigVals','err_subs');
%     
% end
