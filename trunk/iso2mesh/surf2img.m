function img=surf2img(node,face,xi,yi,zi)
%   img=surf2img(node,face,xi,yi,zi)
%
%   convert a triangular surface to a shell of voxels in a 3D image
%
%   author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%   input:
%          node: node list of the triangular surface, 3 columns for x/y/z
%          face: triangle node indices, each row is a triangle
%          xi,yi,zi: x/y/z grid for the resulting volume
%   output:
%          img: a volumetric binary image at position of ndgrid(xi,yi,zi)
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

img=surf2imgz(node,face,xi,yi,zi);
img=img | shiftdim(surf2imgz(node(:,[3 1 2]),face,zi,xi,yi),1);
img=img | shiftdim(surf2imgz(node(:,[2 3 1]),face,yi,zi,xi),2);

