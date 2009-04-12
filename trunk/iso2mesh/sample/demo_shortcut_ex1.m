%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   demo script for using short-hand version of the meshing wrappers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% preparation
% user must add the path of iso2mesh to matlab path list
% addpath('../');

% user need to add the full path to .../iso2mesh/bin directory
% to windows/Linux/Unix PATH environment variable

%% load the sample data
load sampleVol2Mesh.mat

% volimage is a volumetric image such as an X-ray or MRI image
%% v2m is the short-hand version of vol2mesh

% mesh volimage at threshold level 0.05, max surface element size 3,
% maximum tetrahedral element volume 2

[node,elem,face]=v2m(volimage,0.05,3,2);

%% visualize the resulting mesh
subplot(211);
if(isoctavemesh)
        trimesh(face(:,1:3),node(:,1),node(:,2),node(:,3));
else
        trisurf(face(:,1:3),node(:,1),node(:,2),node(:,3));
end
axis equal;

%% alternatively, one can call vol2surf and surf2mesh separately

% v2s: shorthand version of vol2surf, s2m: shorthand version of surf2mesh

[node,face,regions,holes]=v2s(volimage,0.05,3);
[node,elem,face]=s2m(node,face,1,2);

%% visualize the resulting mesh
subplot(212)
if(isoctavemesh)
        trimesh(face(:,1:3),node(:,1),node(:,2),node(:,3));
else
        trisurf(face(:,1:3),node(:,1),node(:,2),node(:,3));
end
axis equal;

