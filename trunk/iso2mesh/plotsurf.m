function h=plotsurf(node,face,varargin)
% h=plotsurf(node,face,opt)
%
% plot 3D surface meshes
% 
% Author: Qianqian Fang <fangq at nmr.mgh.harvard.edu>
%
% input: 
%      node: node coordinates, dimension (nn,3)
%      face: triangular surface face list
%      opt:  additional options for the plotting, see trisurf
% 
% output:
%   h: handle or handles (vector) to the plotted surfaces
% example:
%
%   h=plotsurf(node,face);
%   h=plotsurf(node,face,'facecolor','r');
% 
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if(nargin<3)
	if(isoctavemesh)
		h=trimesh(face(:,1:3),node(:,1),node(:,2),node(:,3));
	else
		h=trisurf(face(:,1:3),node(:,1),node(:,2),node(:,3));
	end
	view(3);
else
        if(isoctavemesh)
                h=trimesh(face(:,1:3),node(:,1),node(:,2),node(:,3),varargin{:});
        else
                h=trisurf(face(:,1:3),node(:,1),node(:,2),node(:,3),varargin{:});
        end
	view(3);
end
