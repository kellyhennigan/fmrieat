function [valence, arousal, pa, na, familiarity, image_types] = getQualtricsData(subjects)

% from the 'Cue_fMRI_subjects' gsheet
% docid = '1wcYTCKhouZ8Cf8omTFQMkekxcJn0lVBKi9ApPHTR3ak'; % doc id for google sheet w/relapse data
docid='1HYLKyy6YfidMKjrLA2R5HSv8hmFgtHy7iUjh6I_IGkQ';

% try to load spreadsheet; if it can't be loaded, return age var as empty
try
    d = GetGoogleSpreadsheet(docid); % load google sheet as cell array
    
catch
    warning(['\ngoogle sheet couldnt be accessed, probably bc your offline.' ...
        'returning age var as empty...']);
    return
    
end

% get column indices for Valence Arousal Familiarity
validx=find(strncmp(d(1,:),'Valence',3));
aroidx=find(strncmp(d(1,:),'Arousal',3));
famidx=find(strncmp(d(1,:),'Familiarity',3));


i=1
for i=1:numel(subjects)
    
    i
    if strcmp(subjects{i},'ss190122')
        
        fprintf('\n skipping subjet ss190122 for now - figure this out later!\n\n');
        ri=[];
        
    else
        
        % get row for this subject
        if strcmp(subjects{i},'rs181219')
            ri=find(strcmp('rs1811219',d(:,1)));
        elseif strcmp(subjects{i},'ty190110')
            ri=find(strcmp('ty190109',d(:,1)));
        else
            ri=find(strncmp(d(:,1),subjects{i},numel(subjects{i}))); % row w/this subject's data
            if numel(ri)>1
                error('hold up!');
            end
        end
        
    end
    
    if isempty(ri)
        
        
        %         error('wait!! theres a problem');
        valence(i,:)=nan(size(valence,2),1);
        arousal(i,:)=nan(size(arousal,2),1);
        familiarity(i,:)=nan(size(familiarity,2),1);
        pa(i,:)=nan(size(pa,2),1);
        na(i,:)=nan(size(na,2),1);
    else
        valence(i,:) = str2num(cell2mat(d(ri,validx)'))';
        arousal(i,:) = str2num(cell2mat(d(ri,aroidx)'))';
        familiarity(i,:) = str2num(cell2mat(d(ri,famidx)'))';
        [pa(i,:),na(i,:)]=va2pana(valence(i,:),arousal(i,:));
        
    end
    
    
end % subjects

% hard-coded image types, 1=alcohol, 2=drug, 2=foood, 4=neutral
% DOUBLE CHECK THIS !!!!!!
image_types = [1 2 3 4 1 2 1 4 4 2 3 1 4 3 4 2 3 3 3 4 2 1 1 2 2 3 2 3 ...
    1 4 4 4 3 1 4 4 1 2 1 3 2 1 2 3 4 1 3 2 1 3 2 3 4 4 3 2 2 3 3 1 4 2 ...
    1 2 4 1 2 3 4 1 4 1];


% reorder the qualtrics ratings to be in the same order as
% they were presented during the cue task in the scanner

reorder_idx = [23 15 22 21 3 28 45 6 33 12 7 10 37 30 5 55 24 65 43 52 ...
    16 50 58 1 27 39 59 38 2 71 41 61 53 34 29 54 56 68 25 69 13 72 64 ...
    14 18 42 4 60 46 17 20 48 8 63 9 66 11 32 19 57 44 35 40 62 31 51 26 ...
    47 49 70 36 67];

valence=valence(:,reorder_idx);
arousal=arousal(:,reorder_idx);
pa = pa(:,reorder_idx);
na = na(:,reorder_idx);
familiarity = familiarity(:,reorder_idx);
image_types = image_types(reorder_idx);





end % function

















