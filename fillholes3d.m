function resimg = fillholes3d(img, maxgap, varargin)
%
% resimg=fillholes3d(img,maxgap)
%
% close a 3D image with the speicified gap size and then fill the holes
%
% author: Qianqian Fang, <q.fang at neu.edu>
%
% input:
%    img: a 3D binary image
%    maxgap: maximum gap size for image closing
%
% output:
%    resimg: the image free of holes
%
% this function requires the image processing toolbox for matlab/octave
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if (nargin > 1 && maxgap)
    resimg = volclose(img, maxgap);
else
    resimg = img;
end

% if (exist('imfill', 'file'))
%     resimg = imfill(resimg, 'holes');
%     return;
% end

newimg = ones(size(resimg) + 2);

oldimg = zeros(size(newimg));
if (ndims(resimg) == 3)
    oldimg(2:end - 1, 2:end - 1, 2:end - 1) = resimg;
    newimg(2:end - 1, 2:end - 1, 2:end - 1) = 0;
else
    oldimg(2:end - 1, 2:end - 1) = resimg;
    newimg(2:end - 1, 2:end - 1) = 0;
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

resimg = double(~resimg);
