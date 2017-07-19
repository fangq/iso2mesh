function [no,el]=removeisolatednode(node,elem)
%
% [no,el]=removeisolatednode(node,elem)
%
% remove isolated nodes: nodes that are not included in any element
%
% author: Qianqian Fang, <q.fang at neu.edu>
%
% input:
%     node: list of node coordinates
%     elem: list of elements of the mesh, can be a regular array or a cell array for PLCs
%
% output:
%     no: node coordinates after removing the isolated nodes
%     el: element list of the resulting mesh
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

oid=1:size(node,1);       % old node index
if(~iscell(elem))
    idx=setdiff(oid,elem(:)); % indices to the isolated nodes
else
    el=cell2mat(elem);
    idx=setdiff(oid,el(:)); % indices to the isolated nodes
end
idx=sort(idx);
delta=zeros(size(oid));   
delta(idx)=1;
delta=-cumsum(delta);     % calculate the new node index after removing the isolated nodes
oid=oid+delta;            % map to new index
if(~iscell(elem))
    el=oid(elem);             % element list in the new index
else
    el=cellfun(@(x) oid(x), elem,'UniformOutput',false);
end
no=node;                  
no(idx,:)=[];             % remove the isolated nodes
