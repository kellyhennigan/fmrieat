function p = getFmrieatPaths()
% -------------------------------------------------------------------------
% usage: get a structural array containing all relevant paths for this
% experiment. Also moves the experiment's "scripts" directory to the top of
% the search path. If a subject id string is given, subject-specific
% directories will also be returned.

%
% INPUT:


%
% OUTPUT:
%   p - structural array containing relevant project paths
%
%
% author: Kelly, kelhennigan@gmail.com, 09-Nov-2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get base directory address
baseDir = getFmrieatMainDir;


% define structural array p for output
p = struct();

p.baseDir = baseDir;
p.raw = fullfile(p.baseDir, 'rawdata_bids');
p.derivatives = fullfile(p.baseDir, 'derivatives');
p.source = fullfile(p.baseDir, 'source');
p.figures = fullfile(p.baseDir, 'figures');
p.scripts = fullfile(p.baseDir, 'scripts');
p.subjlist = fullfile(p.baseDir, 'subjects_list');

% place scripts directory at the top of the search path
path(genpath_nohidden(p.scripts),path)



end % function


