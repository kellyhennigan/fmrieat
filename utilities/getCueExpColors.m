function colors = getCueExpColors(labels,set)
% -------------------------------------------------------------------------
% usage: returns rgb color values for plotting cue experiment results. The
% idea of having this is to keep plot colors for each stimulus consistent.
% Hard code desired colors here, then they will be used by various plotting
% scripts.


% INPUT:
%   labels - cell array of stims or groups to return colors for; options
%   are: 
    %     alcohol
    %     cig
    %     food 
    %     neutral
    %     strongdontwant
    %     somewhatdontwant
    %     strongwant
    %     somewhatwant

    %   set (optional) - either 'grayscale' or 'color' to return grayscale
    %   or colors. Default is color.
%
% OUTPUT:
%   colors - rgb values in rows for colors
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ~iscell(labels)
    labels = {labels};
end


if notDefined('set')
    set = 'color'; % either 'grayscale' or 'color'
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% define colors for all possible stims/groups here %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch set
    
    
    % define grayscale shades for each stim/group
    case 'grayscale'
        
        % stims
        alcohol_color = [75 75 75]./255; % dark gray
        drug_color = [30 30 30]./255; % grayish black
        food_color = [100 100 100]./255; % mid-gray
        neutral_color = [170 170 170]./255; % light gray
        
        % want ratings
        strongwant_color =   [30 30 30]./255; % grayish black
        somewhatwant_color =  [77 77 77]./255; % dark gray
        somewhatdontwant_color = [123 123 123]./255; % mid gray
        strongdontwant_color = [170 170 170]./255; % light gray
        
        
        % define colors for each stim/group
    case 'color'
        
        % stims
        alcohol_color =  [219 79 106]./255;       % pink
        drug_color =  [253 158 33]./255;      % orange
        food_color = [42 160 120]./255;  % green
        neutral_color = [2 117 180]./255;     % blue
      
        % want ratings
        strongwant_color =  [219 79 106]./255;       % pink
        somewhatwant_color =  [253 158 33]./255;      % orange
        somewhatdontwant_color = [42 160 120]./255;  % green
        strongdontwant_color = [2 117 180]./255;     % blue
        
        
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% determine which colors to return based on input labels %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

colors = [];
for i=1:numel(labels)
      
    switch lower(labels{i})
        
        case 'alcohol'
            colors(i,:) = alcohol_color;
            
        case {'drugs','drug'}
            colors(i,:) = drug_color;
            
        case 'food'
            colors(i,:) = food_color;
            
        case 'neutral'
            colors(i,:) = neutral_color;
     
        case {'strongwant','strong want','strong_want'}
            colors(i,:) = strongwant_color;
            
        case {'somewhatwant','somewhat want','somewhat_want'}
            colors(i,:) = somewhatwant_color;
            
        case {'somewhatdontwant','somewhat dontwant','somewhat_dontwant'}
            colors(i,:) = somewhatdontwant_color;
            
        case {'strongdontwant','strong dontwant','strong_dontwant'}
            colors(i,:) = strongdontwant_color;
            
        otherwise
            colors(i,:) = [30 30 30]./255; % return grayish black
            
    end
    
end
