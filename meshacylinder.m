function [node, face, elem] = meshacylinder(c0, c1, r, tsize, maxvol, ndiv)
%
% [node,face]=meshacylinder(c0,c1,r,tsize,maxvol,ndiv)
%    or
% [node,face,elem]=meshacylinder(c0,c1,r,tsize,maxvol,ndiv)
% [nplc,fplc]=meshacylinder(c0,c1,r,0,0,ndiv);
%
% create the surface and (optionally) tetrahedral mesh of a 3D cylinder
%
% author: Qianqian Fang, <q.fang at neu.edu>
%
% input:
%   c0, c1:  cylinder axis end points
%   r:   radius of the cylinder; if r contains two elements, it outputs
%        a cone trunk, with each r value specifying the radius on each end
%        if r is a 2x2 matrix, the first row defines an elliptic cylinder's
%        major axis on both ends; the 2nd row defines the minor axes
%   tsize: maximum surface triangle size on the sphere
%   maxvol: maximu volume of the tetrahedral elements
%
%         if both tsize and maxvol is set to 0, this function sill return
%         the piecewise-linear-complex (PLC) in the form of the nodes (as node)
%         and a cell array (as face).
%
%   ndiv: approximate the cylinder surface into ndiv flat pieces, if
%         ignored, ndiv is set to 20
%
% output:
%   node: node coordinates, 3 columns for x, y and z respectively
%   face: integer array with dimensions of NB x 3, each row represents
%         a surface mesh triangle
%   elem: (optional) integer array with dimensions of NE x 4, each row
%         represents a tetrahedron
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if (nargin < 3)
    error('you must at least provide c0, c1, and r');
end

if (numel(r) == 1)
    r = [r, r];
end

if (size(r, 1) == 1)
    r(2, :) = r(1, :);
end

if (any(r(:) <= 0) || all(c0(:) == c1(:)))
    error('invalid cylinder parameters');
end
c0 = c0(:);
c1 = c1(:);
len = sqrt(sum((c0 - c1) .* (c0 - c1)));
% define the axial vector v0 and a perpendicular vector t
v0 = c1 - c0;

if (nargin < 4)
    tsize = min([r(:)', len]) / 10;
end

if (nargin < 5)
    maxvol = tsize^3 / 5;
end

% calculate the cylinder end face nodes
if (nargin < 6)
    ndiv = 20;
end

dt = 2 * pi / ndiv;
theta = dt:dt:2 * pi;
cx = bsxfun(@times, r(1, :)', cos(theta));
cy = bsxfun(@times, r(2, :)', sin(theta));
cx = cx';
cy = cy';
p0 = [cx(:, 1) cy(:, 1) zeros(ndiv, 1)];
p1 = [cx(:, 2) cy(:, 2) len * ones(ndiv, 1)];
pp = [p0; p1];
no = rotatevec3d(pp, v0) + repmat(c0', size(pp, 1), 1);

fc = cell(ndiv + 2, 1);
for i = 1:ndiv - 1
    fc{i} = {[i i + ndiv i + ndiv + 1 i + 1], 1};
end
fc{ndiv} = {[ndiv ndiv + ndiv 1 + ndiv 1], 1};
fc{ndiv + 1} = {1:ndiv, 2};
fc{ndiv + 2} = {1 + ndiv:2 * ndiv, 3};

if (nargout == 2 && tsize == 0.0 && maxvol == 0.0)
    node = no;
    face = fc;
    return
end
if (nargin == 3)
    tsize = len / 10;
end
if (nargin < 5)
    maxvol = tsize * tsize * tsize;
end
[node, elem] = surf2mesh(no, fc, min(no), max(no), 1, maxvol, [0 0 1], [], 0);
face = volface(elem(:, 1:4));
