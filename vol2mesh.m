function [node,elem,bound]=vol2mesh(img,ix,iy,iz,keepratio,maxvol,dofix)
% [node,elem,bound]=vol2mesh(img,ix,iy,iz,thickness,keepratio,maxvol,A,B)
% convert a binary volume to tetrahedral mesh
% author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
% date:   2007/12/21
%
% inputs: 
%        img: a volumetric binary image 
%        ix,iy,iz: subvolume selection indices in x,y,z directions
%        keepratio: target surface element number after simplification
%        maxvol: target maximum tetrahedral elem volume

img=img(ix,iy,iz);
dim=size(img);
newdim=dim+[2 2 2];
newimg=zeros(newdim);
newimg(2:end-1,2:end-1,2:end-1)=img;

exesuff='.exe';
if(isunix) exesuff=['.',mexext]; end

[f,v]=isosurface(newimg,0);
v(:,[1 2])=v(:,[2 1]); % isosurface(V,th) assumes x/y transposed
if(dofix)
    [v,f]=meshcheckrepair(v,f);
end

% first, resample the surface mesh with qslim
fprintf(1,'resampling surface mesh ...\n');
[no,el]=meshresample(v,f,keepratio);

% trisurf(el,no(:,1),no(:,2),no(:,3));
% waitforbuttonpress;
% then smooth the resampled surface mesh (Laplace smoothing)
edges=surfedge(no,el);   
mask=zeros(size(no,1),1);
mask(unique(edges(:)))=1;  % =1 for edge nodes, =0 otherwise

% remove end elements (all nodes are edge nodes)
el=delendelem(el,mask);

% dump surface mesh to .poly file format
savesurfpoly(no,el,[],[],'vesseltmp.poly');

% call tetgen to create volumetric mesh
delete('vesseltmp.1.*');
fprintf(1,'creating volumetric mesh from a surface mesh ...\n');
eval(['! tetgen',exesuff,' -q1.414a',num2str(maxvol), ' vesseltmp.poly']);

% read in the generated mesh
[node,elem,bound]=readtetgen('vesseltmp.1');
node=node-1; % because we wrapped the image with a 1 voxel thick null layer in newimg

node(:,1)=node(:,1)*(max(ix)-min(ix))/dim(1)+min(ix);
node(:,2)=node(:,2)*(max(iy)-min(iy))/dim(2)+min(iy);
node(:,3)=node(:,3)*(max(iz)-min(iz))/dim(3)+min(iz);
