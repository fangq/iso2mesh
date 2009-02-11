function edgemask=imedge3d(img)
% edgemask=imedge3d(img)
%
% label all voxels that has different values from its neighbors
%   by Qianqian Fang, <fangq at nmr.mgh.harvard.edu>
%
% parameters: 
%   img:  a 3D binary image
%
% outputs
%   edgemask: a 3D array with same size as img, with value 1 for voxels
%             which is different from its neighbors and 0 elsewhere
%
% note: the thickness of the edge may not necessarily 1, sometimes
% it is 2 (at the direction exiting the object), but this is fine for
% vol2surf boundary field calculation
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
% 

dim=size(img);

% find the jumps for all directions
d1=diff(img,1,1);
d2=diff(img,1,2);
d3=diff(img,1,3);
[ix,iy]=find(d1);
[jx,jy]=find(d2);
[kx,ky]=find(d3);

% compensate the dim. reduction due to diff

ix=ix+1;

[jy,jz]=ind2sub([dim(2)-1,dim(3)],jy);
jy=jy+1;
jy=sub2ind(dim(2:3),jy,jz);

[ky,kz]=ind2sub([dim(2),dim(3)-1],ky);
kz=kz+1;
ky=sub2ind(dim(2:3),ky,kz);

id1=sub2ind(dim,ix,iy);
id2=sub2ind(dim,jx,jy);
id3=sub2ind(dim,kx,ky);

allid=[id1;id2;id3];
edgemask=zeros(dim);
edgemask(allid)=1;
