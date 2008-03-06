function facecell=finddisconnsurf(f)
% facecell=finddisconnsurf(facelist)
% 
% subroutine to extract disconnected surfaces from a 
% cluster of surfaces
% facelist: input, node indices for all surface triangles
% facecell: separated disconnected surface node indices
%
% Qianqian Fang (fangq@nmr.mgh.harvard.edu)
% Date: 2008/03/06
% 
% this subroutine is part of iso2mesh toolbox

facecell={};
subset=[];
while(length(f))
    [ii,jj]=find(sum(ismember(f,f(1,:))')');
	while(length(ii)>0)
		if(length(ii)==0) break; end
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
