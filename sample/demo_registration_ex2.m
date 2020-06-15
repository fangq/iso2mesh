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

load sampledata


% start the metch-gui to perform the registration

%== Description of the workflow ==
%
% 1. when the GUI pops up, it will display the mesh and the points,
%    you can rotate both plots so that you can identify the matching 
%    features
% 2. switch on "Select" mode, then, click on a land-mark point on the point
%    plot, when a data-tip shows up, click "Add Selected" button
% 3. click on the corresponding position on the mesh, and click
%    "Add Selected"      
% 4. repeat the above for at least 4 point pairs (you can select more);
%    if you want to change views, switch off "Select" box and rotate;
%    after rotation, switch on "Select" box again
% 5. click "Initialize": this will create the initial mapping using the
%    selected point pairs
% 6. click "Optimize": this will fit the surface with the whole point cloud
% 7. click "Proj2Mesh": this will project the fitted point clouds onto the
%    mesh
% 8. you can quit the GUI by hit "Close", your results will be saved to reg
% 9. close the window 

if(exist('OCTAVE_VERSION')~=0)
        reg=metchgui_one(no,el,pt);
else
        reg=metchgui(no,el,pt);
end

