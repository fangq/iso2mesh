function savegts(v,f,fname,edges)
%
% savegts(v,f,fname,edges)
%
% save a surface mesh to GNU Triangulated Surface Format (GTS)
%
% author: Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
% date: 2011/02/23
%
% input:
%      v: input, surface node list, dimension (nn,3)
%      f: input, surface face element list, dimension (be,3)
%      fname: output file name
%      edges: edge list, if ignored, savegts will compute
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

fid=fopen(fname,'wt');
if(fid==-1)
    error('You do not have permission to save mesh files.');
end
v=v(:,1:3);
f=f(:,1:3);
if(nargin<=3)
    edges=meshedge(f);
end
fprintf(fid,'%d %d %d\n',size(v,1),size(edges,1),size(f,1));
fprintf(fid,'%f %f %f\n',v');
fprintf(fid,'%d %d\n',edges');
fprintf(fid,'%d %d %d\n',f');
fclose(fid);
