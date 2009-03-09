function [no,el,regions,holes]=vol2surf(img,ix,iy,iz,opt,dofix,method)
%   [no,el,regions,holes]=vol2surf(img,ix,iy,iz,opt,dofix,method)
%   vol2surf: converting a 3D volumetric image to surfaces
%
%   author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%   inputs:
%          img: a volumetric binary image; if img is empty, vol2surf will
%               return user defined surfaces via opt.surf if it exists
%          ix,iy,iz: subvolume selection indices in x,y,z directions
%          opt: function parameters
%            if method is 'cgalsurf':
%              opt=a float number>1: max radius of the Delaunay sphere(element size) 
%              opt.radbound: same as above, max radius of the Delaunay sphere
%              opt(1,2,...).radbound: same as above, for each levelset
%            if method is 'simplify':
%              opt=a float number<1: compression rate for surf. simplification
%              opt.keeyratio=a float less than 1: same as above, same for all surf.
%              opt(1,2,..).keeyratio: setting compression rate for each levelset
%            opt(1,2,..).maxsurf: 1 - only use the largest disjointed surface
%                                 0 - use all surfaces for that levelset
%            opt(1,2,..).holes: user specified holes interior pt list
%            opt(1,2,..).regions: user specified regions interior pt list
%            opt(1,2,..).surf.{node,elem}: add additional surfaces
%            opt(1,2,..).{A,B}: linear transformation for each surface
%          dofix: 1: perform mesh validation&repair, 0: skip repairing
%          method: - if method is 'simplify', iso2mesh will first call
%                    binsurface to generate a voxel-based surface mesh and then
%                    use meshresample/meshcheckrepair to create a coarser mesh;
%                  - if method is 'cgalsurf', iso2mesh will call the surface
%                    extraction program from CGAL to make surface mesh
%                  - if method is not specified, 'cgalsurf' is assumed by default
%   outputs: 
%          no:  list of nodes on the resulting suface mesh, 3 columns for x,y,z
%          el:  list of trianglular elements on the surface, [n1,n2,n3,region_id]
%          regions: list of interior points for all sub-region, [x,y,z]
%          holes:   list of interior points for all holes, [x,y,z]

el=[];
no=[];

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
maxlevel=0;

if(~isempty(img))

    img=img(ix,iy,iz);
    dim=size(img);
    newdim=dim+[2 2 2];
    newimg=zeros(newdim);
    newimg(2:end-1,2:end-1,2:end-1)=img;

    maxlevel=max(newimg(:));

    % to accelerate the boundary field calculation
    bfield=imedge3d(newimg);

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
          [idx,idy]=find(newimg==i & bfield==min(bfield(idx)));
          if(~isempty(idx))
              % pick the first 1 for all min points
              [idy,idz]=ind2sub([size(newimg,2),size(newimg,3)],idy(1));
              % because binsurface makes the bfield shift by 1 in all axes
              disp([idx(1),idy,idz]-1);
              regions(end+1,:)=[idx(1),idy,idz]-1;
          end
      end
    end

    for i=1:maxlevel
        fprintf(1,'processing threshold level %d...\n',i);

        if(nargin==7 & strcmp(method,'simplify'))

          [v0,f0]=binsurface(newimg>i-1); % not sure if binsurface works for multi-value arrays
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

        elseif(nargin<7 | strcmp(method,'cgalsurf'))
          if(isstruct(opt) & length(opt)==maxlevel) radbound=opt(i).radbound;
          elseif (isstruct(opt) & length(opt)==1) radbound=opt.radbound;
          else radbound=opt;  end;

          maxsurfnode=40000;  % maximum node numbers for each level
          if(isstruct(opt) & length(opt)==maxlevel) maxsurfnode=opt(i).maxnode;
          elseif (isstruct(opt) & length(opt)==1) maxsurfnode=opt.maxnode;

          [v0,f0]=vol2restrictedtri(newimg>(i-1),0.5,regions(i,:),max(newdim)*max(newdim)*2,30,radbound,radbound,maxsurfnode);
        end
        % if use defines maxsurf=1, take only the largest closed surface
        if(isstruct(opt))
            if( (isfield(opt,'maxsurf') && length(opt)==1 && opt.maxsurf==1) | ...
                    (length(opt)==maxlevel && isfield(opt(i),'maxsurf') && opt(i).maxsurf==1))
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

    %some final fix and scaling
    no(:,1:3)=no(:,1:3)-1; % because we padded the image with a 1 voxel thick null layer in newimg

    no(:,1)=no(:,1)*(max(ix)-min(ix)+1)/dim(1)+(min(ix)-1);
    no(:,2)=no(:,2)*(max(iy)-min(iy)+1)/dim(2)+(min(iy)-1);
    no(:,3)=no(:,3)*(max(iz)-min(iz)+1)/dim(3)+(min(iz)-1);

end  % if not isempty(img)

if(isstruct(opt) & isfield(opt,'surf'))
   for i=1:length(opt.surf)
	opt.surf(i).elem(:,4)=maxlevel+i;
        el=[el;opt.surf(i).elem+length(no)];
        no=[no;opt.surf(i).node];
   end
end
