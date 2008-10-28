function [node,elem]=meshresample(v,f,elemnum)
% [node,elem]=meshresample(v,f,elemnum)
%
% meshresample: resample mesh using CGAL mesh simplification code
% by FangQ, 2007/11/21

exesuff='.exe';
if(isunix) exesuff=['.',mexext]; end
if(strcmp(exesuff,'.mexa64')) % cgalsimp2.mexglx can be used for both
	exesuff='.mexglx';
end

saveoff(v,f,mwpath('pre_remesh.off'));
deletemeshfile('post_remesh.off');
eval(['! "' mcpath('cgalsimp2') exesuff '" "' mwpath('pre_remesh.off') '" ' num2str(elemnum) ' "' mwpath('post_remesh.off') '"']);

[node,elem]=readoff(mwpath('post_remesh.off'));
[node,I,J]=unique(node,'rows');
elem=J(elem);
saveoff(node,elem,mwpath('post_remesh.off'));
