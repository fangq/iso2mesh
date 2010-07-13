%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Create meshes for a sphere inside a cubic domain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% preparation

% you have to add the path to iso2mesh toolbox 
% addpath('/path/to/iso2mesh/toolbox/');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Part 0.  How to Create a Spherical Mesh Using Iso2mesh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% first create a gray-scale field representing distance from the sphere center

dim=60;
[xi,yi,zi]=meshgrid(0:0.5:dim,0:0.5:dim,0:0.5:dim);
dist=sqrt((xi-30).^2+(yi-30).^2+(zi-30).^2);
clear xi yi zi;

% extract a level-set at v=20, being a sphere with R=20
% the maximum element size of the surface triangles is 2

[v0,f0]=vol2restrictedtri(dist,20,[60 60 60],60*60*20,30,2,2,40000);
v0=(v0-0.5)*0.5;

% iso2mesh will also produce a surface for the bounding box, remove it
facecell=finddisconnsurf(f0);
sphsurf=facecell{1};

if( sum((v0(sphsurf(1,1),:)-[30 30 30]).^2) > 25*25 )
   sphsurf=facecell{2};
end
plotmesh(v0,sphsurf);
axis equal;
idx=unique(sphsurf);  % this is the index of all the nodes on the sphere

% show the histogram of the displacement error for the nodes on the sphere
r0=sqrt((v0(idx,1)-30).^2+(v0(idx,2)-30).^2+(v0(idx,3)-30).^2);
figure;hist(r0,100);

% we only take the nodes on the surface
[no,el]=removeisolatednode(v0,sphsurf);
[no,el]=meshcheckrepair(no,el);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Part I.  A Coarse Mesh for a Sphere Inside a Box with Refinement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate a coarse volumetric mesh from the sphere with an additional bounding box
% the maximum element volume is 8

ISO2MESH_SESSION='demo_sph3_';

srcpos=[30. 30. 0.];                     % set the center of the ROI
fixednodes=[30.,30.,0.1; 30 30 30];     % add control points so we can refine mesh densities there
nodesize=[ones(size(no,1),1) ; 0.2; 4];  % set target edge size of 1 for all nodes on the sphere
                                         % target edge size 0.3 near (30,30,0.05)
                                         % and target edge size 4 near (30,30,30)
nfull=[no;fixednodes];                   % append additional control points
[node3,elem3,face3]=surf2mesh([nfull,nodesize],el,[0 0 0],[61 61 61],1,8,[30 30 30],[],[2 2 2 2 6 6 6 6]);
                             % ^- add node size as the last            ^ max volume     ^- edge sizes at the 8 
                             %    column to node                                           corners of the bounding box
[node3,elem3]=sortmesh(srcpos,node3,elem3,1:4);  % reorder the nodes/elements 
                                                 % so that the nodes near earch order
                                                 % are more clustered in the memory
elem3(:,1:4)=meshreorient(node3,elem3(:,1:4));   % reorient elements to ensure the volumns are positive

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Part II.  A Dense Mesh for a Sphere Inside a Box with Refinement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate a dense volumetric mesh from the sphere with an additional bounding box
% the maximum element volume is 2

ISO2MESH_SESSION='demo_sph2_';

nodesize=[0.7*ones(size(no,1),1) ; 0.2; 2];  % set target edge size to 0.7 near the sphere
                                             % 0.2 near (30,30,0.5) and 2 near (30,30,30)
[node2,elem2,face2]=surf2mesh([nfull,nodesize],el,[0 0 0],[61 61 61],1,2,[30 30 30],[],[1 1 1 1 5 5 5 5]);

figure; plotmesh(node2,face2(:,1:3),'y>30');axis equal;

[node2,elem2]=sortmesh(srcpos,node2,elem2,1:4);
elem2(:,1:4)=meshreorient(node2,elem2(:,1:4));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Part III.  A Coarse Mesh for a Sphere Inside a Box without Refinement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ISO2MESH_SESSION='demo_sph1_';

% reduce the surface node numbers to 20%  
[no2,el2]=meshresample(no,el,0.2);  % down sample the sphere mesh

% using the coarse spherical surface, we generate a coarse volumetric
% mesh with maximum volume of 10

[node1,elem1,face1]=surf2mesh(no2,el2,[0 0 0],[61 61 61],1,10,[30 30 30],[],1);
[node1,elem1]=sortmesh(srcpos,node1,elem1,1:4);
elem1(:,1:4)=meshreorient(node1,elem1(:,1:4));

clear ISO2MESH_SESSION
