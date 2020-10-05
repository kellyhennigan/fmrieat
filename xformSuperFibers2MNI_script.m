% xform subject's superfiber coordinates to tlrc space


clear all
close all


% [p,task,subjects,gi]=whichCueSubjects('stim','dti');
p=getFmrieatPaths();
task='dti';
dataDir = p.derivatives;
subjects=getFmrieatSubjects(task); 

group='';

method = 'mrtrix_fa';

fgMDir = fullfile(dataDir,'fgMeasures',method);

% fgMNames = {'DAL_naccL_belowAC_autoclean';
%     'DAR_naccR_belowAC_autoclean';
%     'DAL_naccL_aboveAC_autoclean';
%     'DAR_naccR_aboveAC_autoclean';
%     'DAL_caudateL_autoclean';
%     'DAR_caudateR_autoclean';
%     'DAL_putamenL_autoclean';
%     'DAR_putamenR_autoclean'};
fgMNames = {'PauliAtlasDAL_naccL_belowAC_autoclean'};

    
t1Path = fullfile(dataDir,'templates','mni_icbm152_t1_tal_nlin_asym_09a_brain.nii');

% define subject-specific filepaths for affine & warp xforms from native to tlrc space
xform_aff=fullfile(dataDir,'%s','anat_proc','t12mni_xform_Affine.txt');
xform_invWarp=fullfile(dataDir,'%s','anat_proc','t12mni_xform_InverseWarp.nii.gz');

outDir = fullfile(dataDir,'superfibers_mni');
if ~exist(outDir,'dir')
    mkdir(outDir);
end

%% get coords from desired node of fiber group & convert to tlrc space

t1=niftiRead(t1Path); % load background image


for j=1:numel(fgMNames)
    
    fgMName=fgMNames{j}; 
    
    fgMFile=fullfile(fgMDir,[fgMName '.mat']);
    
    outName=[fgMName '_group_mni' ];

    [fgMeasures,fgMLabels,scores,subjects,gi,SuperFibers]=loadFGBehVars(...
        fgMFile,'',group);


i=1
for i=1:size(subjects)
    
    subject = subjects{i};
    
    fprintf('\nworking on subject %s...\n',subject)
    
    % % get subject's node coords in group space  
fgcoords_mni{i,1} = xformCoordsANTsMovingToFixed(SuperFibers(i).fibers{1},...
        sprintf(xform_aff,subject),...
        sprintf(xform_invWarp,subject))';
    
    fprintf('\ndone.\n')
    
end % subject loop

% save out as fiber group
fg = dtiNewFiberGroup(outName, [],[],1,fgcoords_mni);
mtrExportFibers(fg,fullfile(outDir,outName));

% save out as density map
% fd = dtiComputeFiberDensityNoGUI(fg, t1.qto_xyz,size(t1.data),1,1,0);
% ni=createNewNii(t1,fd,fullfile(outDir,outName),'fiber density');
% writeFileNifti(ni);

% save out coords as .mat file
save(fullfile(outDir,[outName '.mat']),'fgcoords_mni');


end % fg loop


