% to demonstrate how to use qmeshcut to produce cross-sectional plot 
% of an un-structured (tetrahedral) mesh

% run vol2mesh demo 1 to create a 3d mesh

demo_vol2mesh_ex1

% define a plane by 3 points, in this case, z=15

plane=[0 0 15; 0 20 15; 20 0 15];

% run qmeshcut to get the cross-section information at z=15
% use the x-coordinates as the nodal values

[cutpos,cutvalue,facedata]=qmeshcut(elem,node,node(:,1),plane);

% plot your results

figure;
trimesh(bound(:,1:3),node(:,1),node(:,2),node(:,3),'facecolor','none');
hold on;
patch('Vertices',cutpos,'Faces',facedata,'FaceVertexCData',cutvalue,'facecolor','interp');
axis equal;
