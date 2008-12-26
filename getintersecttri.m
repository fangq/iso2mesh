function eid=getintersecttri(tmppath)
[status,str] = system(['"' mcpath('tetgen') getexeext '" -d "' tmppath filesep 'post_vmesh.poly"']);

eid=[];
if(status==0)
    id=regexp(str, ' #([0-9]+) ', 'tokens');
    for j=1:length(id)
        eid(end+1)=str2num(id{j}{1});
    end
end
eid=unique(eid);