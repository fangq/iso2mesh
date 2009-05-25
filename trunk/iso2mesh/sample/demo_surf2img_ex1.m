%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   demo script to convert a closed surface to a binary image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% preparation
% user must add the path of iso2mesh to matlab path list
% addpath('../');

%% load the sample data
load sampleVol2Mesh.mat

% first, generate a surface from the original image
% similar to demo_shortcuts_ex1.m

[node,face,regions,holes]=v2s(volimage,0.05,3);

mdim=ceil(max(node)+1);

img=surf2img(node,face(:,1:3),0:0.5:mdim(1),0:0.5:mdim(2),0:0.5:mdim(3));

imagesc(squeeze(img(:,:,20))); % z=10

hold on

z0=10;
plane=[min(node(:,1)) min(node(:,2)) z0
       min(node(:,1)) max(node(:,2)) z0
       max(node(:,1)) min(node(:,2)) z0];

% run qmeshcut to get the cross-section information at z=mean(node(:,1))
% use the x-coordinates as the nodal values

[bcutpos,bcutvalue,bcutedges]=qmeshcut(face(:,1:3),node,node(:,1),plane);
[bcutpos,bcutedges]=removedupnodes(bcutpos,bcutedges);
bcutloop=extractloops(bcutedges);
bcutloop(isnan(bcutloop))=[]; % there can be multiple loops, remove the separators
plot(bcutpos(bcutloop,2)*2,bcutpos(bcutloop,1)*2,'w');

if(0 & exist('imfill'))
   img2=imfill(img,'holes')+img;
   figure;
   imagesc(squeeze(img2(:,:,20))); % z=10
   hold on;
   plot(bcutpos(bcutloop,2)*2,bcutpos(bcutloop,1)*2,'y.');
end
