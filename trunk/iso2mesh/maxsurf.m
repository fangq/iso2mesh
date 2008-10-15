function f=maxsurf(facecell)
maxsize=-1;
maxid=-1;

for i=1:length(facecell)
	if(length(facecell{i})>maxsize)
		maxsize=length(facecell{i});
		maxid=i;
	end
end
f=[];
if(maxid>0)
	f=facecell{maxid};
end
