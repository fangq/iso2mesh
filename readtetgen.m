function [node,elem,bound]=readtetgen(fstub)
% readtetgen: read tetgen output files
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/11/21
%
% parameters:
%    fstub: file name stub

% read node file
fp=fopen([fstub,'.node'],'rt');
if(fp==0) 
	error('node file is missing!'); 
end
[dim,count] = fscanf(fp,'%d',4);
if(count<4) error('wrong node file'); end
node=fscanf(fp,'%f',[4,dim(1)]);
node=node(2:4,:)';
fclose(fp);

% read element file
fp=fopen([fstub,'.ele'],'rt');
if(fp==0) 
        error('elem file is missing!'); 
end
[dim,count] = fscanf(fp,'%d',3);
if(count<3) error('wrong elem file'); end
elem=fscanf(fp,'%d',[5,dim(1)]);
elem=elem(2:end,:)'+1;
fclose(fp);

% read surface mesh file
fp=fopen([fstub,'.face'],'rt');
if(fp==0)
        error('surface data file is missing!');
end
[dim,count] = fscanf(fp,'%d',2);
if(count<2) error('wrong surface file'); end
bound=fscanf(fp,'%d',[5,dim(1)]);
bound=[bound(2:end-1,:)+1;bound(end,:)]';
fclose(fp);

