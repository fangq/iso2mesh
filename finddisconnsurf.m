function facecell = finddisconnsurf(fa, opt)
%
% facecell=finddisconnsurf(f)
% 
% subroutine to extract disconnected surfaces from a 
% cluster of surfaces
%
% input: 
%     fa: faces defined by node indices for all surface triangles
%	  opt: connectivity type (default 'vertex'). Can be:
%	       'vertex': faces joined by at least 1 vertex.
%          'edge': faces joined by at least 1 edge.
%          'edge2': faces joined by at least a manifold edge (valence == 2)
%          'tetra': tetrahedrons joined by at least 1 face.
% output:
%     facecell: separated disconnected surface node indices
%
%Extended from iso2mesh toolbox by Salvatore Cunsolo (sal.cuns@gmail.com)
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
% author: Qianqian Fang (fangq@nmr.mgh.harvard.edu)
% Date: 2008/03/06

if nargin == 1
    opt = 'vertex';
end

if iscell(opt)
    conn = opt;
elseif strcmp(opt, 'vertex')
    vconn=cell(max(fa(:)), 1);
    for i=1:size(fa, 1)
        for j = 1:size(fa, 2)
            vconn{fa(i, j)}=[vconn{fa(i, j)}, i];
        end
    end
    conn=cell(size(fa, 1), 1);
    for i=1:size(fa,1)
        conn{i} = unique(horzcat(vconn{fa(i, :)}));
    end
elseif strcmp(opt, 'edge')
    alledges = sort([fa(:,[1,2]);fa(:,[2,3]);fa(:,[3,1])],2);
    [~, ~, IC] = unique(alledges,'rows');
    econn=cell(max(IC), 1);
    for i=1:size(fa, 1)
            econn{IC(i)}=[econn{IC(i)}, i];
            econn{IC(i+size(fa,1))}=[econn{IC(i+1*size(fa,1))}, i];
            econn{IC(i+2*size(fa,1))}=[econn{IC(i+2*size(fa,1))}, i];
    end
    conn=cell(size(fa, 1), 1);
    for i=1:size(fa,1)
        conn{i} = unique(horzcat(econn{IC([i,i+size(fa,1),i+2*size(fa,1)])}));
    end
elseif strcmp(opt, 'edge2')
    conn = mat2cell(edgeneighbors(fa), ones(size(fa, 1), 1), 3);
elseif strcmp(opt, 'tetra')
    allfaces = sort([fa(:,[1,2,3]);fa(:,[2,1,4]);fa(:,[1,3,4]);fa(:,[2,4,3])],2);  
    [~, ~, IC] = unique(allfaces,'rows');
    fconn=cell(max(IC), 1);
    for i=1:size(fa, 1)
            fconn{IC(i)}=[fconn{IC(i)}, i];
            fconn{IC(i+size(fa,1))}=[fconn{IC(i+1*size(fa,1))}, i];
            fconn{IC(i+2*size(fa,1))}=[fconn{IC(i+2*size(fa,1))}, i];
            fconn{IC(i+3*size(fa,1))}=[fconn{IC(i+3*size(fa,1))}, i];
    end
    conn=cell(size(fa, 1), 1);
    for i=1:size(fa,1)
        conn{i} = unique(horzcat(fconn{IC([i,i+size(fa,1),i+2*size(fa,1),i+3*size(fa,1)])}));
    end
end

facecell={};
faout = ones(size(fa, 1), 1);
while(1)
    subset = find(faout, 1);
    if isempty(subset) 
        break; 
    end
    linked = setdiff(horzcat(conn{subset}), [0, subset]);
    while any(linked)
        subset = [subset, linked];
        linked = setdiff(horzcat(conn{linked}), [0, subset]);
    end
    facecell{end+1} = fa(subset, :);
    faout(subset) = 0;
end
