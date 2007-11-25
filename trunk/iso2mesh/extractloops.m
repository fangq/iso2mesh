function loops=extractloops(edges)
% extractloops: extract individual loops from an edge table of a loop
%               collection
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/11/21
%
% parameters:   
%    edges:  two column matrix recording the starting/ending 
%             points of all edge segments
%    loops:  output, a single vector separated by NaN, each segment
%             is a close-polygon consisted by node IDs

loops=[];
loops=[loops,edges(1,:)];
loophead=edges(1,1);
loopend=edges(1,end);
edges(1,:)=[];

while(length(edges))
    idx=[find(edges(:,1)==loopend),find(edges(:,2)==loopend)];
    if(length(idx)>1) error('topology is unsupported'); end
    if(length(idx)==1)
        newend=setdiff(edges(idx,:),loopend);
        if(newend==loophead)
            loops=[loops,nan];
            edges(idx,:)=[];
            if(size(edges,1)==0) break; end
            loops=[loops,edges(1,:)];
            loophead=edges(1,1);
            loopend=edges(1,end);
            edges(1,:)=[];
            continue;
        else
            loops=[loops,newend];
        end
        loopend=newend;
        edges(idx,:)=[];
    end
end
    
