function [node,elem,face]=meshabox_with_gridoptions(p0,p1,maxvol, maxradiustoedge, minangle,  nodesize)
% 
% [node,elem,face]=meshabox_with_gridoptions(p0,p1,maxvol,aspectratio,minangle,nodesize)
%
% This function extends the capabilities of the meshabox() function from
% ISO2MESH library to allow for more specific mesh controls sent to tetgen.
%
% input:
%   p0: coordinate of one corner of bounding box
%   p1: coordinate of opposit corner of bounding box
%   maxvol: maximal volume of a tetrahedral element.  ~ h^3
%   maxradiustoedge: maximal value allowed of radius(T) / min_{e in T} |e|
%       This is a way of measuring quality of tetrahedron.  The default is 
%       2, but it is possible to specify (and still converge) down to 1.2 
%       or 1.414. While it isn't guaranteed to give good quality for small
%       ratio since slivers can have as small as 0.7, it is a decent 
%       measure.  With angle conditions, it could be better.
%   minangle: minimal dihedral angle of an element.  default = 0, but can
%       converge up to 18.  This is not guaranteed to be enforced, but the
%       optimizer will try.  If the angle is too high, the optimization
%       subroutine may not converge, so try lowering the value if this
%       happens.
%   nodesize = 1 or an 8x1 array, size of the element near each vertex
%
% output:
%   node: node coordinates, 3 columns for x, y and z respectively
%   face: integer array with dimensions of NB x 3, each row represents
%         a surface mesh face element 
%   elem: integer array with dimensions of NE x 4, each row represents
%         a tetrahedron 
%
%  example:  
%
%     p0 = [0,0,0];
%     p1 = [1,1,1];
%     min_volume = (0.1)^3;
%     radius_to_edge_ratio = 1.2;
%     min_angle = 18;
%     nodesize = 1;
% 
%     [node,elem,face]=meshabox_with_gridoptions(p0,p1,min_volume,...
%                                radius_to_edge_ratio,min_angle,nodesize);
%
%
% Author: Spencer Patty
% Dec 29, 2015

if(nargin<3)
   maxvol = 1;
   maxradiustoedge = 1.414;
   minangle = 0;
   nodesize = 1;
elseif (nargin < 4)
   maxradiustoedge = 1.414;
   minangle = 0;
   nodesize = 1;
elseif (nargin < 5)
   minangle = 0;
   nodesize = 1;
elseif (nargin < 6)
   nodesize = 1;
end

% should add some assertions
% assert  0 <= aspectratio <= 2  but in reality no smaller than 1.2
% assert  30 > minangle > 0 but in reality no larger than 18.
% assert maxvol > 0 

% define the options that will be picked up in the surf2mesh function
ISO2MESH_TETGENOPT = ['-A -q' num2str(maxradiustoedge) '/' num2str(minangle) ...
                      ' -a' num2str(maxvol) ' -V']; 
                  
[node,elem,face]=surf2mesh([],[],p0,p1,1,maxvol,[],[],nodesize);
elem=elem(:,1:4);
face=face(:,1:3);