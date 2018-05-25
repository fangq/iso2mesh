function [f, mask]=surfaceclean(f,v,tol)
%
% [f, mask] = surfaceclean(f,v,tol)
%
% remove surface patches that are located inside the bounding box faces 
% with tolerance tol. Returns mask of kept faces.
%
% input: 
%      v: surface node list, dimension (nn,3)
%      f: surface face element list, dimension (be,3)  
%    tol: tolerance of face removal
%
% output:
%      f: faces free of those on the bounding box
%   mask: bounding box face mask, dimension (be,1)
%
%Extended from iso2mesh toolbox by Salvatore Cunsolo
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
% author: Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
% date: 2008/04/08

mi=min(v);
ma=max(v);
if nargin < 3
    tol = 1e-6;
end

idx0=abs(v(:,1)-mi(1))<=tol;
idx1=abs(v(:,1)-ma(1))<=tol;

idy0=abs(v(:,2)-mi(2))<=tol;
idy1=abs(v(:,2)-ma(2))<=tol;

idz0=abs(v(:,3)-mi(3))<=tol;
idz1=abs(v(:,3)-ma(3))<=tol;

mask = ~(sum(idx0(f),2)==3|sum(idx1(f),2)==3 | ...
    sum(idy0(f),2)==3 | sum(idy1(f),2)==3 |...
    sum(idz0(f),2)==3 | sum(idz1(f),2)==3);

f = f(mask, :);
end