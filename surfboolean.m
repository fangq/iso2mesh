function [newnode,newelem]=surfboolean(node,elem,varargin)
%
% [newnode,newelem]=surfboolean(node1,elem1,op2,node2,elem2,op3,node3,elem3,...)
%
% merge two or more triangular meshes and resolve intersecting elements
% 
% author: Qianqian Fang <fangq at nmr.mgh.harvard.edu>
%
% input:
%      node: node coordinates, dimension (nn,3)
%      elem: tetrahedral element or triangle surface (nn,3)
%      op:  a string of a boolean operator, possible op values include
%           'union' and 'diff'
%
% output:
%      newnode: the node coordinates after boolean operations, dimension (nn,3)
%      newelem: tetrahedral element or surfaces after boolean operations (nn,4) or (nhn,5)
%
% example:
%
%   [node1,elem1,face1]=meshabox([0 0 0],[10 10 10],1,1);
%   [node2,elem2,face2]=meshabox([0 0 0]+5,[10 10 10]+5,1,1);
%   [newnode,newface]=surfboolean(node1,face1,'union',node2,face2);
%   plotmesh(newnode,newface);
%   figure;
%   [newnode,newface]=surfboolean(node1,face1,'diff',node2,face2);
%   plotmesh(newnode,newface,'x>5');
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

len=length(varargin);
newnode=node;
newelem=elem;
if(len>0 && mod(len,3)~=0)
   error('you must give operator, node and element in trilet forms');
end

exesuff=getexeext;
exesuff=fallbackexeext(exesuff,'gtsset');

for i=1:3:len
   op=varargin{i};
   no=varargin{i+1};
   el=varargin{i+2};
   deletemeshfile(mwpath('pre_surfbool*.gts'));
   deletemeshfile(mwpath('post_surfbool.gts'));
   savegts(newnode(:,1:3),newelem(:,1:3),mwpath('pre_surfbool1.gts'));
   savegts(no(:,1:3),el(:,1:3),mwpath('pre_surfbool2.gts'));
   cmd=sprintf('"%s%s" "%s" "%s" "%s" -v > "%s"',mcpath('gtsset'),exesuff,...
       op,mwpath('pre_surfbool1.gts'),mwpath('pre_surfbool2.gts'),mwpath('post_surfbool.gts'));
   status=system(cmd);
   if(status~=0)
       error(['surface boolean command failed:' cmd]);
   end
   [newnode,newelem]=readgts(mwpath('post_surfbool.gts'));
end
