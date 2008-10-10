function tri=surfedge(v,f)
% surfedge: find the edge of an open surface
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/11/21
%
% parameters:
%      v: input, surface node list, dimension (nn,3)
%      f: input, surface face element list, dimension (be,3)

edges=[f(:,[1,2]);
       f(:,[2,3]);
       f(:,[1,3])];             % create all the edges
node4=[f(:,3);f(:,2);f(:,1)];   % node idx concatinated
edges=sort(edges,2);
[foo,ix,jx]=unique(edges,'rows');
vec=histc(jx,1:max(jx));
qx=find(vec==1);
tri=edges(ix(qx),:);
node4=node4(ix(qx));
