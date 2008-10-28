function [node,elem,bound]=vol2mesh(img,ix,iy,iz,opt,maxvol,dofix)
% [node,elem,bound]=vol2mesh(img,ix,iy,iz,thickness,keepratio,maxvol,A,B)
% convert a binary volume to tetrahedral mesh
% author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
% date:   2007/12/21
%
% inputs: 
%        img: a volumetric binary image 
%        ix,iy,iz: subvolume selection indices in x,y,z directions
%        opt: target surface element number after simplification
%        maxvol: target maximum tetrahedral elem volume

%first, convert the binary volume into isosurfaces
[no,el]=vol2surf(img,ix,iy,iz,opt,dofix);

%then, create volumetric mesh from the surface mesh
[node,elem,bound]=surf2mesh(no,el,[],[],1,maxvol);


%some final fix and scaling
node=node-1; % because we padded the image with a 1 voxel thick null layer in newimg

dim=(size(img));
node(:,1)=node(:,1)*(max(ix)-min(ix)+1)/dim(1)+(min(ix)-1);
node(:,2)=node(:,2)*(max(iy)-min(iy)+1)/dim(2)+(min(iy)-1);
node(:,3)=node(:,3)*(max(iz)-min(iz)+1)/dim(3)+(min(iz)-1);
