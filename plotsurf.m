function hm=plotsurf(node,face,varargin)
%
% hm=plotsurf(node,face,opt)
%
% plot 3D surface meshes
% 
% author: Qianqian Fang <fangq at nmr.mgh.harvard.edu>
%
% input: 
%      node: node coordinates, dimension (nn,3)
%      face: triangular surface face list
%      opt:  additional options for the plotting, see trisurf
%
% output:
%   hm: handle or handles (vector) to the plotted surfaces
%
% example:
%
%   h=plotsurf(node,face);
%   h=plotsurf(node,face,'facecolor','r');
% 
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if(nargin>=2)
    if(size(face,2)==4)
        randseed=hex2dec('623F9A9E'); % "U+623F U+9A9E"
        if(~isempty(getvarfrom('base','ISO2MESH_RANDSEED')))
                randseed=getvarfrom('base','ISO2MESH_RANDSEED');
        end
        rand('state',randseed);
        
        tag=face(:,4);
		types=unique(tag);
        hold on;
		h=[];
        for i=1:length(types)
            h=[h plotasurf(node,face(find(tag==types(i)),1:3),'facecolor',rand(3,1),varargin{:})];
        end
    else
        h=plotasurf(node,face,varargin{:});
    end
end    
if(~isempty(h)) 
  axis equal;
  if(all(get(gca,'view')==[0 90]))
      view(3);
  end
end
if(~isempty(h) & nargout>=1)
  hm=h;
end

%-------------------------------------------------------------------------
function hh=plotasurf(node,face,varargin)
if(nargin<3)
	if(isoctavemesh)
		h=trimesh(face(:,1:3),node(:,1),node(:,2),node(:,3));
	else
		h=trisurf(face(:,1:3),node(:,1),node(:,2),node(:,3));
	end
else
        if(isoctavemesh)
                h=trimesh(face(:,1:3),node(:,1),node(:,2),node(:,3),varargin{:});
        else
                h=trisurf(face(:,1:3),node(:,1),node(:,2),node(:,3),varargin{:});
        end
end
if(h) hh=h; end