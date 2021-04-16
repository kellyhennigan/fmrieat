% script to regress out nuisance regressors and save out the err ts

clear all
close all

%% define initial stuff

p=getFmrieatPaths;
task='cue';
subjects=getFmrieatSubjects(task);

dataDir = p.derivatives;


 afniStr = '_afni'; % '_afni' to use afni xform version, '' to use ants version

 
% define file path to nuisance regressors & corresponding names
nuisance_regfiles{1} = fullfile(dataDir,'%s','func_proc',[task '_vr.1D']);
nuisance_regidx{1} = [2:7]; % column index for which vectors to use within each regfile
nuisance_regfiles{2} = fullfile(dataDir,'%s','func_proc',[task '_csf_ts.1D']);
nuisance_regidx{2} = 1; 
nuisance_regfiles{3} = fullfile(dataDir,'%s','func_proc',[task '_wm_ts.1D']);
nuisance_regidx{3} = 1; 

nuisanceRegNames = {'dx','dy','dz','roll','pitch','yaw','csf','wm'};

% number of degrees of polynomial baseline regressors *PER RUN*
nDPolyRegs=2; %


outFilePath = fullfile(dataDir,'%s','func_proc',['pp_' task '_tlrc_nuisance_designmat.txt']);


%% do it

switch task
    
    case 'cue'
        
        nTRsPerRun=436;
        nTRs=sum(nTRsPerRun);
        
%     case 'mid'
%         
%         nTRsPerRun=[256 292];
%         nTRs=sum(nTRsPerRun);
%         
%     case 'midi'
%         
%         nTRsPerRun=[292 292];
%         nTRs=sum(nTRsPerRun);
%         
        
end


i=1;
for i=1:numel(subjects) % subject loop
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
        % get baseline polynomial regressors
        baseregs=modelBaseline(nTRs,nDPolyRegs);
        baseRegNames=[];
        for j=1:size(baseregs,2)
            baseRegNames=[baseRegNames {['base' num2str(j)]}];
        end
        
        % get nuisance regressors 
        for j=1:numel(nuisance_regfiles)
            temp = dlmread(sprintf(nuisance_regfiles{j},subject));
            baseregs = [baseregs, temp(:,nuisance_regidx{j})];
        end
        baseRegNames=[baseRegNames nuisanceRegNames];
        
        % define design matrix w/intercept and nuisance regs
        baseregs = array2table(baseregs,'VariableNames',baseRegNames);
        
        writetable(baseregs,sprintf(outFilePath,subject));
        
        fprintf('done.\n\n');
    
end % subjects

