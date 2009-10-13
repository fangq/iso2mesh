function openedge=surfedge(f)
% openedge=surfedge(f)
%
% surfedge: find the edge of an open surface
%
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/11/21
%
% parameters:
%      f: input, surface face element list, dimension (be,3)
% output:
%      openedge: list of edges of the specified surface
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if(size(f,2)==3)
    edges=[f(:,[1,2]);
           f(:,[2,3]);
           f(:,[1,3])];             % create all the edges
elseif(size(f,2)==4)
    edges=[f(:,[1,2,3]);
           f(:,[1,2,4]);
           f(:,[1,3,4]);
           f(:,[2,3,4])];             % create all the edges
else
    error('surfedge only support 2D and 3D elements');
end
% node4=[f(:,3);f(:,2);f(:,1)];   % node idx concatinated
edges=sort(edges,2);
[foo,ix,jx]=unique(edges,'rows');

if(isoctavemesh)
        u=unique(jx);
	qx=u(hist(jx,u)==1);
else
	vec=histc(jx,1:max(jx));
	qx=find(vec==1);
end
openedge=edges(ix(qx),:);
% node4=node4(ix(qx));
