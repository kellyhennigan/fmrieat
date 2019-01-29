function hf = setupFig(hf,fSize)
% --------------------------------
% usage: call this to set up a matlab figure 

% INPUT:
%   hf (optional) - figure handle
%   fSize (optional) - font size
  
% OUTPUT:
%   hf - figure handle 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it 

if notDefined('hf')
    hf = figure; 
else
    hf;
end
hold on

if notDefined('fSize')
    fSize = 12;
end

set(gca,'fontName','Helvetica','fontSize',fSize);
set(gca,'box','off');
set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');



