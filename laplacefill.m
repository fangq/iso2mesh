function newvol = laplacefill(vol, seeds, solver, tol, maxiter, varargin)
%
% newvol = laplacefill(vol, seeds, solver, tol, maxiter, ...)
%
% perform a hole-fill or flood-fill in a 2-D or 3-D binary image using
% Laplace solver
%
% author: Qianqian Fang, <q.fang at neu.edu>
%
% input:
%     vol: a 2-D or 3-D binary image
%     seeds: seeds for flood-fill, 2 or 3-column matrix; if empty, perfrom
%          hole-fill
%     solver: (optional) linear solver, if not given, use bicgstab
%     tol: (optional) linear solver convergence tolerance, default 1e-5
%     maxiter: (optional) linear solver max iteration, default 3000
%
%     additional parameters that are supported by any iterative solver,
%     such as qmr, pcg, gmres, tfqmr, mldivide, minres etc
%
% output:
%     newvol: the volume image after flood-fill or hole-fill
%
% example:
%     a = zeros(60, 80, 90);
%     a(20:40, 40:70, 30:80)=1;
%     a(25:35, 50:60, 50:60)=0;
%     newvol = laplacefill(a);
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

dims = size(vol) + 2;

interiornode = prod(dims - 2);

zeroidx = find(vol == 0);

if (ndims(vol) == 3)
    [ix, iy, iz] = ndgrid(2:dims(1) - 1, 2:dims(2) - 1, 2:dims(3) - 1);
else
    [ix, iy, iz] = ndgrid(2:dims(1) - 1, 2:dims(2) - 1, 2);
    dims(3) = 3;
end

ix = ix(zeroidx);
iy = iy(zeroidx);
iz = iz(zeroidx);

idx = sub2ind(dims - 2, ix - 1, iy - 1, iz - 1);  % index of all interior nodes in the subset of interior nodes
idx = idx(:)';
nnzpos = {idx, idx(ix > 2), idx(ix < dims(1) - 1), idx(iy > 2), idx(iy < dims(2) - 1), idx(iz > 2), idx(iz < dims(3) - 1)};

nonzeroidx = find(vol > 0)';

seedidx = [];

if (nargin > 1 && size(seeds, 2) == 3)
    seedidx = sub2ind(dims(1:3) - 2, seeds(:, 1), seeds(:, 2), seeds(:, 3));
end

Amat = sparse([seedidx, nonzeroidx, nnzpos{1}, nnzpos{2} - 1, nnzpos{3} + 1, ...
               nnzpos{4} - dims(1) + 2, nnzpos{5} + dims(1) - 2, ...
               nnzpos{6} - (dims(1) - 2) * (dims(2) - 2), nnzpos{7} + (dims(1) - 2) * (dims(2) - 2)], ...
              [seedidx, nonzeroidx, nnzpos{:}], ...
              [ones(1, length(seedidx)) ones(1, length(nonzeroidx)) -ones(1, length(idx)) ...
               (1 / 6) * ones(1, sum(cellfun(@(x) length(x), nnzpos(2:end))))], ...
              interiornode, interiornode);

if (~isempty(seedidx))
    b = sparse(seedidx, ones(size(seedidx)), ones(size(seedidx)), interiornode, 1);
else
    if (ndims(vol) == 3)
        boundnode = idx(ix == 2 | iy == 2 | iz == 2 | ix == dims(1) - 1 | iy == dims(2) - 1 | iz == dims(3) - 1);
    else
        boundnode = idx(ix == 2 | iy == 2 | ix == dims(1) - 1 | iy == dims(2) - 1);
    end
    b = sparse(boundnode, ones(size(boundnode)), -(1 / 6) * ones(size(boundnode)), interiornode, 1);
end

if (nargin < 4)
    tol = 1e-10;
end

if (nargin < 5)
    maxiter = 3000;
end

if (nargin > 2)
    mysolver = str2fun(solver);
    [newvol, flag] = mysolver(Amat, b, tol, maxiter, varargin{:});
else
    [newvol, flag] = bicgstab(Amat, b, tol, maxiter, varargin{:});
end

if (flag)
    newvol = gmres(Amat, b, 100, tol, maxiter, varargin{:});
end

newvol = reshape(full(newvol), size(vol));

if (isempty(seedidx))
    newvol = ~newvol;
end
