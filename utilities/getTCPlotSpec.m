function [stims,stimStrs]=getTCPlotSpec(task)
% -------------------------------------------------------------------------
% usage: define time course plot specifications for plotting VOI time
% courses for cue task
%
% INPUT: na
%
% OUTPUT:
%   stims - cell array of stims to plot; " "
%   stimStrs - cell array of strings (shorthand for multiple stims) to use
%   for plot title and file name, etc.

% NOTES: for cells that have >1 stim or group, they are separated with a
% space.
%
% author: Kelly, kelhennigan@gmail.com, 05-Apr-2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch task
    
    case 'cue'  % cue fmri task
        
        
        % corresponding stims:
        stims =  {'alcohol drugs food neutral';
            'strong_dontwant somewhat_dontwant somewhat_want strong_want';
            'alcohol neutral';
            'drugs neutral';
            'food neutral';};
        
        % corresponding stim strings to use in figure and file name
        stimStrs =  {'type';
            'want';
            'alcoholVneutral';
            'drugsVneutral';
            'foodVneutral';};
        
        
    otherwise 
        error('task should be cue bc thats the only task these subjects did');
end

   






