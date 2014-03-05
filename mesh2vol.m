function [mask weight]=mesh2vol(node,elem,xi,yi,zi)
%
% [mask weight]=mesh2vol(node,face,Nxyz)
%   or
% [mask weight]=mesh2vol(node,face,[Nx,Ny,Nz])
%   or
% [mask weight]=mesh2vol(node,face,xi,yi,zi,hf)
%
% fast rasterization of a 3D mesh to a volume with tetrahedron index labels
% 
% author: Qianqian Fang <fangq at nmr.mgh.harvard.edu>
% date for initial version: Feb 10,2014
%
% input:
%      node: node coordinates, dimension N by 2 or N by 3 array
%      face: a triangle surface, N by 3 or N by 4 array
%      Nx,Ny,Nxy: output image in x/y dimensions, or both
%      xi,yi: linear vectors for the output pixel center positions in x/y
%      hf: the handle of a pre-created figure window for faster rendering
%
% output:
%      mask: a 2D image, the value of each pixel is the index of the
%            enclosing triangle, if the pixel is outside of the mesh, NaN
%
% note: This function only works for matlab
%
% example:
%
%   [no,el]=meshgrid6(0:5,0:5,0:3);
%   mask=mesh2vol(no,el(:,1:4),0:0.1:5,0:0.1:5,0:0.1:4);
%   imagesc(mask(:,:,3))
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if(nargin==3 && length(xi)==1 && xi>0)
    mn=min(node);
    mx=max(node);
    df=(mx(1:3)-mn(1:3))/xi;
elseif(nargin==3 && length(xi)==3 && all(xi>0))
    mn=min(node);
    mx=max(node);
    df=(mx(1:3)-mn(1:3))./(xi(:)');
elseif(nargin==5)
    mx=[max(xi) max(yi) max(zi)];
    mn=[min(xi) min(yi) min(zi)];
    df=[min(diff(xi(:))) min(diff(yi(:))) min(diff(zi(:)))];
else
    error('you must give at least xi input');
end

xi=mn(1):df(1):mx(1);
yi=mn(2):df(2):mx(2);
zi=mn(3):df(3):mx(3);

if(size(node,2)~=3 || size(elem,2)<=3)
    error('node must have 3 columns; face can not have less than 3 columns');
end

nz=length(zi);
mask=zeros(length(xi)-1,length(yi)-1,length(zi)-1);
weight=[];

hf=figure('visible','on');
for i=1:nz
    [cutpos,cutvalue,facedata,elemid]=qmeshcut(elem,node,node(:,1),['z=' num2str(zi(i))]);
    if(isempty(cutpos))
        continue;
    end
    maskz=mesh2mask(cutpos,facedata,xi,yi,hf);
    idx=find(~isnan(maskz));
    maskz(idx)=elemid(maskz(idx));
    mask(:,:,i)=maskz;
end
close(hf);
