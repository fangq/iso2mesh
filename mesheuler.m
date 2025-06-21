function [X, V, E, F, b, g, C] = mesheuler(face)
%
% [X,V,E,F,b,g,C]=mesheuler(face)
%
% Euler's charastistics of a mesh
%
% author: Qianqian Fang, <q.fang at neu.edu>
%
% input:
%   face: a closed surface mesh
%
% output:
%   X: Euler's charastistics
%   V: number of vertices
%   E: number of edges
%   F: number of triangles (if face is tetrahedral mesh, exterior surface)
%   b: number of boundary loops (for surfaces)
%   g: genus (holes)
%   C: number of tetrahedra
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

% mesh vertices
V = length(unique(face));

b = 0;
g = 0;
C = 0;
% mesh unique edges
ed = uniqedges(face);
E = size(ed, 1);

% mesh unique faces
if (size(face, 2) == 4)
    fc = uniqfaces(face);
    F = size(fc, 1);
    C = size(face, 1);
else
    if (nargout > 4)
        ed = surfedge(face);
        loops = extractloops(ed);
        b = length(find(isnan(loops)));
    end
    F = size(face, 1);
end

% Euler's formula, X = V - E + F - C - 2*g
X = V - E + F - C;
if (nargout > 5 && size(face, 2) == 3)
    g = floor((X + b - 2) / 2);
end
