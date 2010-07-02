function hm=plottetra(node,elem,varargin)
%
% hm=plottetra(node,elem,opt)
%
% plot 3D surface meshes
% 
% author: Qianqian Fang <fangq at nmr.mgh.harvard.edu>
%
% input: 
%      node: node coordinates, dimension (nn,3)
%      elem: tetrahedral element list
%      opt:  additional options for a patch object
%
% output:
%   hm: handle or handles (vector) to the plotted surfaces
%
% example:
%
%   h=plottetra(node,elem);
%   h=plottetra(node,elem,'facealpha',0.5);
% 
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if(~iscell(elem))
	if(size(elem,2)>4)
		tag=elem(:,5);
		types=unique(tag);
		hold on;
		h=[];
		for i=1:length(types)
			idx=find(tag==types(i));
			face=volface(elem(idx,1:4));
			h=[h plotsurf(node,face,'facecolor',rand(3,1))];
		end
	else
		face=volface(elem(:,1:4));
		if(nargin<3) 
			h=plotsurf(node,face);
		else
                        h=plotsurf(node,face,varargin{:});
		end
	end
end

if(~isempty(h) & nargout>=1)
  hm=h;
end
