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

totalmask = sum(mask(:));
newvol = vol;

for i = 1:layer
    newvol = (convn(logical(newvol), logical(mask), 'same') == totalmask);
end

newvol = double(newvol);
