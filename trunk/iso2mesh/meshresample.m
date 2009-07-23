function [node,elem]=meshresample(v,f,keepratio)
% [node,elem]=meshresample(v,f,elemnum)
%
% meshresample: resample mesh using CGAL mesh simplification utility
%
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/11/12
%
% input:
%    v: list of nodes
%    f: list of surface elements (each row for each triangle)
%    keepratio: decimation rate, a number less than 1, as the percentage
%               of the elements after the sampling
% output:
%    node: the node coordinates of the sampled surface mesh
%    elem: the element list of the sampled surface mesh
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

exesuff=getexeext;
if(strcmp(exesuff,'.mexa64')) % cgalsimp2.mexglx can be used for both
	exesuff='.mexglx';
end

saveoff(v,f,mwpath('pre_remesh.off'));
deletemeshfile(mwpath('post_remesh.off'));
system([' "' mcpath('cgalsimp2') exesuff '" "' mwpath('pre_remesh.off') '" ' num2str(keepratio) ' "' mwpath('post_remesh.off') '"']);
[node,elem]=readoff(mwpath('post_remesh.off'));
if(length(node)==0)
    error(['Your input mesh contains topological defects, and the ',...
           'mesh resampling utility aborted during processing. Please ',...
           'repair your input mesh with meshcheckrepair function first and ',...
           'pass the repaired mesh to meshresample.'] );
end
[node,I,J]=unique(node,'rows');
elem=J(elem);
saveoff(node,elem,mwpath('post_remesh.off'));
