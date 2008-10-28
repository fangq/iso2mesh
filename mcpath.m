function binname=mcpath(fname)
% tempname=mcpath(fname)
% return a command file name by prepending meshing command directory path
% parameters:
%    fname: input, a file name string
%    tempname: output, full file name located in the bin directory

userpath=evalin('base','exist(''ISO2MESH_BIN'')');
if(userpath==1) 
	p=evalin('base','ISO2MESH_BIN'); 
else
	p=[];
end
tempname=[];
if(isempty(p) | ~exist(p))
	binname=fname;
else
	binname=[p filesep fname];
end
