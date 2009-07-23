function [no,el,regions,holes]=v2s(img,isovalues,opt,method)
% [no,el,regions,holes]=v2s(img,isovalues,opt,method)
% short-hand version of vol2surf
%
% author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%
% inputs and outputs are similar to those defined in vol2surf
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if(nargin==3)
   method='cgalsurf';
end
[no,el,regions,holes]=vol2surf(img,1:size(img,1),1:size(img,2),1:size(img,3),opt,1,method,isovalues);
