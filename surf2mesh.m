
function [node,elem,bound]=surf2mesh(v,f,p0,p1,elemnum,edgelen)
% surf2mesh - create quality volumetric mesh from isosurface patches
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/11/24
%
% parameters:
%      v: input, isosurface node list, dimension (nn,3)
%      f: input, isosurface face element list, dimension (be,3)
%      p0: input, coordinates of one corner of the bounding box, p0=[x0 y0 z0]
%      p1: input, coordinates of the other corner of the bounding box, p1=[x1 y1 z1]
%      elemnum: input, target surface element number for resampling
%      edgelen: input, maximum tetrahedral mesh edge length
%      node: output, node coordinates of the tetrahedral mesh
%      elem: output, element list of the tetrahedral mesh
%      bound: output, mesh surface element list of the tetrahedral mesh 
%             the last column denotes the boundary ID

exesuff='.exe';
if(isunix) exesuff=['.',mexext]; end

% first, resample the surface mesh with qslim
fprintf(1,'resampling surface mesh ...\n');
[no,el]=meshresample(v,f,elemnum);

% then smooth the resampled surface mesh (Laplace smoothing)
edges=surfedge(no,el);   
mask=zeros(size(no,1),1);
mask(unique(edges(:)))=1;  % =1 for edge nodes, =0 otherwise
[conn,connnum,count]=meshconn(el,length(no));
no=smoothsurf(no,mask,conn,2);

% remove end elements (all nodes are edge nodes)
el=delendelem(el,mask);

% dump surface mesh to .poly file format
savesurfpoly(no,el,p0,p1,'vesseltmp.poly');

% call tetgen to create volumetric mesh
delete('vesseltmp.1.*');
fprintf(1,'creating volumetric mesh from a surface mesh ...\n');
eval(['! tetgen',exesuff,' -qa',num2str(edgelen), ' vesseltmp.poly']);

% read in the generated mesh
[node,elem,bound]=readtetgen('vesseltmp.1');
