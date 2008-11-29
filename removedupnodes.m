function [newnode,newelem]=removedupnodes(node,elem)
% [newnode,newelem]=removedupnodes(node,elem)
%
% Removing the duplicated nodes from a mesh
% Author: Qianqian Fang <fangq at nmr.mgh.harvard.edu>
%
% Parameters:
%   elem: integer array with dimensions of NE x 4, each row contains
%         the indices of all the nodes for each tetrahedron
%   node: node coordinates, 3 columns for x, y and z respectively
%
% Outputs:
%   newnode: nodes without duplicates
%   newelem: elements with only the unique nodes
%

[newnode,I,J]=unique(node,'rows');
newelem=J(elem);
