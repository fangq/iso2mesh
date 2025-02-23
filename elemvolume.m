function vol = elemvolume(node, elem, option)
%
% vol=elemvolume(node,elem,option)
%
% calculate the volume for a list of simplexes
%
% author: Qianqian Fang, <q.fang at neu.edu>
% date: 2007/11/21
%
% input:
%    node:  node coordinates
%    elem:  element table of a mesh
%    option: if option='signed', the volume is the raw determinant,
%            else, the results will be the absolute values
%
% output:
%    vol:   volume values for all elements
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

v1 = node(elem(:, 1), :);
v2 = node(elem(:, 2), :);
v3 = node(elem(:, 3), :);

edge1 = v2 - v1;
edge2 = v3 - v1;

if (size(elem, 2) == size(node, 2))
    det12 = cross(edge1, edge2);
    det12 = sum(det12 .* det12, 2);
    vol = 0.5 * sqrt(det12);
    return
end

v4 = node(elem(:, 4), :);
edge3 = v4 - v1;
vol = -dot(edge1, cross(edge2, edge3, 2), 2);

if (nargin == 3 && strcmp(option, 'signed'))
    vol = vol / prod(1:size(node, 2));
else
    vol = abs(vol) / prod(1:size(node, 2));
end
