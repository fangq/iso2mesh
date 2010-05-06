function nodevol=nodevolume(node,elem)
% nodevol=nodevolume(node,elem)
%
% calculate the Voronoi volume of each node in a simplex mesh
%
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2009/12/31
%
% input:
%    node:  node coordinates
%    elem:  element table of a mesh
%
% ooutput:
%    nodevol:   volume values for all nodes
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

vol=elemvolume(node,elem(:,1:4));

elemnum=size(elem,1);
nodenum=size(node,1);
nodevol=zeros(nodenum,1);
for i=1:elemnum
      nodevol(elem(i,1:4))=nodevol(elem(i,1:4))+vol(i);
end
nodevol=nodevol/4;
