function [node,elem,bound]=vol2mesh(img,ix,iy,iz,opt,maxvol,dofix,method)
%   convert a binary (or multi-valued) volume to tetrahedral mesh
%   author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%   inputs:
%          img: a volumetric binary image
%          ix,iy,iz: subvolume selection indices in x,y,z directions
%          opt: additional parameters
%            opt=a float less than 1: compression rate for surf. simplification
%            opt.keeyratio=a float less than 1: same as above, same for all surf.
%            opt(1,2,..).keeyratio: setting compression rate for each levelset
%            opt(1,2,..).surf.{node,elem}: add additional surfaces
%            opt(1,2,..).{A,B}: linear transformation for each surface
%          maxvol: target maximum tetrahedral elem volume
%          dofix: 1: perform mesh validation&repair, 0: skip repairing
%          node: output, node coordinates of the tetrahedral mesh
%          elem: output, element list of the tetrahedral mesh
%          bound: output, mesh surface element list of the tetrahedral mesh
%               the last column denotes the boundary ID

%first, convert the binary volume into isosurfaces
if(nargin==8)
	[no,el,regions,holes]=vol2surf(img,ix,iy,iz,opt,dofix,method);
else
        [no,el,regions,holes]=vol2surf(img,ix,iy,iz,opt,dofix,'cgalsurf');
end
%then, create volumetric mesh from the surface mesh
[node,elem,bound]=surf2mesh(no,el,[],[],1,maxvol,regions,holes);


%some final fix and scaling
node=node-1; % because we padded the image with a 1 voxel thick null layer in newimg

dim=(size(img));
node(:,1)=node(:,1)*(max(ix)-min(ix)+1)/dim(1)+(min(ix)-1);
node(:,2)=node(:,2)*(max(iy)-min(iy)+1)/dim(2)+(min(iy)-1);
node(:,3)=node(:,3)*(max(iz)-min(iz)+1)/dim(3)+(min(iz)-1);
