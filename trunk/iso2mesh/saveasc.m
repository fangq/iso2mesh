function saveasc(v,f,fname)
%
% saveasc(v,f,fname)
%
% save a surface mesh to FreeSurfer ASC mesh format
%
% author: Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
% date: 2009/04/02
%
% input:
%      v: input, surface node list, dimension (nn,3)
%      f: input, surface face element list, dimension (be,3)
%      fname: output file name
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

fid=fopen(fname,'wt');
if(fid==-1)
    error(['You do not have permission to save mesh files, if you are working in a multi-user ',...
         'environment, such as Unix/Linux and there are other users using iso2mesh, ',...
         'you may need to define ISO2MESH_SESSION=''yourstring'' to make your output ',...
         'files different from others; if you do not have permission to ',mwpath(''),...
         ' as the temporary directory, you have to define ISO2MESH_TEMP=''/folder/you/have/write/permission'' ',...
         'in matlab/octave base workspace.']);
end
fprintf(fid,'#!ascii raw data file %s\n',fname);
fprintf(fid,'%d %d\n',length(v),length(f));
fprintf(fid,'%f %f %f 0\n',v');
fprintf(fid,'%d %d %d 0\n',(f-1)');
fclose(fid);
