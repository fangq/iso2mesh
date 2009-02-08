function saveoff(v,f,fname)
% saveoff(v,f,fname)
% savesmf: save a surface mesh to  Geomview Object File Format
% author: Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/03/28
%
% parameters:
%      v: input, surface node list, dimension (nn,3)
%      f: input, surface face element list, dimension (be,3)
%      fname: output file name

fid=fopen(fname,'wt');
if(fid==-1)
    error(['You do not have permission to save mesh files, if you are working in a multi-user ',...
         'environment, such as Unix/Linux and there are other users using iso2mesh, ',...
         'you may need to define ISO2MESH_SESSION=''yourstring'' to make your output ',...
         'files different from others; if you do not have permission to ',mwpath(''),...
         ' as the temporary directory, you have to define ISO2MESH_TEMP=''/folder/you/have/write/permission'' ',...
         'in matlab/octave base workspace.']);
end
fprintf(fid,'OFF\n');
fprintf(fid,'%d %d %d\n',length(v),length(f),0);
fprintf(fid,'%f %f %f\n',v');
fprintf(fid,'3 %d %d %d\n',(f-1)');
fclose(fid);

