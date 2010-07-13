% This example calls cgalmesher to mesh a segmented
% brain volume. The segmentation was done by FreeSurfer
% and there are 41 different types of tissues. Each tissue
% type is labeled by a unique integer.

fprintf(1,'loading segmented brain image...\n');
for i=1:256
  brain(:,:,i)=imread('headseg.tif',i);
end
brain=uint8(brain);

% call cgalmesher to mesh the segmented volume
% this will take 30 seconds on an Intel P4 2.4GHz PC

fprintf(1,'meshing the segmented brain (this may take a few minutes) ...\n');

%[node,elem,face]=v2m(brain,[],3,100,'cgalmesh');
[node,elem,face]=v2m(brain,[],2,100,'cgalmesh');

centroid=meshcentroid(node(:,1:4),face(:,1:3));

hs=plotmesh(node,face(:,1:3),'y>100');

axis equal;
title('cross-cut view of the generated surface mesh');

% find the sub-region number 3, it happens to be the left-hemisphere
% gray-matter. Use volface to extract the pial surface.

fprintf(1,'extracting the left-hemisphere pial surface\n')

LHwhitemat=elem(find(elem(:,5)==3),:);
wmsurf=volface(LHwhitemat(:,1:4));

figure;
hs=plotmesh(node,wmsurf);
axis equal;
title('pre-smoothed pial surface');


fprintf(1,'performing mesh smoothing on the pial surface\n')

[no,el]=removeisolatednode(node,wmsurf);
conn=meshconn(el,length(no));
wmno=smoothsurf(no(:,1:3),[],conn,3,0.5,'laplacianhc',0.5);

figure;
hs=plotmesh(wmno,el);
axis equal;
title('smoothed pial surface for left-hemisphere');


fprintf(1,'generate volumetric mesh from the smoothed pial surface \n')

[wmnode,wmelem,wmface]=s2m(wmno(:,1:3),el(:,1:3),1,200);
