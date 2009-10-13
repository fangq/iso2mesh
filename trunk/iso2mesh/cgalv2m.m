function [node,elem,face]=cgalv2m(vol,opt,maxvol)
%   [node,elem,face]=cgalv2m(vol,opt,maxvol)
%   wrapper for CGAL 3D mesher (CGAL 3.5)
%   convert a binary (or multi-valued) volume to tetrahedral mesh
%
%   http://www.cgal.org/Manual/3.5/doc_html/cgal_manual/Mesh_3/Chapter_main.html
%
%   author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%   inputs:
%          vol: a volumetric binary image
%          ix,iy,iz: subvolume selection indices in x,y,z directions
%          opt: parameters for CGAL mesher, if opt is a structure, then
%              opt.radbound: defines the maximum surface element size
%              opt.angbound: defines the miminum angle of a surface triangle
%              opt.surfaceapprox: defines the maximum distance between the 
%                  center of the surface bounding circle and center of the 
%                  element bounding sphere
%              opt.reratio:  maximum radius-edge ratio
%              if opt is a scalar, it only specifies radbound.
%          maxvol: target maximum tetrahedral elem volume
%
%   outputs:
%          node: output, node coordinates of the tetrahedral mesh
%          elem: output, element list of the tetrahedral mesh, the last 
%               column is the region id
%          face: output, mesh surface element list of the tetrahedral mesh
%               the last column denotes the boundary ID
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

fprintf(1,'creating surface and tetrahedral mesh from a multi-domain volume ...\n');

dtype=class(vol);
if(~(islogical(vol) | strcmp(dtype,'uint8')))
	error('cgalmesher can only handle uint8 volumes, you have to convert your image to unit8 first.');
end

exesuff=getexeext;
if(strcmp(exesuff,'.mexa64')) % cgalmesh.mexglx can be used for both
	exesuff='.mexglx';
end

ang=30;
ssize=6;
approx=4;
reratio=3;

if(~isstruct(opt))
	ssize=opt;
end

if(isstruct(opt) & length(opt)==1)  % does not support settings for multiple labels
	if(isfield(opt,'radbound'))   ssize=opt.radbound; end
	if(isfield(opt,'angbound'))   ang=opt.angbound; end
	if(isfield(opt,'surfapprox')) approx=opt.surfapprox; end
	if(isfield(opt,'reratio'))    reratio=opt.reratio; end
end

saveinr(vol,mwpath('pre_cgalmesh.inr'));
deletemeshfile(mwpath('post_cgalmesh.mesh'));
cmd=sprintf('"%s%s" "%s" "%s" %f %f %f %f %f',mcpath('cgalmesh'),exesuff,...
    mwpath('pre_cgalmesh.inr'),mwpath('post_cgalmesh.mesh'),ang,ssize,...
    approx,reratio,maxvol);
system(cmd);
if(~exist(mwpath('post_cgalmesh.mesh'),'file'))
    error(['output file was not found, something must have gone wrong when running command: \n',cmd]);
end
[node,elem,face]=readmedit(mwpath('post_cgalmesh.mesh'));

fprintf(1,'surface and volume meshes complete\n');

