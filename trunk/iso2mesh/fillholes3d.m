function resimg=fillholes3d(img,ballsize)
% resimg=fillholes3d(img,ballsize)
%
% close a 3D image with the speicified gap size and then fill the holes
%
% author: Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
% 
% input:
%    img: a 3D binary image
%    ballsize: maximum gap size for image closing
% output:
%    resimg: the image free of holes
%
% this function requires the image processing toolbox for matlab/octave
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

resimg = imclose(img,closeball = strel('ball',ballsize));
resimg = imfill(resimg,'holes');
