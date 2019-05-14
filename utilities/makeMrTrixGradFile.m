function [ ] = makeMrTrixGradFile( file_bval, file_bvec, outfile )
%EXPORTDTIDATAFORMRTRIX Takes gradient direction and strength files from
%the CNI scanner and converts them into a form that mrTrix can use for
%performing spherical deconvolution
%
% file_bval : The file containing the b values
% file_bvec : The file containing the gradient vector directions
% outfile   : The file that mrTrix will use (aka. the diffusion config file)
x = load(file_bval);
y = load(file_bvec);

z = [y;x]';

dlmwrite(outfile, z, ' ');

end

