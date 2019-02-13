function betas= saveOutRoiBetas(roiFilePath,subjects,resultsDir,fileStr,volIdx,outFilePath)
% -------------------------------------------------------------------------
% usage: this function will pull out VOI betas 
% 
% INPUT:
%   roiFilePath - file path to roi nifti file w/same dimensions as subject files (e.g., func)
%   subjects - cell array of subject ids
%   resultsDir - path to directory with glm results files
%   fileStr - string to use to ID files of interest
%   volIdx - index, starting with 0
%   outFilePath - filepath to save out roi betas to. Default outFilePath is: 
%         fullfile(resultsDir,'roi_betas',roiStr,[volStr '.csv']); e.g.: 
%         ~/cueexp/data/results_mid_afni/roi_betas/nacc_desai/gvnant.csv
%         If 0, then betas will be returned but not saved out. (NOT YET
%         IMPLEMENTED)

% OUTPUT:
%   betas - vector of roi beta values
% 
% NOTES:
% 
% add compatiblity to give 0 for outFilePath to NOT save out roi betas 
% 
% author: Kelly, kelhennigan@gmail.com, 01-Feb-2017

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % make sure that the path to afni bin is set in the system search path
% afnibin_path = '~/abin'; % EDIT AS NEEDED - this should be the directory where afni commands are located 
% ext_path=getenv('PATH');
% if isempty(strfind(ext_path,afnibin_path))
%     setenv('PATH', [ext_path ':' afnibin_path])
% end
% !echo $PATH 


%%%%% roi file path
if notDefined('roiFilePath')
    error('must provide an roi nifti filepath');
end


% which subjects to process? 
if notDefined('subjects')
    error('must provide cell array of subject ids');
end
if ischar(subjects)
    subjects = {subjects};
end
if size(subjects,1)==1 && size(subjects,2)>1
    subjects=subjects';
end

% which results directory to get betas from? 
if notDefined('resultsDir')
    p = getCuePaths();
    cd(p.data);
    a=dir('*results*');
    fprintf('\nfound results directories: \n\n');
    dir_list=cellfun(@(x) [x '\n '], vertcat({a(:).name}), 'UniformOutput',0)';
    fprintf([dir_list{:}]);
    resultsDir = input('\nenter a results directory: ','s');
end

cd(resultsDir);

% provide a file string to ID files of interest:
if notDefined('fileStr')
    fprintf('\nfiles in pwd: \n\n');
    ls
    fileStr = input('\nenter a file string to ID files of interest: ','s');
end

a=dir(['*' fileStr '*']);

% which volume to pull out? 
if notDefined('volIdx')
    fprintf('\nfile info: \n\n');
    system(['3dinfo -verb ' a(1).name]);
    volIdx = input('\nwhich volume to process (1st vol is zero, etc.): ');
end
  
    
% if outFilePath isn't given, suggest default save out filepath: 
if notDefined('outFilePath')
    
    % get roi name
    [~,roiStr,~]=fileparts(roiFilePath);
    roiStr= strrep(roiStr,'_func','');
    
    % get beta name
    [~,volStr]= system(['3dinfo -label ' a(1).name '[' num2str(volIdx) ']']);
    i=regexp(volStr,'#'); volStr(i:end)=[];
    
    outFilePath = fullfile(resultsDir,'roi_betas',roiStr,[volStr '.csv']);
    fprintf(['\n\n saving out roi betas to:\n' outFilePath]);
 
end

% if outFilePath is given without a file extension, add csv
[~,~,fext] = fileparts(outFilePath);
if isempty(fext)
    outFilePath = [outFilePath '.csv'];
end

% if file outFilePath already exists, let the user know: 
while exist(outFilePath,'file')
    fprintf(['\n file, ' outFilePath ' already exists.\n'])
    w=input('enter 1 to write over file, or 2 to change out file name: ');
    if w==1
        delete(outFilePath);
    elseif w==2
        outFilePath = input('\nenter a new name for the out file: ','s');
    end
end

% create directories for saving out file, if they don't already exist
[outDir,~]=fileparts(outFilePath)
if ~exist(outDir,'dir')
    mkdir(outDir);
end




%% do it

% get cell array of all files with fileStr
fnames=[{a(:).name}];

tempFile = tempname; % get a temp file to save out betas to

for i=1:numel(subjects)
    
    subject = subjects{i};
    
    idx=find(strncmp(subject,fnames,8));
    if numel(idx)>1
        fprintf(['\nmore than 1 file found for subject, ' subject ' \n\n']);
        disp(fnames(idx));
        this_idx=input('which file to use? Enter 1,2, etc.: ');
        idx = idx(this_idx);
    elseif numel(idx)<1
        error(['no file found for subject, ' subject ' \n\n']);
    end
        
    subj_file = fnames{idx};    
    cmd = ['3dmaskave -mask ' roiFilePath ' -quiet -mrange 1 2 ' ...
        '-dindex ' num2str(volIdx) ' ' subj_file ' >> ' tempFile];
    system(cmd);
    
end
        
    
%% load betas and save outFilePath fileStr with subjects as first column

betas=dlmread(tempFile);
T = table(subjects,betas);
writetable(T,outFilePath,'WriteVariableNames',0);
    
    
    
    
    
    
    
    
    
    
    
    
    