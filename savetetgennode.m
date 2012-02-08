function savetetgennode(newpt,fname)

hasprop=0;
attrstr='';
markers='';

fid=fopen(fname,'wt');
if(fid==0)
        error(['can not write to file ' fname]);
end
if(size(newpt,2)>=5)
        hasprop=size(newpt,2)-4;
        attrstr=repmat('%e ',1,hasprop);
end
if(size(newpt,2)>=4)
        markers='%d';
end
fprintf(fid,'%d %d %d %d\n',size(newpt,1),3,hasprop,size(newpt,2)>=4);
fprintf(fid,['%d %e %e %e ' attrstr markers '\n'], [(1:size(newpt,1))'-1 newpt]');
fclose(fid);
