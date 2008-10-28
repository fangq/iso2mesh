function tempname=mwpath(fname)
% tempname=meshtemppath(fname)
% return a temporarily file name by appending meshing working directory path
% parameters:
%    fname: input, a file name string
%    tempname: output, full file name located in the working directory

p=getvarfrom('base','ISO2MESH_TEMP');
session=getvarfrom('base','ISO2MESH_SESSION');

tempname=[];
if(isempty(p) | ~exist(p))
	tempname=[tempdir filesep session fname];
else
	tempname=[p filesep session fname];
end
