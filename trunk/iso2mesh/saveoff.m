function saveoff(v,f,fname)
% savesmf: save a surface mesh to  Geomview Object File Format
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/03/28
%
% parameters:
%      v: input, surface node list, dimension (nn,3)
%      f: input, surface face element list, dimension (be,3)
%      fname: output file name

fid=fopen(fname,'wt');
fprintf(fid,'OFF\n');
fprintf(fid,'%d %d %d\n',length(v),length(f),0);
fprintf(fid,'%f %f %f\n',v');
fprintf(fid,'3 %d %d %d\n',(f-1)');
fclose(fid);
