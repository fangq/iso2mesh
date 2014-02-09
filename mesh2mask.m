function mask=mesh2mask(node,face,xi,yi)
%
% mask=mesh2mask(node,face,Nxy)
%   or
% mask=mesh2mask(node,face,Nx,Ny)
%   or
% mask=mesh2mask(node,face,xi,yi)
%
% fast convertion from a 2D mesh to an image with triangle index labels
% 
% author: Qianqian Fang <fangq at nmr.mgh.harvard.edu>
% date for initial version: July 18,2013
%
% input:
%      node: node coordinates, dimension (nn,2) or (nn,3)
%      face: a triangle surface (ne,3)
%      Nx,Ny,Nxy: output image in x/y dimensions, or both
%      xi,yi: linear vectors for the output pixel center positions in x/y
%
% output:
%      mask: a 2D image, the value of each pixel is the index of the
%            enclosing triangle, if the pixel is outside of the mesh, NaN
%
% note: This function only works for matlab
%
% example:
%
%   [no,fc]=meshgrid6(0:5,0:5);
%   mask=mesh2mask(no,fc,-1:0.1:5,0:0.1:5);
%   imagesc(mask);
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if(nargin==3 && length(xi)==1 && xi>0)
    mn=min(node);
    mx=max(node);
    df=(mx(1:2)-mn(1:2))/xi;
elseif(nargin==3 && length(xi)==2 && all(xi>0))
    mn=min(node);
    mx=max(node);
    df=(mx(1:2)-mn(1:2))./xi;
elseif(nargin==4)
    mx=[max(xi) max(yi)];
    mn=[min(xi) min(yi)];
    df=[min(diff(xi(:))) min(diff(yi(:)))];
else
    error('you must give at least xi input');
end

hf=figure('visible','off');
patch('Vertices',node,'Faces',face,'linestyle','none','FaceColor','flat',...
 'FaceVertexCData',(1:size(face,1))','CDataMapping', 'scaled');
set(gca, 'Position', [0 0 1 1]);
cm=jet(size(face,1));
colormap(cm);
axis off
set(gca,'xlim',[mn(1) mx(1)]);
set(gca,'ylim',[mn(2) mx(2)]);
set(gca,'clim',[1 size(face,1)]);

output_size = round((mx(1:2)-mn(1:2))./df);%Size in pixels

resolution = 300; %Resolution in DPI
set(gcf,'PaperPositionMode','manual')
set(gcf,'paperunits','inches','paperposition',[0 0 output_size/resolution]);

%set(gcf,'PaperPositionMode','auto');

print(mwpath('post_mesh2mask.png'),'-dpng',['-r' num2str(resolution)]);

close(hf);

mask=imread(mwpath('post_mesh2mask.png'));
mask=int32(reshape(mask,[size(mask,1)*size(mask,2) size(mask,3)]));
[isfound,locb]=ismember(mask,floor(cm*255),'rows');
locb(isfound==0)=nan;

mask=rot90(reshape(locb,output_size([2 1]))');
