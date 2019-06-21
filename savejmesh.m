function savejmesh(node,face,elem,fname,varargin)
%
% savejmesh(node,face,elem,fname,opt)
%
% export a mesh to the JMesh format defined in http://github.com/fangq/jmesh
%
% author: Qianqian Fang, <q.fang at neu.edu>
% date: 2011/10/06
%
% input:
%      node: input, node list, dimension (nn,3)
%      face: input, optional, surface face element list, dimension (be,3)
%      elem: input, tetrahedral element list, dimension (ne,4)
%      fname: output file name; if file name has a suffix .bmsh or .bmesh, 
%           the mesh data will be saved in the binary jmesh format; otherwise,
%           the file will be saved as a text-based jmesh (which is a plain 
%           JSON file)
%      opt: additional parameters in the form of 'parameter',value pairs
%           valid parameters include:
%           'Dimension': 0 - a user defined mesh, 2- a 2D mesh, 3- a 3D mesh
%           'Author': a string to set the author of the mesh
%           'MeshTitle': a string to set the title of the mesh
%           'MeshTag': a value as the tag of the mesh data
%           'Comment': a string as the additional note for the mesh data
%
%           please type 'help savejson' and 'help saveubjson' to see additional 
%           supported options    
%
% examples:
%
%    [no,fc,el]=meshabox([0 0 0],[60,30,40],3,10);
%    savejmesh(no,fc,[],'box_surf.jmsh','dimension',3);
%    savejmesh(no,fc,el,'box_zlib.jmsh','compression','zlib');
%    savejmesh(no,fc,el,'box.bmsh','dimension',3);
%    savejmesh(no,fc,el,'box_zlib.bmsh','dimension',3,'compression','zlib');
%    mesh=loadubjson('box.bmsh')
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if(nargin==2)
   fname=face;
   face=[];
   elem=[];
end

if(nargin==3)
   fname=elem;
   elem=[];
end

if(length(varargin)==1 && ischar(varargin{1}))
   opt=struct('FileName',varargin{1});
else
   opt=varargin2struct(varargin{:});
end

meshdim=jsonopt('Dimension',0,opt);

mesh.x0x5F_DataInfo_=struct();

metadata.JMeshVersion=0.4;
metadata.CreationTime=datestr(now);
metadata.Comment=['Created by iso2mesh ' iso2meshver '(http://iso2mesh.sf.net)'];

if(meshdim==0) % a user-defined mesh
    mesh.MeshNode=node;
    if(~isempty(face))
        mesh.MeshSurf=face;
    end
    if(~isempty(elem))
        mesh.MeshElem=elem;
    end
elseif(meshdim==3) % a 3D mesh
    nd=size(node);
    if(nd(2)<3) error('expecting 3 or more columns in node'); end
    mesh.MeshVertex3=node(:,1:3);
    if(nd(2)>3)
        mesh.MeshVertex3=struct('Data',mesh.MeshVertex3,'Properties',struct('Value',node(:,4:end)));
    end
    if(~isempty(face))
        nd=size(face);
        if(nd(2)<3) error('expecting 3 or more columns in face'); end
        mesh.MeshTri3=face(:,1:3);
        if(nd(2)>3)
            mesh.MeshTri3=struct('Data',mesh.MeshTri3,'Properties',struct('Value',face(:,4:end)));
        end
    end
    if(~isempty(elem))
        nd=size(elem);
        if(nd(2)<4) error('expecting 4 or more columns in elem'); end
        mesh.MeshTet4=elem(:,1:4);
        if(nd(2)>4)
            mesh.MeshTet4=struct('Data',mesh.MeshTet4,'Properties',struct('Value',elem(:,5:end))); 
        end
    end
elseif(meshdim==2) % a 2D mesh
    nd=size(node);
    if(nd(2)<2) error('expecting 2 or more columns in node'); end
    mesh.MeshVertex2=node(:,1:2);
    if(nd(2)>2)
        mesh.MeshVertex2=struct('Data',mesh.MeshVertex2,'Properties',struct('Value',node(:,3:end)));
    end
    if(~isempty(face))
        nd=size(face);
        if(nd(2)<3) error('expecting 3 or more columns in face'); end
        mesh.MeshTri3=face(:,1:3);
        if(nd(2)>3)
            mesh.MeshTri3=struct('Data',mesh.MeshTri3,'Properties',struct('Value',face(:,4:end)));
        end
    end
    if(~isempty(elem))
        warning('elem is redundant in a 2D mesh, skip');
    end
else
    error('the specified Dimension is not supported, please remove to save data to a general format');
end

author=jsonopt('Author','',opt);
if(~isempty(author))
    metadata.Author=author;
end

title=jsonopt('MeshTitle','',opt);
if(~isempty(title))
    metadata.MeshTitle=title;
end

tag=jsonopt('MeshTag',[],opt);
if(~isempty(tag))
    metadata.MeshTag=tag;
end

comm=jsonopt('Comment','',opt);
if(~isempty(comm))
    metadata.Comment=comm;
end

mesh.x0x5F_DataInfo_=metadata;

if(~isempty(regexp(fname,'\.bmesh$', 'once')) || ~isempty(regexp(fname,'\.bmsh$', 'once')))
   saveubjson('',mesh,'FileName',fname,varargin{:});
else
   savejson('',mesh,'FileName',fname,varargin{:});
end
