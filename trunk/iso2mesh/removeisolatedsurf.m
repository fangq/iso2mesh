function fnew=removeisolatedsurf(v,f,maxdiameter)

fc=finddisconnsurf(f);
for i=1:length(fc)
    xdia=v(fc{i},1);
    xdia=max(xdia(:))-min(xdia(:));
    if(xdia<=maxdiameter) fc{i}=[]; continue; end
    ydia=v(fc{i},2);
    ydia=max(ydia(:))-min(ydia(:));
    if(ydia<=maxdiameter) fc{i}=[]; continue; end
    zdia=v(fc{i},3);
    zdia=max(zdia(:))-min(zdia(:));
    if(zdia<=maxdiameter) fc{i}=[]; continue; end
end
fnew=[];
for i=1:length(fc)
	if(length(fc{i})) fnew=[fnew;fc{i}]; end
end
if(size(fnew,1)~=size(f,1))
   fprintf(1,'removed %d elements of small isolated surfaces',size(f,1)-size(fnew,1)); 
end
