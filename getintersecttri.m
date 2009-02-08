function eid=getintersecttri(tmppath)
% eid=getintersecttri(tmppath)
% get the IDs of self-intersecting elements from tetgen
% call this when tetgen complains about self-intersection
%
% input: 
%   tmppath: working dir, use mwpath('') in most cases
% output:
%   eid: an array of all intersecting surface elements, 
%     one can read the corresponding node/elem by
%     [no,el]=readoff(mwpath('post_vmesh.off'));

[status,str] = system(['"' mcpath('tetgen') getexeext '" -d "' ...
                        tmppath filesep 'post_vmesh.poly"']);

eid=[];
if(status==0)
    id=regexp(str, ' #([0-9]+) ', 'tokens');
    for j=1:length(id)
        eid(end+1)=str2num(id{j}{1});
    end
end
eid=unique(eid);
