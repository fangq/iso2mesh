function facecell=finddisconnsurf(f)
% facecell=finddisconnsurf(f)
% 
% subroutine to extract disconnected surfaces from a 
% cluster of surfaces
% 
% author: Qianqian Fang (fangq@nmr.mgh.harvard.edu)
% Date: 2008/03/06
%
% input: 
%     f: faces defined by node indices for all surface triangles
% output:
%     facecell: separated disconnected surface node indices
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

facecell={};
subset=[];
while(length(f))
    [ii,jj]=find(sum(ismember(f,f(1,:))')');
	while(length(ii)>0)
		if(isempty(ii)) break; end
		%ii=unique(ii);
		subset(end+1:end+length(ii),:)=f(ii,:);
		f(ii,:)=[];
	        [ii,jj]=find(sum(ismember(f,subset)')');
	end
	if(length(subset))
		facecell{end+1}=subset;
        	subset=[];
	end
end
