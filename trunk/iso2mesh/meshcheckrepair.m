function [node,elem]=meshcheckrepair(node,elem,opt)
% [node,elem]=meshcheckrepair(node,elem,opt)
% 
% check and repair a surface mesh
%
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2008/10/10
%
% parameters:
%      node: input/output, surface node list, dimension (nn,3)
%      elem: input/output, surface face element list, dimension (be,3)
%      opt: options, including
%            'duplicated': remove duplicated elements
%            'isolated': remove isolated nodes
%            'deep': call external jmeshlib to remove non-manifold vertices

if(nargin<3 || strcmp(opt,'duplicated'))
    l1=length(elem);
    elem=removedupelem(elem);
    l2=length(elem);
    if(l2~=l1) fprintf(1,'%d duplicated elements were removed\n',l1-l2); end
end

if(nargin<3 || strcmp(opt,'isolated'))
    l1=length(node);
    [node,elem]=removeisolatednode(node,elem);
    l2=length(node);
    if(l2~=l1) fprintf(1,'%d isolated nodes were removed\n',l1-l2); end
end

if(nargin<3 || strcmp(opt,'open'))
    eg=surfedge(elem);
    if(length(eg)>0) 
        error('open surface found, you need to enclose it by padding zeros around the volume');
    end
end
exesuff='.exe';
if(isunix) exesuff=['.',mexext]; end

if(nargin<3 || strcmp(opt,'deep'))
    exesuff='.exe';
    if(isunix) exesuff=['.',mexext]; end
    if(exist('cleanedmesh.off')) delete('cleanedmesh.off'); end
    saveoff(node,elem,'cleanmesh.off');
    eval(['! meshfix',exesuff ' cleanmesh.off cleanedmesh.off']);
    [node,elem]=readoff('cleanedmesh.off');
end
