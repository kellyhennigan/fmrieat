function [pa,na,cueNames]=getCueRatings(filepath)
% -------------------------------------------------------------------------
% usage: return PA and NA ratings for cues for cue reactivity study
% 
% INPUT:
%   filepath - path to cue ratings
%  
% OUTPUT:
%   pa - positive arousal 
%   na - negative arousal
%   cueNames - label associated with each cue
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 27-May-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if file doesn't exist, throw an error
if ~exist(filepath,'file')
    cueNames = {};
    pa = [];
    na = [];
else 

% load cue ratings
T=readtable(filepath); 

cueNames = table2cell(T(:,1)); 

valence = T.valence;
arousal = T.arousal;

[pa,na]=va2pana(valence,arousal);

end