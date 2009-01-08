% sample script to create volumetric mesh from 
% multiple levelsets of a binary segmented head image.
%
% Author: Qianqian Fang <fangq at nmr.mgh.harvard.edu>

% load iso2mesh image

img=imread('iso2mesh_bar.tif');
img=fliplr(img);
fullimg=repmat(1-img,[1,1,30]);
fullimg(:,:,31:60)=repmat(ones(size(img)),[1,1,30]);

% create volumetric tetrahedral mesh from the two-layer 3D images
% this may take another few minutes for a 256x256x256 volume
clear opt
opt.keepratio=0.1; % this option is only useful when vol2mesh uses 'simplify' method
opt.radbound=3;    % set the target surface mesh element bounding sphere be <3 pixels in radius.
tic
[node,elem,bound]=vol2mesh(fullimg,1:size(fullimg,1),1:size(fullimg,2),1:size(fullimg,3),opt,100,1);
toc
if(isoctavemesh)
        hb=trimesh(bound(:,1:3),node(:,1),node(:,2),node(:,3));
else
        hb=trisurf(bound(:,1:3),node(:,1),node(:,2),node(:,3));
end
axis equal
view(-90.5,-72);
