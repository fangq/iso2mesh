function [node,elem,face]=v2m(img,isovalues,opt,maxvol,method)
%   [node,elem,face]=v2m(img,isovalues,opt,maxvol,method)
%   short-hand version of vol2mesh
%
%   author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%
%   inputs and outputs are similar to those defined in vol2mesh
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

[node,elem,face]=vol2mesh(img,1:size(img,1),1:size(img,2),1:size(img,3),opt,maxvol,1,method,isovalues);
