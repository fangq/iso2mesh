function saveinr(vol,fname)
% savesmf: save a surface mesh to INR Format
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2009/01/04
%
% parameters:
%      vol: input, a binary volume
%      fname: output file name

%try
	fid=fopen(fname,'wb');
	dtype=class(vol);
	if(islogical(vol) | strcmp(dtype,'uint8'))
	   btype='unsigned fixed';
	   dtype='uint8';
	   bitlen=8;
	elseif(strcmp(dtype,'uint16'))
	   btype='unsigned fixed';
           dtype='uint16';
	   bitlen=16;	
	elseif(strcmp(dtype,'float'))
	   btype='float';
           dtype='float';
	   bitlen=32;
	elseif(strcmp(dtype,'double'))
	   btype='float';
           dtype='double';
	   bitlen=64;
	else
	   error('volume format not supported');
	end
	header=sprintf(['#INRIMAGE-4#{\nXDIM=%d\nYDIM=%d\nZDIM=%d\nVDIM=1\nTYPE=%s\n' ...
	  'PIXSIZE=%d bits\nCPU=decm\nVX=1\nVY=1\nVZ=1\n'],size(vol),btype,bitlen);
	header=[header char(10*ones(1,256-4-length(header))) '##}' char(10)];
	size(header)
	fwrite(fid,header,'char');
        fwrite(fid,vol,dtype);
	fclose(fid);
%catch
%    error(['You do not have permission to save INR files, if you are working in a multi-user ',...
%         'environment, such as Unix/Linux and there are other users using iso2mesh, ',...
%         'you may need to define ISO2MESH_SESSION=''yourstring'' to make your output ',...
%         'files different from others; if you do not have permission to ',mwpath(''),...
%         ' as the temporary directory, you have to define ISO2MESH_TEMP=''/folder/you/have/write/permission'' ',...
%         'in matlab/octave base workspace.']);
%end
