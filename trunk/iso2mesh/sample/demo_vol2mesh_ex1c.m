%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   demo script for mesh generation from binarized volumetric image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% preparation
% user must add the path of iso2mesh to matlab path list
% addpath('../');

% user need to add the full path to .../iso2mesh/bin directory
% to windows/Linux/Unix PATH environment variable

%% load the sample data
load sampleVol2Mesh.mat

% volimage is a volumetric image such as an X-ray or MRI image
% A,b are registration matrix and vector, respectively
%% perform mesh generation

%% use the alternative 'simplify' method: first create voxel-based
% surface mesh, and then resample it to desired density.
% this method does not guarantee to be free of self-intersecting
% element, as 'cgalsurf' promises.

opt.radbound=2;
[node,elem,face]=v2m(uint8(volimage),0.5,opt,100,'cgalmesh');

%% visualize the resulting mesh

if(isoctavemesh)
        trimesh(face(:,1:3),node(:,1),node(:,2),node(:,3));
else
        trisurf(face(:,1:3),node(:,1),node(:,2),node(:,3));
end
axis equal;
