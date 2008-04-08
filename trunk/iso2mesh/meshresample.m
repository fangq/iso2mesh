function [node,elem]=meshresample(v,f,elemnum)
% meshresample: resample mesh using CGAL mesh simplification code
% by FangQ, 2007/11/21

exesuff='.exe';
if(isunix) exesuff=['.',mexext]; end

%savesmf(v,f,'origmesh.dat')
saveoff(v,f,'origmesh.off');
delete newmesh.dat;
%eval(['! qslim',exesuff,' -t ', num2str(elemnum),' -m 1000 -O 2 -c 1 origmesh.dat -o newmesh.dat']);
eval(['! cgalsimp2',exesuff,' origmesh.off ', num2str(elemnum), ' newmesh.dat']);
[node,elem]=readoff('newmesh.dat');
