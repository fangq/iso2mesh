function binname=mcpath(fname)
% tempname=mcpath(fname)
% get full executable path by prepending a command directory path
% parameters:
%    fname: input, a file name string
%    tempname: output, full file name located in the bin directory
%
%    if global variable ISO2MESH_BIN is set in 'base', it will
%    use [ISO2MESH_BIN filesep cmdname] as the command full path,
%    otherwise, let matlab pass the cmdname to the shell, which
%    will search command in the directories listed in system
%    $PATH variable.

p=getvarfrom('base','ISO2MESH_BIN');
tempname=[];
if(isempty(p) | ~exist(p))
	binname=fname;
else
	binname=[p filesep fname];
end
