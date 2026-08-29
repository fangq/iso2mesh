function ang = facedihedral(node, face, varargin)
%
% ang = facedihedral(node, face)
%   or
% ang = facedihedral(node, face, 'general')
%
% for every triangle in a triangular mesh, compute its dihedral angle
% with its edge neighbor
%
% author: Qianqian Fang, <q.fang at neu.edu>
%
% input:
%   node:  node coordinates of the input mesh
%   face:  triangle list
%
% output:
%   ang: 3 dihedral angles of each triangle, with order set by edgeneighbors
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

opt = struct();
opt.type = '';
if (length(varargin) == 1)
    opt.type = 'general';
end

% edgeneighbors only accepts a 2nd input when it is 'general'
if (isempty(opt.type))
    edgenb = edgeneighbors(face(:, 1:3));
else
    edgenb = edgeneighbors(face(:, 1:3), opt.type);
end
surfnorm = surfacenorm(node, face(:, 1:3));
ang = nan(size(face, 1), 3);
if (~iscell(edgenb))
    for i = 1:size(edgenb, 2)
        idx = edgenb(:, i);
        ang(idx > 0, i) = dot(surfnorm(idx > 0, :), surfnorm(edgenb(idx > 0, i), :), 2);
    end
else
    for i = 1:size(edgenb, 1)
        dihe = sort(abs(dot(repmat(surfnorm(i, :), length(edgenb{i}), 1), surfnorm(edgenb{i}, :), 2)));
        dihe = max(min(dihe, 1), 0);
        if (length(dihe) < 3)
            ang(i, 1:length(dihe)) = dihe;
        else
            ang(i, :) = dihe(end - 2:end);
        end
    end
end
if (~iscell(edgenb))
    ang = max(min(ang, 1), -1);
    ang(edgenb == 0) = nan;
end
ang = acos(ang);
