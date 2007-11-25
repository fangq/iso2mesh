function [conn,connnum,count]=meshconn(elem,nn);
% meshconn: create node neighbor list from a mesh
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/11/21
%
% parameters:
%    elem:  element table of a mesh
%    nn  :  total node number of the mesh
%    conn:  output, a cell structure of length nn, conn{n}
%           contains a list of all neighboring node ID for node n
%    connnum: vector of length nn, denotes the neighbor number of each node
%    count: total neighbor numbers

conn=cell(nn,1);
dim=size(elem);
for i=1:dim(1)
  for j=1:dim(2)
    conn{elem(i,j)}=[conn{elem(i,j)},elem(i,:)];
  end
end
count=0;
connnum=zeros(1,nn);
for i=1:nn
    conn{i}=sort(setdiff(unique(conn{i}),i));
    connnum(i)=length(conn{i});
    count=count+connnum(i);
end
