function resimg = fillholes3d(img, maxgap, varargin)
%
% resimg=fillholes3d(img,maxgap,mask)
%
% close a 3D image with the speicified gap size and then fill the holes
%
% author: Qianqian Fang, <q.fang at neu.edu>
%
% input:
%    img: a 2D or 3D binary image
%    maxgap: if is a scalar, specify maximum gap size for image closing
%            if a pair of coordinates, specify the seed position for
%            floodfill
%    mask: (optional) neighborhood structure element for floodfilling
%
% output:
%    resimg: the image free of holes
%
% this function requires the image processing toolbox for matlab/octave
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if (nargin > 1 && numel(maxgap) == 1)
    resimg = volclose(img, maxgap);
else
    resimg = img;
end

if (exist('imfill', 'file'))
    resimg = imfill(resimg, 'holes');
    return
end

if (nargin > 1 && numel(maxgap) > 1)
    newimg = zeros(size(resimg) + 2);
else
    newimg = ones(size(resimg) + 2);
end

oldimg = zeros(size(newimg));
if (ndims(resimg) == 3)
    oldimg(2:end - 1, 2:end - 1, 2:end - 1) = resimg;
    newimg(2:end - 1, 2:end - 1, 2:end - 1) = 0;
else
    oldimg(2:end - 1, 2:end - 1) = resimg;
    newimg(2:end - 1, 2:end - 1) = 0;
end

isseeded = false;
if (nargin > 1 && numel(maxgap) > 1)
    if (size(maxgap, 2) == 3)
        newimg(sub2ind(size(newimg), maxgap(:, 1) + 1, maxgap(:, 2) + 1, maxgap(:, 3) + 1)) = 1;
    else
        newimg(sub2ind(size(newimg), maxgap(:, 1) + 1, maxgap(:, 2) + 1)) = 1;
    end
    isseeded = true;
end

newsum = sum(newimg(:));
oldsum = -1;

while (newsum ~= oldsum)
    newimg = (volgrow(newimg, 1, varargin{:}) & ~(oldimg > 0));
    oldsum = newsum;
    newsum = sum(newimg(:));
end

if (ndims(resimg) == 3)
    resimg = newimg(2:end - 1, 2:end - 1, 2:end - 1);
else
    resimg = newimg(2:end - 1, 2:end - 1);
end

if (~isseeded)
    resimg = double(~resimg);
else
    resimg = double(resimg);
end
