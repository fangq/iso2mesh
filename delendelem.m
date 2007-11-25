function elem=delendelem(elem,mask)
% delendelem - delete elements whose nodes are all edge nodes
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/11/24
%
% parameters: 
%      elem: input/output, surface/volumetric element list
%      mask: of length of node number, =0 for internal nodes, =1 for edge nodes

badidx=sum(mask(elem)');
elem(find(badidx==size(elem,2)),:)=[];
