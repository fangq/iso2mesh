function cleanimg=deislands2d(img,sizelim)

img=squeeze(img);
maxisland=-1;
if(nargin==2) maxisland=sizelim; end

islands={};

cleanimg=zeros(size(img));
if(sum(img(:)))
    img=imclose(img, strel('disk',3));
    islands=bwislands(img);
end

if(length(islands))
    % remove small islands of the foreground
    maxblock=-1;
    maxblockid=-1;
    if(maxisland<0)
      for i=1:length(islands)
        if(length(islands{i})>maxblock)
            maxblockid=i;
            maxblock=length(islands{i});
        end
      end
      if(maxblock>0)
          cleanimg(islands{maxblockid})=1;
      end
    else
      for i=1:length(islands)
        if(length(islands{i})>maxisland)
            cleanimg(islands{i})=1;
        end
      end
    end

    % remote small islands of the background
    
    cleanimg=imfill(cleanimg,'holes');
end
