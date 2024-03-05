function [node,face]=readobjmesh(fname)
%
% [node,face]=readobjmesh(fname)
%
% read Wavefront obj-formatted surface mesh files (.obj)
%
% author: Qianqian Fang, <q.fang at neu.edu>
%
% input:
%    fname: name of the .obj data file
%
% output:
%    node: node coordinates of the mesh
%    face: list of elements of the surface mesh
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

str = fileread(fname);
nodestr=regexprep(str,'[#f][^\n]+\n','');
node=textscan(nodestr,'v %f %f %f');
facestr=regexprep(regexprep(str,'[^a-eg-zA-Z][^\n]+\n',''),'f\s+([^\n]+)\n', '$1\n');
facestr=regexprep(facestr,'(\d+)(/\d+){0,2}', '\1');
face=textscan(facestr,'f %d %d %d');
node=cell2mat(node);
face=cell2mat(face);
