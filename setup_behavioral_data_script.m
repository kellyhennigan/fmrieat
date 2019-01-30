% script to set up behavioral data for cue reactivity study


% TO DO:

% -make sure that saving out with writetable() produces same result as
% previous stim files

%%
p=getFmrieatPaths; % get experiment paths

rawDir = '/Users/kelly/Google Drive/fmrieat';

doOverwrite=1; % 1 to overwrite files while copying stim files, 0 to not overwrite

% input subject id:
subjid = input('enter subject id: ','s');

%%

for i=1:numel(subjects)
    
    subjid=subjects{i};
    
    fprintf(['\nworking on subject ' subjid '\n\n']);
    
    % make subject behavior dir if it doesn't exist
    subjOutDir = fullfile(p.source,subjid,'behavior');
    if ~exist(subjOutDir,'dir')
        mkdir(subjOutDir);
    end
    
    
    %% CUE TASK
    
    %%%%%%%%%%%% stim timing file
    inFile = [subjid '_m.csv'];
    inPath = fullfile(rawDir,'task_files','data',inFile);
    outPath = fullfile(subjOutDir,'cue_matrix.csv');
    
    % check that stim file exists
    if exist(inPath,'file')
        
        % make sure it has the right # of rows
        T=readtable(inPath,'Delimiter',',','ReadVariableNames',true);
        if size(T,1)==432
            fprintf('\n\ncue stim file looks good!\n');
            
            % check if outfile already exists
            if exist(outPath,'file')
                if doOverwrite
                    fprintf(['\n copying over pre-existing file: ' outPath '...\n']);
                    copyfile(inPath,outPath);
                else
                    fprintf(['\nfile: ' outPath '\n already exists; NOT overwriting...\n']);
                end
            else
                copyfile(inPath,outPath);
            end
            
        else
            fprintf(['\n\ncue stim file:\n' inFile '\nhas unexpected # of rows...manually check this!\n']);
           
        end
        
    else
        fprintf(['\n\ncouldnt find cue stim file:\n' inFile '\ncheck filename for typos, etc.\n']);
      
    end
    
    clear inFile inPath outPath T
    
    %%%%%%%%% rating file
    inFile = [subjid '_ratings.csv'];
    inPath = fullfile(rawDir,'task_files','data',inFile);
    outPath = fullfile(subjOutDir,'cue_ratings.csv');
    
    % check that stim file exists
    if exist(inPath,'file')
        
        % make sure it has the right # of rows
        T=readtable(inPath,'Delimiter',',','ReadVariableNames',true);
        if size(T,1)==4
            fprintf('\n\ncue ratings file looks good!\n');
            
            % check if outfile already exists
            if exist(outPath,'file')
                if doOverwrite
                    fprintf(['\n copying over pre-existing file: ' outPath '...\n']);
                    copyfile(inPath,outPath);
                else
                    fprintf(['\nfile: ' outPath '\n already exists; NOT overwriting...\n']);
                end
            else
                copyfile(inPath,outPath);
            end
            
        else
            fprintf(['\n\ncue ratings file:\n' inFile '\nhas unexpected size...manually check this!\n']);
          
        end
        
    else
        
        fprintf(['\n\ncouldnt find cue ratings file:\n' inFile '\ncheck filename for typos, etc.\n']);
        
    end
    
    clear inFile inPath outPath T 
    
    fprintf(['\ndone.']);
