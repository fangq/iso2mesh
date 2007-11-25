function [node,elem]=readsmf(fname)
% readsmf: read simple model format
% by FangQ, 2007/11/21
node=[];
elem=[];
fid=fopen(fname,'rt');
while(~feof(fid))
    line=fgetl(fid);
    if(line(1)=='v')
        dd=sscanf(line,'v %f %f %f');
        if(length(dd)==3)
            node=[node;dd];
        end
    elseif(line(1)=='f')
        dd=sscanf(line,'f %d %d %d');
        if(length(dd)==3)
            elem=[elem;dd];
        end
    end
end
fclose(fid);
node=reshape(node,3,length(node)/3)';
elem=reshape(elem,3,length(elem)/3)';