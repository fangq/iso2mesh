function savedxf(node,elem,face,fname)
% savedxf(node,elem,face,fname)
%
% savedxf: save a surface mesh to DXF format
%
% author: Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
% date: 2010/04/25
%
% parameters:
%      node: input, surface node list, dimension (nn,3)
%      elem: input, tetrahedral element list, dimension (ne,4)
%      face: input, surface face element list, dimension (be,3)
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

fprintf(fid,'0\nSECTION\n2\nHEADER\n0\nENDSEC\n0\nSECTION\n2\nBLOCKS\n0\nBLOCK\n');

if(~isempty(node))
  fprintf(fid,'0\nVERTEX\n8\nMeshes\n10\n%f\n20\n%f\n30\n%f\n70\n192\n',node');
end

if(~isempty(face))
  fprintf(fid,'0\nVERTEX\n8\nMeshes\n62\n254\n10\n0.0\n20\n0.0\n30\n0.0\n70\n128\n71\n%d\n72\n%d\n73\n%d\n',(face-1)');
end

fprintf(fid,'0\nSEQEND\n0\nENDBLK\n0\nENDSEC\n0\nEOF\n');

fclose(fid);
