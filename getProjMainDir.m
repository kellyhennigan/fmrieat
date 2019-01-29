function mainDir = getProjMainDir()
% -------------------------------------------------------------------------
% usage: function to get path to cue experiment base directory, which is
% different depending on which computer this function is running on
% 
% OUTPUT:
%   baseDir - string specifiying data directory path
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cName=getComputerName;

if strcmp(cName,'cnic2')               % cni server
    mainDir = '/home/hennigan/fmrieat';
else                                   % assume its my laptop
    mainDir = '/Users/kelly/fmrieat';
end
