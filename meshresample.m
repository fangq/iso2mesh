function [node,elem]=meshresample(v,f,elemnum)
% meshresample: resample mesh using qslim binary
% by FangQ, 2007/11/21

savesmf(v,f,'origmesh.dat')
delete newmesh.dat;
eval(['! qslim -t ', num2str(elemnum),' -m 1000 -O 2 -c 1 origmesh.dat -o newmesh.dat']);
[node,elem]=readsmf('newmesh.dat');
