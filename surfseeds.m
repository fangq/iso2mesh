function seeds = surfseeds(node, face)
%
% seeds=surfseeds(node,face)
%
% calculate a set of interior points with each enclosed by a closed
% component of a surface
%
% author: Qianqian Fang, <q.fang at neu.edu>
%
% input:
%   node: a list of node coordinates (nn x 3)
%   face: a surface mesh triangle list (ne x 3)
%
% output:
%   seeds: the interior points coordinates for each closed-surface
%          component
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

fc = finddisconnsurf(face(:, 1:3));
len = length(fc);
seeds = zeros(len, 3);
isfound = zeros(len, 1);
for i = 1:len
    % surfinterior returns [] for an open or degenerate component; such a
    % component is skipped instead of aborting the whole seed search
    seed = surfinterior(node, fc{i});
    if (~isempty(seed))
        seeds(i, :) = seed;
        isfound(i) = 1;
    else
        warning('no interior point was found for surface component %d, skipped', i);
    end
end
seeds = seeds(isfound == 1, :);
