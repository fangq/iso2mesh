function dist=maskdist(vol)
%
% dist=maskdist(vol)
%
% return the distance in each voxel towards the nearest label boundaries
%
% author: Qianqian Fang (q.fang at neu.edu)
%
% input:
%	 img: a 3D array
%
% output:
%	 dist: a integer array, storing the distance, in voxel unit, towards
%	       the nearest boundary between two distinct non-zero voxels, the
%	       space outside of the array space is also treated as a unique
%	       non-zero label.
%
% example:
%
%    a=ones(60,60,60);
%    a(:,:,1:10)=2;
%    a(:,:,11:20)=3;
%    im=maskdist(a);
%    imagesc(squeeze(im(:,30,:)))
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if(isempty(vol))
    error('input vol can not be empty');
end

vals=unique(vol(:));
if(length(vals)>256)
    error('it appears that your input is a gray-scale image, you must convert it to binary or labels first');
end

newvol=ones(size(vol)+2)*max(vals)+1;
newvol(2:end-1,2:end-1,2:end-1)=vol;

vals(end+1)=newvol(1,1,1);
vals(vals==0)=[];

dist=ones(size(newvol))*inf;

for i=1:length(vals(:))
    vv=(newvol==vals(i));
    vdist=bwdist(vv);
    vdist(vdist==0)=inf;
    dist=min(dist,vdist);
end

dist=dist(2:end-1,2:end-1,2:end-1);