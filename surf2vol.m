function [img, v2smap]=surf2vol(node,face,xi,yi,zi)
%
% [img, v2smap]=surf2vol(node,face,xi,yi,zi)
%
% convert a triangular surface to a shell of voxels in a 3D image
%
% author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%
% input:
%	 node: node list of the triangular surface, 3 columns for x/y/z
%	 face: triangle node indices, each row is a triangle
%	 xi,yi,zi: x/y/z grid for the resulting volume
%
% output:
%	 img: a volumetric binary image at position of ndgrid(xi,yi,zi)
%        v2smap (optional): a 4x4 matrix denoting the Affine transformation to map
%             the voxel coordinates back to the mesh space.
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

fprintf(1,'converting a closed surface to a volumetric binary image ...\n');

img=surf2volz(node(:,1:3),face(:,1:3),xi,yi,zi);
img=img | shiftdim(surf2volz(node(:,[3 1 2]),face(:,1:3),zi,xi,yi),1);
img=img | shiftdim(surf2volz(node(:,[2 3 1]),face(:,1:3),yi,zi,xi),2);

v2smap=[];

% here we assume the grid is uniform; surf2vol can handle non-uniform grid, 
% but the affine output is not correct in this case

if(nargout>1) 
    dlen=abs([xi(2)-xi(1) yi(2)-yi(1) zi(2)-zi(1)]);
    p0=min(node);
    offset=p0;
    v2smap=diag(abs(dlen));
    v2smap(4,4)=1;
    v2smap(1:3,4)=offset';
end
