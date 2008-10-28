function cleanimg=deislands3d(img,sizelim)

maxisland=-1;
if(nargin==2) maxisland=sizelim; end

for i=1:size(img,1)
    if(mod(i,10)==0) fprintf(1,'processing slice x=%d\n',i); end
    img(i,:,:)=deislands2d(img(i,:,:),maxisland);
end
for i=1:size(img,2)
    if(mod(i,10)==0) fprintf(1,'processing slice y=%d\n',i); end
    img(:,i,:)=deislands2d(img(:,i,:),maxisland);
end
for i=1:size(img,3)
    if(mod(i,10)==0) fprintf(1,'processing slice z=%d\n',i); end
    img(:,:,i)=deislands2d(img(:,:,i),maxisland);
end

cleanimg=img;
