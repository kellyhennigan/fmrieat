function [trial,TR,trialonset,trialtype,target_ms,rt,cue_value,win,trial_gain,...
    total,iti,drift,total_winpercent,binned_winpercent]=loadMidBehData(filePath,format)
% -------------------------------------------------------------------------
% usage: loads mid or midi behavioral data
%
% INPUT:
%   filepath - string specifying which stim file
%   format - 'long' for all rows or 'short' for just 1 row/trial

% OUTPUT:
%   column headers of mid behavioral stim file & header, which is a string
%   of all those column headers
%
% author: Kelly, kelhennigan@gmail.com, 04-Apr-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

% if file doesn't exist, throw an error
if ~exist(filePath,'file')
    error(['cant find input stim file, ' filePath ' check for typos']);
end

% return long format by default
if ~exist('format','var')
    format = 'long';
end

T=readtable(filePath);


trial = T.trial;
TR = T.TR;
trialonset = T.trialonset;
trialtype=T.trialtype;
target_ms=T.target_ms;
rt=T.rt;
cue_value=T.cue_value;
win=T.hit;
trial_gain=T.trial_gain;
total=T.total;
iti=T.iti;
drift=T.drift;
total_winpercent=T.total_winpercent;
binned_winpercent=T.binned_winpercent;


%% short or long format?

% if short format is requested, return only 1 row entry per trial
if strcmp(format,'short')
    
    % get an index for rows w/new trial starts
    t_idx = [1;find(diff(trial))+1];
    if any(isnan(trial(t_idx)))
        t_idx(isnan(trial(t_idx)))=[];
    end
    
    trial = trial(t_idx);
    TR = TR(t_idx);
    trialonset = trialonset(t_idx);
    trialtype=trialtype(t_idx);
    target_ms=target_ms(t_idx);
    rt=rt(t_idx);
    cue_value=cue_value(t_idx);
    win=win(t_idx);
    trial_gain=trial_gain(t_idx);
    total=total(t_idx);
    iti=iti(t_idx);
    drift=drift(t_idx);
    total_winpercent=total_winpercent(t_idx);
    binned_winpercent=binned_winpercent(t_idx);
    
end



