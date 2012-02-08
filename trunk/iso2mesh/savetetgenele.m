function savetetgenele(elem,fname)

hasprop=0;
attrstr='';
markers='';

fid=fopen(fname,'wt');
if(fid==0)
        error(['can not write to file ' fname]);
end
if(size(elem,2)>=6)
        hasprop=size(elem,2)-5;
        attrstr=repmat('%e ',1,hasprop);
end
if(size(elem,2)>=5)
        markers='%d';
end
elem(:,1:4)=elem(:,1:4)-1;
fprintf(fid,'%d %d %d\n',size(elem,1),4,hasprop+(size(elem,2)>=5));
fprintf(fid,['%d %d %d %d %d ' attrstr markers '\n'], [(1:size(elem,1))'-1 elem]');
fclose(fid);
