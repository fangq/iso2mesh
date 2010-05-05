function nodevol=nodevolume(elem,node)
% nodevol=nodevolume(elem,node)
%
% calculate the Voronoi volume of each node in a simplex mesh
%
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2009/12/31
%
% input:
%    elem:  element table of a mesh
%    node:  node coordinates
%
% ooutput:
%    nodevol:   volume values for all nodes
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

vol=elemvolume(elem(:,1:4),node);

elemnum=size(elem,1);
nodenum=size(node,1);
nodevol=zeros(nodenum,1);
for i=1:elemnum
      nodevol(elem(i,1:4))=nodevol(elem(i,1:4))+vol(i);
end
nodevol=nodevol/4;
