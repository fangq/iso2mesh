function [no,el,fc]=sortmesh(origin,node,elem,face)
% [no,el,fc]=sortmesh(origin,node,elem,face)
%
% sort nodes and elements in a mesh so that the indexed
% nodes and elements are closer to each order
% (this may reduce cache-miss in a calculation)
%
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2010/05/06
%
% input:
%    origin: sorting all nodes and elements with the distance and
%            angles wrt this location, if origin=[], it will be 
%            node(1,:)
%    node: list of nodes
%    elem: list of elements (each row are indices of nodes of each element)
%    face: list of surface triangles (this can be omitted)
%
% output:
%    no: node coordinates in the sorted order
%    el: the element list in the sorted order
%    fc: the surface triangle list in the sorted order (can be ignored)
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if(isempty(origin))
   origin=node(1,:);
end
sdist=node-repmat(origin,size(node,1),1);
[theta,phi,R]=cart2sph(sdist(:,1),sdist(:,2),sdist(:,3));
sdist=[R,phi,theta];
[nval,nidx]=sortrows(sdist);
no=node(nidx,:);

[nval,nidx]=sortrows(nidx);
el=sort(nidx(elem),2);
el=sortrows(el);

if(nargin>=4 && nargout==3)
  fc=sort(nidx(face),2);
  fc=sortrows(fc);
end
