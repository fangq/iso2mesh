function nodenew=smoothsurf(node,mask,conn,iter)
% smoothsurf: smooth a surface mesh by Laplace smoothing
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/11/21
%
% parameters:
%    node:  node coordinates of a surface mesh
%    mask: of length of node number, =0 for internal nodes, =1 for edge nodes
%    conn:  input, a cell structure of length size(node), conn{n}
%           contains a list of all neighboring node ID for node n
%    iter:  smoothing iteration number
%    nodenew: output, the smoothed node coordinates

nn=size(node);
nodenew=node;
idx=find(mask==0)';

%simple Laplacian, maybe Fujiwara operator should be used in the future

for j=1:iter
    for i=1:length(idx)
        nodenew(idx(i),:)=mean(node(conn{idx(i)},:)); 
    end
    node=nodenew;
end
