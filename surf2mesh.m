function [node,elem,bound]=surf2mesh(v,f,p0,p1,keepratio,maxvol,regions,holes)
% surf2mesh - create quality volumetric mesh from isosurface patches
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/11/24
%
% parameters:
%      v: input, isosurface node list, dimension (nn,3)
%      f: input, isosurface face element list, dimension (be,3)
%      p0: input, coordinates of one corner of the bounding box, p0=[x0 y0 z0]
%      p1: input, coordinates of the other corner of the bounding box, p1=[x1 y1 z1]
%      keepratio: input, percentage of elements being kept after the simplification
%      maxvol: input, maximum tetrahedra element volume
%      node: output, node coordinates of the tetrahedral mesh
%      elem: output, element list of the tetrahedral mesh
%      bound: output, mesh surface element list of the tetrahedral mesh 
%             the last column denotes the boundary ID

exesuff=getexeext;

% first, resample the surface mesh with cgal
if(keepratio<1-1e-9)
	fprintf(1,'resampling surface mesh ...\n');
	[no,el]=meshresample(v,f,keepratio);
	el=unique(sort(el,2),'rows');

	% then smooth the resampled surface mesh (Laplace smoothing)

	%% edges=surfedge(el);  % disable on 12/05/08, very slow on octave
	%% mask=zeros(size(no,1),1);
	%% mask(unique(edges(:)))=1;  % =1 for edge nodes, =0 otherwise
	%[conn,connnum,count]=meshconn(el,length(no));
	%no=smoothsurf(no,mask,conn,2);

	% remove end elements (all nodes are edge nodes)
	%el=delendelem(el,mask);
else
	no=v;
	el=f;
end
if(nargin==6)
	regions=[];
	holes=[];
elseif(nargin==6)
	holes=[];
end
% dump surface mesh to .poly file format
savesurfpoly(no,el,holes,regions,p0,p1,mwpath('post_vmesh.poly'));

% call tetgen to create volumetric mesh
deletemeshfile('post_vmesh.1.*');
fprintf(1,'creating volumetric mesh from a surface mesh ...\n');
system([' "', mcpath('tetgen'), exesuff,'" -A -q1.414a',num2str(maxvol), ' "' mwpath('post_vmesh.poly') '"']);
%eval(['! tetgen',exesuff,' -d' ' post_vmesh.poly']);

% read in the generated mesh
[node,elem,bound]=readtetgen(mwpath('post_vmesh.1'));
