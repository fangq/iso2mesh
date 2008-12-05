%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   demo script for mesh generation from surface patches and bounding box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% preparation
% user must add the path of iso2mesh to matlab path list
% addpath('../');

% user need to add the full path to .../iso2mesh/bin directory
% to windows/Linux/Unix PATH environment variable

%% load the sample data
load surfmesh_demo.mat

% f and v stores the surface patch faces and nodes
%% perform mesh generation
[node,elem,bound]=surf2mesh(v,f,[1 1 1],[100 100 100],0.1,25);

%% visualize the resulting mesh
if(isoctavemesh)
	trimesh(bound(:,1:3),node(:,1),node(:,2),node(:,3));
else
	trisurf(bound(:,1:3),node(:,1),node(:,2),node(:,3));
end
axis equal;
