function [pa,na] = va2pana(valence,arousal)
% -------------------------------------------------------------------------
% usage: this function takes in valence and arousal ratings
% and returns positive arousal and negative arousal ratings
%
% if valence & arousal ratings are matrices, this function assumes subjects
% are in rows (e.g., row 1 has subject 1 ratings, etc.)
%
%
% INPUT:
%   valence - vector or matrix of valence ratings
%   arousal - vector or matrix of arousal ratings
%
% OUTPUT:
%   pa - positive arousal ratings
%   na - negative arousal ratings
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% make sure user provided ratings
if notDefined('valence') || notDefined('arousal')
    error('user must provide valence and arousal ratings');
end

% make sure the # of valence & arousal ratings are equal
if ~isequal(numel(valence),numel(arousal))
    error('# of valence and arousal ratings dont match!');
end

% if valence & arousal are column vectors, flip them
flip = 0;
if size(valence,2)==1
    valence = valence';
    flip = 1; 
end
if size(arousal,2)==1
    arousal = arousal';
end

% de-mean valence & arousal ratings across stim within subject
valence = valence - repmat(nanmean(valence,2),1,size(valence,2));
arousal = arousal - repmat(nanmean(arousal,2),1,size(arousal,2));

% transform to positive & negative arousal
pa = (arousal + valence)./sqrt(2);
na = (arousal - valence)./sqrt(2);


% if valence was given as a column vector, return pa & na as column vectors
if flip==1
    pa=pa';
    na=na';
end


