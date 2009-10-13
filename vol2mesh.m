function [node,elem,face]=vol2mesh(img,ix,iy,iz,opt,maxvol,dofix,method,isovalues)
%   [node,elem,face]=vol2mesh(img,ix,iy,iz,opt,maxvol,dofix,method,isovalues)
%   convert a binary (or multi-valued) volume to tetrahedral mesh
%
%   author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%   inputs:
%          img: a volumetric binary image
%          ix,iy,iz: subvolume selection indices in x,y,z directions
%          opt: as defined in vol2surf.m
%          maxvol: target maximum tetrahedral elem volume
%          dofix: 1: perform mesh validation&repair, 0: skip repairing
%          method: 'cgalsurf' or omit: use CGAL surface mesher
%                  'simplify': use binsurface and then simplify
%                  'cgalmesh': use CGAL 3.5 3D mesher for direct mesh generation [new]
%          isovalues: a list of isovalues where the levelset is defined
%
%   outputs:
%          node: output, node coordinates of the tetrahedral mesh
%          elem: output, element list of the tetrahedral mesh, the last 
%               column is the region id
%          face: output, mesh surface element list of the tetrahedral mesh
%               the last column denotes the boundary ID
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if(nargin>=8)
	if(strcmp(method,'cgalmesh'))
		vol=img(ix,iy,iz);
		if(length(unique(vol(:)))>64 & dofix==1)
			error([ 'it appears that you are processing a ' ...
                                'grayscale image. Currently cgalmesher ' ...
                                'does not support grayscale images. ' ...
                                'Please use "cgalsurf" method to mesh a grayscale ' ...
                                'volume. If you are certain to run cgalmesher ' ...
                                'on your data, please set dofix=0 and run this again.' ]);
		end
		[node elem,face]=cgalv2m(vol,opt,maxvol);
		return;
	end
end

%first, convert the binary volume into isosurfaces
if(nargin==8)
	[no,el,regions,holes]=vol2surf(img,ix,iy,iz,opt,dofix,method);
elseif(nargin==9)
	[no,el,regions,holes]=vol2surf(img,ix,iy,iz,opt,dofix,method,isovalues);
else
        [no,el,regions,holes]=vol2surf(img,ix,iy,iz,opt,dofix,'cgalsurf');
end
%then, create volumetric mesh from the surface mesh
[node,elem,face]=surf2mesh(no,el,[],[],1,maxvol,regions,holes);
