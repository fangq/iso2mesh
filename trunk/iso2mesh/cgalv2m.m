function [node,elem,face]=cgalv2m(vol,opt,maxvol)

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
	if(isfield(opt,'radbound')) ssize=opt.radbound; end
	if(isfield(opt,'angbound')) ang=opt.angbound; end
	if(isfield(opt,'surfapprox')) approx=opt.surfapprox; end
	if(isfield(opt,'reratio')) reratio=opt.reratio; end
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
