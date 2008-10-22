function [node,elem,bound]=vol2mesh(img,ix,iy,iz,opt,maxvol,dofix)
% [node,elem,bound]=vol2mesh(img,ix,iy,iz,thickness,keepratio,maxvol,A,B)
% convert a binary volume to tetrahedral mesh
% author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
% date:   2007/12/21
%
% inputs: 
%        img: a volumetric binary image 
%        ix,iy,iz: subvolume selection indices in x,y,z directions
%        opt: target surface element number after simplification
%        maxvol: target maximum tetrahedral elem volume

img=img(ix,iy,iz);
dim=size(img);
newdim=dim+[2 2 2];
newimg=zeros(newdim);
newimg(2:end-1,2:end-1,2:end-1)=img;

exesuff='.exe';
if(isunix) exesuff=['.',mexext]; end

maxlevel=max(newimg(:));
el=[];
no=[];
for i=0:maxlevel-1
  [f0,v0]=isosurface(newimg,i);
  v0(:,[1 2])=v0(:,[2 1]); % isosurface(V,th) assumes x/y transposed
  if(dofix)  [v0,f0]=meshcheckrepair(v0,f0);  end
  
  if(isstruct(opt) & length(opt)==maxlevel) keepratio=opt(i+1).keepratio;
  elseif (isstruct(opt) & length(opt)==1) keepratio=opt.keepratio;
  else keepratio=opt;  end;

  % first, resample the surface mesh with cgal
  fprintf(1,'resampling surface mesh for level %d...\n',i);
  [v0,f0]=meshresample(v0,f0,keepratio);
  if(dofix) [v0,f0]=meshcheckrepair(v0,f0); end
  
  % if a transformation matrix/offset vector supplied, apply them
  if(isstruct(opt) & length(opt)==maxlevel & isfield(opt(i+1),'A') & isfield(opt(i+1),'B')) 
      v0=(opt(i+1).A*v0'+repmat(opt(i+1).B(:),1,size(v0,1)))';
  elseif (isstruct(opt) & length(opt)==1 & isfield(opt,'A') & isfield(opt,'B')) 
      v0=(opt.A*v0'+repmat(opt.B(:),1,size(v0,1)))';
  end

  if(i==0)
      el=f0;
      no=v0;
  else
      el=[el;f0+length(no)];
      no=[no;v0];
  end
end

if(isstruct(opt) & isfield(opt,'surf'))
   for i=1:length(opt.surf)
        el=[el;opt.surf(i).elem+length(no)];
        no=[no;opt.surf(i).node];
   end
end

% then smooth the resampled surface mesh (Laplace smoothing)
edges=surfedge(el);   
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

node(:,1)=node(:,1)*(max(ix)-min(ix)+1)/dim(1)+min(ix);
node(:,2)=node(:,2)*(max(iy)-min(iy)+1)/dim(2)+min(iy);
node(:,3)=node(:,3)*(max(iz)-min(iz)+1)/dim(3)+min(iz);
