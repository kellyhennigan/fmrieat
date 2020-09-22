%% script to create ROI mask nifti files using freesurfer's
% segmentation file

% for Freesurfer label values, see here: 
% http://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/AnatomicalROI/FreeSurferColorLUT


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Striatum %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% L and R NAcc - 26/58
% L and R Caudate - 11/50
% L and R Putamen - 12/51

% roiNames = {'nacc';
%     'caudate';
%     'putamen'};
% 
% 
% labels = {26,58;
%     11,50;
%     12,51}; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Frontal Cortex %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% L and R caudalanteriorcingulate - 1002/2002
% L and R caudalmiddlefrontal - 1003/2003
% L and R lateralorbitofrontal - 1012/2012
% L and R medialorbitofrontal - 1014/2014
% L and R parsopercularis - 1018/2018
% L and R parsorbitalis - 1019/2019
% L and R parstriangularis - 1020/2020
% L and R precentral - 1024/2024
% L and R rostralanteriorcingulate - 1026/2026
% L and R rostralmiddlefrontal - 1027/2027
% L and R superiorfrontal - 1028/2028
% L and R frontalpole - 1032/2032
% 
% roiNames = {'caudalanteriorcingulate';
%     'caudalmiddlefrontal';
%     'lateralorbitofrontal';
%     'medialorbitofrontal';
%     'parsopercularis';
%     'parsorbitalis';
%     'parstriangularis';
%     'precentral';
%     'rostralanteriorcingulate';
%     'rostralmiddlefrontal';
%     'superiorfrontal';
%     'frontalpole'};
% 
% labels = {1002,2002;
%     1003,2003;
%     1012,2012;
%     1014,2014;
%     1018,2018;
%     1019,2019;
%     1020,2020;
%     1024,2024;
%     1026,2026;
%     1027,2027;
%     1028,2028;
%     1032,2032};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Other structures of interest %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% L and R amygdala - 18/54
% L and R hippocampus - 17/53
% L and R insula - 19/55;
% L and R ventral DC  - 28/60
% L and R thalamus (proper)  - 10/49

% roiNames = {'hippocampus';
%     'amygdala';
%     'insula';
%     'ventralDC'
%     'thalamus'};
%
% labels = {17,53;
%     18,54;
%     19,55;
%     28,60;
%     10,49};
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define base directory, subject folders, freesurfer labels, and ROI names

clear all
close all

p=getFmrieatPaths;
subjects=getFmrieatSubjects();

dataDir = p.derivatives;

% path to freesurfer segmentation file; %s is subject id
segFilePath = fullfile(dataDir,'%s','anat_proc','aparc+aseg.nii.gz');  % subject's aparc+aseg nii file
%segFilePath = fullfile(dataDir,'%s','anat_proc','aparc.a2009s+aseg.nii.gz');  % subject's aparc.a2009s+aseg.nii.gz file for vlpfc / ains parcellation from Destrieux atlas

t1FilePath = fullfile(dataDir,'%s','anat_proc','t1_acpc.nii.gz');  % subject's acpc-aligned t1 file

% %s is subject id
outDir = fullfile(dataDir,'%s','ROIs');

% roiNames & corresponding labels from FS segmentation (aparc+aseg.nii.gz)
roiNames = {'amygdala'};
%    {'nacc';
%     'caudate';
%     'putamen';
%     'amygdala';
%     'insula'};

% corresponding labels for left and right hemispheres
labels = {18,54};
%   {26,58};
%    11,50;
%    12,51;
%    18,54;
%    19,55};

% These areas are from a differen FS segmentation file
% (aparc.a2009s+aseg.nii.gz)
%  roiNames = {'vlpfc';
%     'ains';
%     'sgins'};

% labels correspond with vlpfc / ains areas contained in different FS
% segmentation file
%  labels = {11113,12113;     %vlpfc
%            11148,12148;     %ains
%            11118,12118};    %shortins
%        
% roiNames_comb = 'asgins'; 


%% Get to it

for i = 1:length(subjects)          % subject loop
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    fprintf(['\n\n***subject number ' num2str(i) '***\n\n']);
    
    subjSegFilePath = sprintf(segFilePath,subject);
    subjT1FilePath = sprintf(t1FilePath,subject);
  
    % define this out dir if it doesn't already exist
    thisOutDir = sprintf(outDir,subject);
    if ~exist(thisOutDir,'dir')
        mkdir(thisOutDir)
    end
    
    for j = 1:numel(roiNames)

        % save out left ROI
        roiName=roiNames{j};
        labelL=labels{j,1};
      
        outNameL=fullfile(thisOutDir,[roiNames{j} 'L']);
        dtiConvertFreeSurferRoiToMat(subjSegFilePath,labelL,outNameL);
        roiL=roiMatToNifti(outNameL,subjT1FilePath,1);
        
        % save out right ROI
        labelR=labels{j,2};
      
        outNameR=fullfile(thisOutDir,[roiNames{j} 'R']);
        dtiConvertFreeSurferRoiToMat(subjSegFilePath,labelR,outNameR);
        roiR=roiMatToNifti(outNameR,subjT1FilePath,1);

        %  now combine L & R and save out
        roi = createNewNii(roiL,[thisOutDir '/' roiName ]);
        roi.data = roiL.data+roiR.data;
        if any(roi.data(:)>1)
            error(['hold up - L and R ' roiNames{j} ' have overlappling voxels, which shouldn''t happen...'])
        end
        writeFileNifti(roi);
        roiNiftiToMat(roi,1);
        
          
    end % rois
    
    
%         % COMMENT IN / OUT
%         % Now combine ains and sgins
%         % Note: files for combining are hardcoded, adapt file name as required
%         
%         roiName=roiNames_comb;
%         
%          % save out left combined ROI
%         roi_comb_L = createNewNii(subjT1FilePath,[thisOutDir '/' roiName 'L' ]);
%         roi_1_L = niftiRead(fullfile(thisOutDir, 'ainsL.nii.gz'));
%         roi_2_L = niftiRead(fullfile(thisOutDir, 'sginsL.nii.gz'));
%         roi_comb_L.data = roi_1_L.data+roi_2_L.data;
%         if any(roi_comb_L.data(:)>1)
%             error(['hold up - ainsL and sginsL have overlappling voxels, which shouldn''t happen...'])
%         end
%         writeFileNifti(roi_comb_L);
%         roiNiftiToMat(roi_comb_L,1);
%         
%         roi_comb_R = createNewNii(subjT1FilePath,[thisOutDir '/' roiName 'R' ]);
%         roi_1_R = niftiRead(fullfile(thisOutDir, 'ainsR.nii.gz'));
%         roi_2_R = niftiRead(fullfile(thisOutDir, 'sginsR.nii.gz'));
%         roi_comb_R.data = roi_1_R.data+roi_2_R.data;
%         if any(roi_comb_R.data(:)>1)
%             error(['hold up - ainsR and sginsR have overlappling voxels, which shouldn''t happen...'])
%         end
%         writeFileNifti(roi_comb_R);
%         roiNiftiToMat(roi_comb_R,1);
%         
%         roi_comb = createNewNii(subjT1FilePath,[thisOutDir '/' roiName]);
%         roi_1 = niftiRead(fullfile(thisOutDir, 'ains.nii.gz'));
%         roi_2 = niftiRead(fullfile(thisOutDir, 'sgins.nii.gz'));
%         roi_comb.data = roi_1.data+roi_2.data;
%         if any(roi_comb.data(:)>1)
%             error(['hold up - ains and sgins have overlappling voxels, which shouldn''t happen...'])
%         end
%         writeFileNifti(roi_comb);
%         roiNiftiToMat(roi_comb,1);
  
    %fprintf(['done with subject ' subject '.\n\n']);  
    fprintf(['\n\n***done with subject number ' num2str(i) '***\n\n']);
      
end % subjects
