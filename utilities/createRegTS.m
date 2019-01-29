function [reg,regc]=createRegTS(eventOnsets,vals,nTRs,convolve,saveFileName)
% -------------------------------------------------------------------------
% usage: create regressor time series for cue experiment
%
% INPUT:
%   eventOnsets - event onsets (in units of TRs) to include in regressor
%   vals - vector either the same length as eventOnsets indicating the
%          value to give each event or a single integer of value to give
%          all events
%   nTRs - total number of volumes acquired in the scan 
%   convolve - 'spm' to convolve reg time series with spm's hrf, 'waver' to 
%       use afni's hrf, otherwise 0 to not do  convolution. Default is 0.
%   saveFileName - filepath for saving out regressor; if not given,
%   then the regressor won't be saved.
%
%
% OUTPUT:
%   reg - regressor time series
%   regc - convolved regressor time series
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 20-Dec-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

if notDefined('convolve')
    convolve = 0;
end

if notDefined('saveFileName')
    saveOut = 0;
%     if strcmp(convolve,'waver')
%         error('saveFileName must be defined for "waver" convolution');
%     end
else
    saveOut = 1;
end


%% define regressor time series (not convolved)

% define (not convolved) regressor time series
reg = zeros(nTRs,1);
reg(eventOnsets)=vals; % set regressor at event onset times to value in vals

% save out if desired
if saveOut
    [outDir,regName,fs]=fileparts(saveFileName);
    dlmwrite(saveFileName,reg);
    fprintf(['reg file ' regName fs ' saved.\n']);
end


%% do convolution if desired

regc = [];

if convolve
    
    TR = 2; % repetition time for cue experiment
    
    % spm's hrf
    if strcmp(convolve,'spm')
        hrf = spm_hrf(TR);
        regc = conv(reg,hrf); % convolve
        regc = regc(1:nTRs);  % make sure it has the right # of vols
        regc = regc./max(abs(regc)); % scale it to max=1
        if saveOut
            saveFileName2 = fullfile(outDir,[regName 'c_spm' fs]);
            dlmwrite(saveFileName2,regc);
            fprintf(['reg file ' regName 'c_spm' fs ' saved.\n']);
        end
        
        
        % afni's hrf waver
    elseif strcmp(convolve,'waver')
        
        % HARD CODE PATH TO AFNI BIN (directory that contains afni's waver
        % function)
        afniDir = '~/abin/';
%          afniDir = '/usr/lib/afni/bin/';
        if exist(afniDir,'dir')~=7
            error('path to afni bin isnt correct; check this and hard code it into this script. This needs to be the path to the directory that contains the afni function "waver".')
        end
        
      
        % if reg ts wasn't saved out, save it out as a temp file to give to
        % afni's waver command
        if ~saveOut
             saveFileName = tempname; 
             dlmwrite(saveFileName,reg); % save out reg ts to give as input to waver cmd
             saveFileName2 = tempname;
             msg = ['reg ts convolved.\n'];
        else 
            saveFileName2 = fullfile(outDir,[regName 'c' fs]);
            msg = ['reg file ' regName 'c' fs ' saved.\n'];
        end
        
        cmd = [afniDir 'waver -dt ' num2str(TR) ' -GAM -peak 1 -numout ' num2str(nTRs) ...
            ' -input ' saveFileName ' > ' saveFileName2];
        system(cmd)
        fprintf(msg);
        regc = dlmread(saveFileName2);
          
        
    end
        
      
        
end