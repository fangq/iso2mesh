%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        Sample Data and Metch Registration Sessions        %
%                                                           %
%           by Qianqian Fang <q.fang at neu.edu>            %
%                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% first of all, make sure you've already add the metch root
% folder to your matlab/octave search path list

% load the sample data, where
%   no: the node coordinates of a surface mesh
%   el: the surface triangles
%   pt: the point cloud to be registered

disp('(*)First load the mesh and point cloud. Hit Enter to continue...');
pause;

load sampledata
if(exist('OCTAVE_VERSION')~=0)
	trimesh(el,no(:,1),no(:,2),no(:,3));
else
	cla;
	trisurf(el,no(:,1),no(:,2),no(:,3));
end
title('Metch toolbox demonstration');
axis equal;
hold on;

% use metch functions to perform the registration

pnum=size(pt,1);

% define a number of point pairs to initialize the registration
disp('(*)Create 4 mapping pairs to initialize the mapping. Hit Enter to continue...');
pause;

% select 4 land-marks on the point cloud (specified by their indicies)
ptidx=[4 107 1 190];
ptselected=pt(ptidx,:);

% find the corresponding land-marks on the mesh
meshidx=[3173 1715 156 1740];
meshselected=no(meshidx,:);

% calculate the affine mapping using these point pairs
[A0,b0]=affinemap(ptselected,meshselected)

disp('(*)Display the updated points. Hit Enter to continue...');
pause;

% a rough registration from the selected point pairs
points_after_initmap=(A0*pt'+repmat(b0(:),1,pnum))';
plot3(points_after_initmap(:,1),points_after_initmap(:,2),points_after_initmap(:,3),'r.');

disp('(*)Optimize the mapping matrix to fit the surface. Hit Enter to continue...');
pause;

% set pmask: if pmask(i) is -1, it is a free nodes to be optimized
%            if pmask(i) is 0, it is fixed
%            if pmask(i) is a positive number, it is the index of 
%               the mesh node to map to

pmask=-1*ones(pnum,1);
pmask(ptidx)=meshidx;

% perform mesh registration with Gauss-Newton method using A0/b0 
% as initial guess
[A,b,newpos]=regpt2surf(no,el,pt,pmask,A0,b0,ones(12,1),10);
A
b

disp('(*)Display the optimized point cloud. Hit Enter to continue...');
pause;

% update point cloud with the optimized mapping
points_after_optimize=(A*pt'+repmat(b(:),1,pnum))';

plot3(points_after_optimize(:,1),points_after_optimize(:,2),points_after_optimize(:,3),'g+');

disp('(*)Project the point cloud on the surface. Hit Enter to continue...');
pause;

% project the optimized point cloud onto the surface, and make
% sure the comformity

nv=nodesurfnorm(no,el);
[d2surf,cn]=dist2surf(no,nv,points_after_optimize);
[points_after_proj eid weights]=proj2mesh(no,el,points_after_optimize,nv,cn);

disp('(*)Display the final results. Hit Enter to continue...');
pause;

plot3(points_after_proj(:,1),points_after_proj(:,2),points_after_proj(:,3),'c*');

legend('surface mesh','points after initial map','points after optimized map',...
      'points after projection');
