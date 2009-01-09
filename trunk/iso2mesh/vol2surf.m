function [no,el,regions,holes]=vol2surf2(img,ix,iy,iz,opt,dofix,method)
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

if(isstruct(opt) & isfield(opt,'holes')) 
    holes=opt.holes;
else
    holes=[];
end
if(isstruct(opt) & isfield(opt,'regions')) 
    regions=opt.regions;
else
    regions=[];
end

maxlevel=max(newimg(:));

bfield=zeros(newdim);
for i=1:maxlevel
    fprintf(1,'preprocessing threshold level %d...\n',i);
    [v0,f0]=binsurface(newimg>i-1); % not sure if binsurface works for multi-value arrays
    bfield(sub2ind(newdim,v0(:,1),v0(:,2),v0(:,3)))=1;
    v{i}=v0;
    f{i}=f0;
end


% create region list. To do this, we need to find an interior point
% for each region, and make sure this point is not close to the 
% boundary (otherwise, after mesh simplification, it may move outside)

% The trick is to use a bfield matrix, by smoothing it for a few iterations,
% we will get a field with values related to the distances to the boundary; 
% for each region we find the lowest field point as the interior point

% smooth bfield 3 times, this makes the min distance to the boundaries 3
% voxels: I am assuming that the subsequent mesh-resample will not cause
% boundary changes more than 3 voxels, if it moved more, then increase this
% number

bfield=smoothbinvol(bfield,3);

for i=1:maxlevel
  idx=find(newimg==i);
  if(~isempty(idx))
      % for each level, find the bfield voxels with the min values
      [ix,iy]=find(newimg==i & bfield==min(bfield(idx)));
      if(~isempty(ix))
          % pick the first 1 for all min points
          [iy,iz]=ind2sub([size(newimg,2),size(newimg,3)],iy(1));
          % because binsurface makes the bfield shift by 1 in all axes
          disp([ix(1),iy,iz]-1);
          regions(end+1,:)=[ix(1),iy,iz]-1;
      end
  end
end

el=[];
no=[];

for i=1:maxlevel
    fprintf(1,'processing threshold level %d...\n',i);
    
    v0=v{i};
    f0=f{i};
    if(nargin<7 | strcmp(method,'simplify'))
    
	  % with binsurf, I think the following line is not needed anymore
	  %  v0(:,[1 2])=v0(:,[2 1]); % isosurface(V,th) assumes x/y transposed
	  if(dofix)  [v0,f0]=meshcheckrepair(v0,f0);  end  

	  if(isstruct(opt) & length(opt)==maxlevel) keepratio=opt(i).keepratio;
	  elseif (isstruct(opt) & length(opt)==1) keepratio=opt.keepratio;
	  else keepratio=opt;  end;

	  % first, resample the surface mesh with cgal
	  fprintf(1,'resampling surface mesh for level %d...\n',i);
	  [v0,f0]=meshresample(v0,f0,keepratio);

	  % iso2mesh is not stable for meshing small islands,remove them (max 3x3x3 voxels)
	  f0=removeisolatedsurf(v0,f0,3);

	  if(dofix) [v0,f0]=meshcheckrepair(v0,f0); end
	  
    elseif(nargin==7 & strcmp(method,'cgalsurf'))
	  if(isstruct(opt) & length(opt)==maxlevel) radbound=opt(i).radbound;
	  elseif (isstruct(opt) & length(opt)==1) radbound=opt.radbound;
	  else radbound=opt;  end;
	  
	  [v0,f0]=vol2restrictedtri(newimg>(i-1),0.5,regions(i,:),max(newdim)*max(newdim)*2,30,radbound,radbound);
    end
    % if use defines maxsurf=1, take only the largest closed surface
    if(isstruct(opt))
        if(  ((isfield(opt,'maxsurf') & length(opt)==1 & opt.maxsurf==1) | ...
                (length(opt)==maxlevel & isfield(opt(i),'maxsurf') & opt(i).maxsurf==1)))
                f0=maxsurf(finddisconnsurf(f0));
        end
    end

    % if a transformation matrix/offset vector supplied, apply them
    if(isstruct(opt) & length(opt)==maxlevel & isfield(opt(i),'A') & isfield(opt(i),'B')) 
	v0=(opt(i).A*v0'+repmat(opt(i).B(:),1,size(v0,1)))';
    elseif (isstruct(opt) & length(opt)==1 & isfield(opt,'A') & isfield(opt,'B')) 
	v0=(opt.A*v0'+repmat(opt.B(:),1,size(v0,1)))';
    end

    % if user specified holelist and regionlist, append them
    if(isstruct(opt)  & length(opt)==maxlevel)
	if(isfield(opt(i),'hole'))
            holes=[holes;opt(i).hole]
	end
	if(isfield(opt(i),'region'))
            regions=[regions;opt(i).region]
	end
    end

    if(i==0)
	el=[f0 (i+1)*ones(size(f0,1),1)];
	no=v0;
    else
	el=[el;f0+length(no) (i+1)*ones(size(f0,1),1)];
	no=[no;v0];
    end
end

if(isstruct(opt) & isfield(opt,'surf'))
   for i=1:length(opt.surf)
	opt.surf(i).elem(:,4)=maxlevel+i;
        el=[el;opt.surf(i).elem+length(no)];
        no=[no;opt.surf(i).node];
   end
end
