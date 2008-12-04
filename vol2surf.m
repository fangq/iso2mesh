function [no,el]=vol2surf(img,ix,iy,iz,opt,dofix)
%   converting a 3D volumetric image to surfaces
%   author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%   inputs:
%          img: a volumetric binary image
%          ix,iy,iz: subvolume selection indices in x,y,z directions
%          opt: same as in vol2mesh.m

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
  fprintf(1,'processing threshold level %d...\n',i);

%  if(maxlevel>1) 
%	[f0,v0]=isosurface(newimg,i);
%  else
        [f0,v0]=binsurface(newimg>i); % not sure if binsurface works for multi-value arrays
%  end

  v0(:,[1 2])=v0(:,[2 1]); % isosurface(V,th) assumes x/y transposed
  if(dofix)  [v0,f0]=meshcheckrepair(v0,f0);  end
  
  if(isstruct(opt) & length(opt)==maxlevel) keepratio=opt(i+1).keepratio;
  elseif (isstruct(opt) & length(opt)==1) keepratio=opt.keepratio;
  else keepratio=opt;  end;

  % first, resample the surface mesh with cgal
  fprintf(1,'resampling surface mesh for level %d...\n',i);
  [v0,f0]=meshresample(v0,f0,keepratio);
  
  % iso2mesh is not stable for meshing small islands,remove them (max 3x3x3 voxels)
  f0=removeisolatedsurf(v0,f0,3);

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
