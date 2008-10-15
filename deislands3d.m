function cleanimg=deislands3d(img,sizelim)

maxisland=-1;
if(nargin==2) maxisland=sizelim; end

for i=1:size(img,1)
    fprintf(1,'scan x=%d\n',i);
    img(i,:,:)=deislands2d(img(i,:,:),maxisland);
end
for i=1:size(img,2)
    fprintf(1,'scan y=%d\n',i);
    img(:,i,:)=deislands2d(img(:,i,:),maxisland);
end
for i=1:size(img,3)
    fprintf(1,'scan z=%d\n',i);
    img(:,:,i)=deislands2d(img(:,:,i),maxisland);
end

cleanimg=img;
