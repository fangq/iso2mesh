%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   demo script for mesh generation from a bounding box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% preparation
% user must add the path of iso2mesh to matlab path list
% addpath('../');

% user need to add the full path to .../iso2mesh/bin directory
% to windows/Linux/Unix PATH environment variable

%% create mesh

% another option for setting temporary tetgen file locations
% % where to store the tetgen files
% ISO2MESH_TEMP = '/Users/srobertp/software/geometric_pdes_matlab/tmp_iso2mesh_files';
% % prefix to tetgen filenames
% ISO2MESH_SESSION = 'srp_';


p0 = [0,0,0];
p1 = [1,1,1];
min_volume = (0.1)^3; 
radius_to_edge_ratio = 1.2; % default = 1.414
min_angle = 18; % default = 0
nodesize = 1; % default = 1

[node,elem,face]=meshabox_with_gridoptions(p0,p1,min_volume,radius_to_edge_ratio,min_angle,nodesize);


%% visualize the resulting mesh
plotmesh(node,face(:,1:3));
axis equal;
