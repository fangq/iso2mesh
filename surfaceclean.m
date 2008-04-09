function f=surfaceclean(f,v)
% surfaceclean: remove surface patches that are located inside 
%               the bounding box faces
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2008/04/08
%
% parameters: 
%      v: input, surface node list, dimension (nn,3)
%      f: input, surface face element list, dimension (be,3)  
%      f: output, faces free of those on the bounding box
pos=v;
mi=min(pos);
ma=max(pos);

idx0=find(abs(pos(:,1)-mi(1))<1e-6);
idx1=find(abs(pos(:,1)-ma(1))<1e-6);

idy0=find(abs(pos(:,2)-mi(2))<1e-6);
idy1=find(abs(pos(:,2)-ma(2))<1e-6);

idz0=find(abs(pos(:,3)-mi(3))<1e-6);
idz1=find(abs(pos(:,3)-ma(3))<1e-6);

f=removeedgefaces(f,v,idx0);
f=removeedgefaces(f,v,idx1);
f=removeedgefaces(f,v,idy0);
f=removeedgefaces(f,v,idy1);
f=removeedgefaces(f,v,idz0);
f=removeedgefaces(f,v,idz1);

function f=removeedgefaces(f,v,idx1)
mask=zeros(length(v),1);
mask(idz1)=1;
f(find(sum(mask(f)')==3),:)=[];