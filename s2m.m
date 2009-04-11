function [node,elem,face]=s2m(v,f,keepratio,maxvol)
%   [node,elem,face]=s2m(v,f,keepratio,maxvol)
%   short-hand version of surf2mesh
%
%   author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%
%   inputs and outputs are similar to those defined in surf2mesh
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

p0=min(v);
p1=max(v);
[node,elem,face]=surf2mesh(v,f,p0,p1,keepratio,maxvol,[],[]);

