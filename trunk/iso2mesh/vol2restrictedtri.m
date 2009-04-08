function [node,elem]=vol2restrictedtri(vol,thres,cent,brad,ang,radbound,distbound,maxnode)
% [node,elem]=vol2restrictedtri(vol,thres,cent,brad,ang,radbound,distbound,maxnode)
%
% vol2restrictedtri: surface mesh extraction using CGAL mesher
% by FangQ, 2009/01/06
%
% inputs:
%       vol: a 3D volumetric image
%       thres: a scalar as the threshold of of the extraction
%       cent: a 3d position (x,y,z) which locates inside the resulting
%             mesh, this is automatically computed from vol2surf
%       brad: maximum bounding sphere squared of the resulting mesh
%       ang: minimum angular constrains of the resulting tranglar elements
%            (in degrees)
%       radbound: maximum triangle delaunay circle radius
%       distbound: maximum delaunay sphere distances
%       maxnode: maximum number of surface nodes (even radbound is not reached)
% outputs:
%       node: the list of 3d nodes in the resulting surface (x,y,z)
%       elem: the element list of the resulting mesh (3 columns of integers)

if(radbound<1)
    warning(['You are meshing the surface with sub-pixel size. If this ' ...
             'is not your your intent, please check if you set ' ...
             '"opt.radbound" correctly for the default meshing method.']);
end

exesuff=getexeext;
if(strcmp(exesuff,'.mexa64')) % cgalsurf.mexglx can be used for both
	exesuff='.mexglx';
end

saveinr(vol,mwpath('pre_extract.inr'));
deletemeshfile('post_extract.off');
system([' "' mcpath('cgalsurf') exesuff '" "' mwpath('pre_extract.inr') ...
    '" ' sprintf('%f %f %f %f %f %f %f %f %d ',thres,cent,brad,ang,radbound,distbound,maxnode) ...
    ' "' mwpath('post_extract.off') '"']);
[node,elem]=readoff(mwpath('post_extract.off'));

% assuming the origin [0 0 0] is located at the lower-bottom corner of the image
node=node+0.5;