function [no,fa,ff]=readoff(fname)
%
% [node,elem]=readoff(fname)
%
% read Avizo AVS UCD file (INP)
%
% author: Salvatore Cunsolo (sal.cuns@gmail.com)
% date: 2016/05/03
%
% input:
%    fname: name of the OFF data file
%
% output:
%    node: node coordinates of the mesh
%    elem: list of elements of the mesh
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

fid=fopen(fname,'rt');
fgetl(fid);fgetl(fid);fgetl(fid);
ecount = fscanf(fid, '%d %d %d %d %d\n', [5 1]);
vcount = ecount(1);
ecount = ecount(2);
no = fscanf(fid, '%*d %f %f %f\n', [3 vcount])';
fa = fscanf(fid, '%*d %d %*s %d %d %d\n', [4 ecount])';
fclose(fid);
fa(:, 2:4) = fa(:, 2:4) + 1;
fa = circshift(fa, [0 -1]);
ii = unique(fa(:, 4));
for i = 1:size(ii)
    ff{i} = fa(fa(:, 4) == ii(i), 1:3);
end
fa = fa(:, 1:3);
end
