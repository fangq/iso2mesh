% qmeshcut demonstration
%
% by Qianqian Fang, <fangq at nmr.mgh.harvard.edu>
%
% to demonstrate how to use qmeshcut to produce cross-sectional plot 
% of an un-structured (tetrahedral) mesh

% run vol2mesh demo 1 to create a 3d mesh

demo_vol2mesh_ex1

% define a plane by 3 points, in this case, z=mean(node(:,3))

z0=mean(node(:,3));

plane=[min(node(:,1)) min(node(:,2)) z0
       min(node(:,1)) max(node(:,2)) z0
       max(node(:,1)) min(node(:,2)) z0];

% run qmeshcut to get the cross-section information at z=mean(node(:,1))
% use the x-coordinates as the nodal values

[cutpos,cutvalue,facedata]=qmeshcut(elem,node,node(:,1),plane);

% plot your results

figure;
hsurf=trimesh(bound(:,1:3),node(:,1),node(:,2),node(:,3),'facecolor','none');
hold on;
hcut=patch('Vertices',cutpos,'Faces',facedata,'FaceVertexCData',cutvalue,'facecolor','interp');
%set(hcut, 'linestyle','none')
axis equal;
