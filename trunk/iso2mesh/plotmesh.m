function hm=plotmesh(node,varargin)
%
% hm=plotmesh(node,face,elem,opt)
%
% plot surface and volumetric meshes
% 
% author: Qianqian Fang <fangq at nmr.mgh.harvard.edu>
%
% input: 
%      node: a node coordinate list, 3 columns for x/y/z
%      face: a triangular surface face list
%      elem: a tetrahedral element list
%      opt:  additional options for the plotting
%
%            for simple point plotting, opt can be markers
%            or color options, such as 'r.', or opt can be 
%            a logic statement to select a subset of the mesh,
%            such as 'x>0 & y+z<1'; opt can have more than one
%            items to combine these options, for example: 
%            plotmesh(...,'x>0','r.'); the range selector must
%            appear before the color/marker specifier
%
% output:
%   hm: handle or handles (vector) to the plotted surfaces
%
% example:
%
%   h=plotmesh(node,'r.');
%   h=plotmesh(node,'x<20','r.');
%   h=plotmesh(node,face);
%   h=plotmesh(node,face,'y>10');
%   h=plotmesh(node,face,'facecolor','r');
%   h=plotmesh(node,elem,'x<20');
%   h=plotmesh(node,elem,'x<20 & y>0');
%   h=plotmesh(node,face,elem);
%   h=plotmesh(node,face,elem,'linestyle','--');
% 
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

selector=[];
opt=[];
face=[];
elem=[];

if(nargin>1)
   hasopt=0;
   for i=1:length(varargin)
   	if(ischar(varargin{i}))
		if(regexp(varargin{i},'[0-9&|]'))
			selector=varargin{i};
			if(nargin>=i+1) opt=varargin(i+1:end); end
		else
			opt=varargin(i:end);
		end
		if(i==1)
			face=[];elem=[];
		elseif(i==2)
			if(iscell(varargin{1}) | size(varargin{1},2)<4 || (size(varargin{1},2)==4 & max(varargin{1}(:,4))<10) )
				face=varargin{1}; elem=[];
			else
				elem=varargin{1}; face=[];
			end
		elseif(i==3)
			face=varargin{1};
			elem=varargin{2};
		end
		hasopt=1;
		break;
	end
   end
   if(hasopt==0)
   	if(length(varargin)>=2)
		face=varargin{1};
		elem=varargin{2};
		if(length(varargin)>2) opt=varargin(3:end); end
	elseif(iscell(varargin{1}) | size(varargin{1},2)<4)
		face=varargin{1}; elem=[];
	else
		elem=varargin{1}; face=[];
	end
   end
end

if(isempty(face) & isempty(elem))
   if(isempty(selector))
        if(isempty(opt))
   		h=plot3(node(:,1),node(:,2),node(:,3),'o');
	else
   		h=plot3(node(:,1),node(:,2),node(:,3),opt{:});
	end
   else
	x=node(:,1);
	y=node(:,2);
	z=node(:,3);
	idx=eval(['find(' selector ')']);
        if(~isempty(idx))
	    if(isempty(opt))
		h=plot3(node(idx,1),node(idx,2),node(idx,3),'o');
	    else
		h=plot3(node(idx,1),node(idx,2),node(idx,3),opt{:});
	    end
	end
   end
end

if(~isempty(face))
   hold on;
   if(isempty(selector))
        if(isempty(opt))
   		h=plotsurf(node,face);
	else
   		h=plotsurf(node,face,opt);
	end
   else
	cent=meshcentroid(node,face(:,1:3));
	x=cent(:,1);
        y=cent(:,2);
	z=cent(:,3);
        idx=eval(['find(' selector ')']);
        if(~isempty(idx))
	    if(isempty(opt))
		h=plotsurf(node,face(idx,:));
	    else
		h=plotsurf(node,face(idx,:),opt);
	    end
	end
   end
end

if(~isempty(elem))
   hold on;
   if(isempty(selector))
        if(isempty(opt))
   		h=plottetra(node,elem);
	else
   		h=plottetra(node,elem,opt);
	end
   else
	cent=meshcentroid(node,elem(:,1:4));
	x=cent(:,1);
        y=cent(:,2);
	z=cent(:,3);
        idx=eval(['find(' selector ')']);
        if(~isempty(idx))
	    if(isempty(opt))
		h=plottetra(node,elem(idx,:));
	    else
		h=plottetra(node,elem(idx,:),opt);
	    end
	end
   end
end

if(~isempty(h) & nargout>=1)
  hm=h;
end
