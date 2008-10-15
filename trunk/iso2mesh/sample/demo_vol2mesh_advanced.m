% load full head image (T1 MRI scan)

fid=fopen('T1.img','rb');
head = fread(fid, inf,'char');
fclose(fid);
head=reshape(head,[256 256 256]);

% load segmented brain images (by freesurfer recon_all)

fid=fopen('brain.img','rb');
brain = fread(fid, inf,'char');
fclose(fid);
brain=reshape(brain,[256 256 256]);

% fill holes in the head image and create the canonical binary volume
% this may take a few minutes for a 256x256x256 volume
tic
cleanimg=deislands3d(logical(head>20));
toc

% add brain image as additional segment
cleanimgfull=cleanimg+(brain>0);

% create volumetric tetrahedral mesh from the two-layer 3D images
% this may take another few minutes for a 256x256x256 volume
tic
[node,elem,bound]=vol2mesh(cleanimgfull,1:size(cleanimg,1),1:size(cleanimg,2),1:size(cleanimg,3),0.05,100,1);
toc

% plot the boundary surface of the generated mesh
h=slice(cleanimgfull,[],[120],[120 180]);
set(h,'linestyle','none')
hold on
hb=trisurf(bound(:,1:3),node(:,2),node(:,1),node(:,3));
set(hb,'facealpha',0.7)
axis equal
