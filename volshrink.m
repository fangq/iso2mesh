function newvol = volshrink(vol, layer, mask)
%
% vol = volshrink(vol, layer, mask)
%
% thinning a binary image or volume by a given pixel width
% this is similar to bwmorph(vol,'thin',3) except
% this does it in both 2d and 3d
%
% author: Qianqian Fang, <q.fang at neu.edu>
%
% input:
%     vol: a volumetric binary image
%     layer: number of iterations for the thickenining
%     mask: (optional) a 3D neighborhood mask
%
% output:
%     vol: the volume image after the thinning operations
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if (nargin < 2)
    layer = 1;
end

if (nargin < 3 || isempty(mask))
    if (ndims(vol) == 3)
        mask = zeros(3, 3, 3);
        mask(2, 2, :) = 1;
        mask(:, 2, 2) = 1;
        mask(2, :, 2) = 1;
    else
        mask = [0 1 0; 1 1 1; 0 1 0];
    end
end
mask = rot90(mask, 2);
totalmask = sum(mask(:));
newvol = ones(size(vol) + 2);
if (ndims(vol) == 3)
    newvol(2:end - 1, 2:end - 1, 2:end - 1) = (vol ~= 0);
    for i = 1:layer
        newvol(2:end - 1, 2:end - 1, 2:end - 1) = (convn(logical(newvol), logical(mask), 'valid') == totalmask);
    end
    newvol = double(newvol(2:end - 1, 2:end - 1, 2:end - 1));
else
    newvol(2:end - 1, 2:end - 1) = (vol ~= 0);
    for i = 1:layer
        newvol(2:end - 1, 2:end - 1) = (convn(logical(newvol), logical(mask), 'valid') == totalmask);
    end
    newvol = double(newvol(2:end - 1, 2:end - 1));
end
