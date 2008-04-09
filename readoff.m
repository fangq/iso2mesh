function [node,elem]=readoff(fname)
% readsmf: read  Geomview Object File Format
% by FangQ, 2008/03/28
node=[];
elem=[];
fid=fopen(fname,'rt');
line=fgetl(fid);
dim=fscanf(fid,'%d',3);
node=fscanf(fid,'%f',[3,dim(1)])';
elem=fscanf(fid,'%f',inf);
if(length(elem)==4*dim(2))
    elem=reshape(elem,[4,dim(2)])';
elseif(length(elem)==8*dim(2))
    elem=reshape(elem,[8,dim(2)])';
end
elem=round(elem(:,2:4))+1;