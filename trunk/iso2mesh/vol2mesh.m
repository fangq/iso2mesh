function [node,elem,bound]=vol2mesh(img,ix,iy,iz,opt,maxvol,dofix,method)
%   [node,elem,bound]=vol2mesh(img,ix,iy,iz,opt,maxvol,dofix,method)
%   convert a binary (or multi-valued) volume to tetrahedral mesh
%
%   author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%   inputs:
%          img: a volumetric binary image
%          ix,iy,iz: subvolume selection indices in x,y,z directions
%          opt: as defined in vol2surf.m
%          maxvol: target maximum tetrahedral elem volume
%          dofix: 1: perform mesh validation&repair, 0: skip repairing
%
%   outputs:
%          node: output, node coordinates of the tetrahedral mesh
%          elem: output, element list of the tetrahedral mesh, the last 
%               column is the region id
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
