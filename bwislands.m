function islands=bwislands(img)

img=logical(1-img);
idx=find(1-img(:));
islands={};

count=1;
while(length(idx))
    [I,J]=ind2sub(size(img),idx(1));
	imgnew=imfill(img,[I,J]);
	islands{count}=find(imgnew~=img);
	count=count+1;
	img=imgnew;
	idx=find(1-img(:));
end


