% insight analysis

clear all
close all

p=getFmrieatPaths; 
dataDir = p.derivatives; 

subjects=getFmrieatSubjects('cue');

[valence, arousal, pa, na, familiarity, image_types] = getQualtricsData(subjects);

% check out variance in PA ratings

conds = {'alcohol','drugs','food','neutral'};

%% check variance 

for j=1:numel(conds)
    for i=1:numel(subjects)
        
        varpa(i,j) = var(pa(i,image_types==j));
    end
end

%% save out as csv files

cd(dataDir);
cd PANAratings

T=table([subjects],pa);
writetable(T,'pa.csv');

T=table([subjects],na);
writetable(T,'na.csv'); 

T=table([subjects],valence);
writetable(T,'valence.csv'); 

T=table([subjects],arousal);
writetable(T,'arousal.csv'); 

T=table([subjects],familiarity);
writetable(T,'familiarity.csv'); 
