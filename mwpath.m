function tempname=mwpath(fname)
% tempname=meshtemppath(fname)
% get full temp-file name by prepend working-directory and current session name
% author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
% parameters:
%    fname: input, a file name string
%    tempname: output, full file name located in the working directory
%
%    if global variable ISO2MESH_TEMP is set in 'base', it will use it
%    as the working directory; otherwise, will use matlab function tempdir
%    to return a working directory.
%
%    if global variable ISO2MESH_SESSION is set in 'base', it will be
%    prepended for each file name, otherwise, use supplied file name.

p=getvarfrom('base','ISO2MESH_TEMP');
session=getvarfrom('base','ISO2MESH_SESSION');

tempname=[];
if(isempty(p) | ~exist(p))
      if(isoctavemesh & tempdir=='\')
		tempname=['.'  filesep session fname];
	else
		tempname=[tempdir filesep session fname];
	end
else
	tempname=[p filesep session fname];
end
