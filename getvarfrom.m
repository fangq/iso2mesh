function p=getvarfrom(ws,name)
isdefined=evalin(ws,['exist(''' name ''')']);
if(isdefined==1)
        p=evalin(ws,name);
else
        p=[];
end

