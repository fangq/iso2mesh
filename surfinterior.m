function [pt,p0,v0,t,idx]=surfinterior(node,face)
%
% [pt,p0,v0,t,idx]=surfinterior(node,face)
%
% identify a point that is enclosed by the (closed) surface
%
% author: Qianqian Fang, <fangq at nmr.mgh.harvard.edu>
%
% input:
%   node: a list of node coordinates (nn x 3)
%   face: a surface mesh triangle list (ne x 3)
%
% output:
%   pt: the interior point coordinates [x y z]
%   p0: ray origin used to determine the interior point
%   v0: the vector used to determine the interior point
%   t : ray-tracing intersection distance (with signs) from p0. the
%       intersection coordinates can be expressed as p0+ts(i)*v0
%   idx: index to the face elements that intersect with the ray, order
%       match that of t
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

pt=[];
len=size(face,1);
for i=1:len
   p0=mean(node(face(i,1:3),:));
   plane=surfplane(node,face(i,:));
   v0=plane(1:3);

   [t,u,v]=raytrace(p0,v0,node,face);

   idx=find(u>=0 & v>=0 & u+v<=1.0);
   if(~isempty(idx) & mod(length(idx),2)==0)
       ts=unique(sort(t(idx)));
       [maxv,maxi]=max(diff(ts));
       pt=p0+v0*(ts(maxi)+ts(maxi+1))*0.5;
       t=t(idx);
       break;
   end
end