function varargout = img2mesh(varargin)
% 
%  Format: 
%      newworkspace = img2mesh or imgmesh(workspace)
%
%      A GUI for Iso2Mesh for streamlined mesh data processing
%  
%  Author: Qianqian Fang <q.fang at neu.edu>
%  
%  Input:
%        workspace (optional): a struct containing the below fields
%           .graph: a digraph object containing the i2m workspace data
%  Output:
%        newworkspace (optional): the updated workspace, with the same
%        subfields as the input.
%
%   If a user supplys an output variable, the GUI will not return until 
%   the user closes the window; if a user does not provide any output,
%   the call will return immediately.
%
%   Please find more information at http://iso2mesh.sf.net/
%  
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @i2m_OpeningFcn, ...
                   'gui_OutputFcn',  @i2m_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before i2m is made visible.
function i2m_OpeningFcn(hObject, eventdata, handles, varargin)

cm = uicontextmenu;
miplot= uimenu(cm,'Label','Plot','CallBack',{@processdata,handles});
midel = uimenu(cm,'Label','Delete','CallBack',{@processdata,handles});
mijmesh = uimenu(cm,'Label','Export to JMesh','CallBack',{@processdata,handles});
miv2s = uimenu(cm,'Label','Volume to surface','CallBack',{@processdata,handles});
miv2m = uimenu(cm,'Label','Volume to mesh','CallBack',{@processdata,handles});
mis2m = uimenu(cm,'Label','Surface to mesh','CallBack',{@processdata,handles});
mis2v = uimenu(cm,'Label','Surface to volume','CallBack',{@processdata,handles});
micln = uimenu(cm,'Label','Clean surface','CallBack',{@processdata,handles});
mifix = uimenu(cm,'Label','Repair surface','CallBack',{@processdata,handles});
misms = uimenu(cm,'Label','Smooth surface','CallBack',{@processdata,handles});
mibool = uimenu(cm,'Label','Surface boolean','CallBack',{@processdata,handles});
mibool1 = uimenu(mibool,'Label','Or','CallBack',{@processdata,handles});
mibool2 = uimenu(mibool,'Label','And','CallBack',{@processdata,handles});
mibool3 = uimenu(mibool,'Label','Diff','CallBack',{@processdata,handles});
mibool4 = uimenu(mibool,'Label','First','CallBack',{@processdata,handles});
mibool5 = uimenu(mibool,'Label','Second','CallBack',{@processdata,handles});

miv2s.Separator='on';

set(handles.fgI2M,'userdata',struct('graph',digraph,'menu',cm));
axis(handles.axFlow,'off');
axis(handles.axPreview,'off');

% Choose default command line output for i2m
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes i2m wait for user response (see UIRESUME)
% uiwait(handles.fgI2M);

function processdata(source,callbackdata,handles)
obj=get(handles.fgI2M,'currentobject');
if(strcmp(class(obj),'matlab.graphics.chart.primitive.GraphPlot')==0)
    return
end
root=get(handles.fgI2M,'userdata');
pos=get(handles.axFlow,'currentpoint');
[nodedata,nodetype,nodeid]=getnodeat(root,obj,pos);

prefix='x';
switch source.Label
    case 'Volume to surface'
        if(isstruct(nodetype) && isfield(nodetype,'hasvol') && nodetype.hasvol)
            [newdata,newtype]=v2sgui(nodedata);
            prefix='Vol2Surf';
        else
            warndlg('no volume data found');
        end
    case 'Volume to mesh'
        if(nodetype.hasvol)
            [newdata,newtype]=v2mgui(nodedata);
            prefix='Vol2Mesh';
        end
    case 'Surface to mesh'
        if(nodetype.hasnode && nodetype.hasface)
            [newdata,newtype]=s2mgui(nodedata);
            prefix='Surf2Mesh';
        end
    case 'Surface to volume'
        if(nodetype.hasnode && nodetype.hasface)
            ndiv = inputdlg('Division number along the shortest dimension:',...
                'surf2vol - rasterizing a surface mesh',1,{'50'});
            if(isempty(ndiv))
                return;
            end
            newdata.vol=s2v(nodedata.node,nodedata.face,str2num(ndiv{1}));
            newtype.hasvol=1;
            prefix='Surf2Vol';
        end
    case 'Clean surface'
        if(nodetype.hasnode && nodetype.hasface)
            [newdata.node,newdata.face]=meshcheckrepair(nodedata.node,nodedata.face,'deep');
            newtype=nodetype;
            prefix='CleanSurf';
        end
    case 'Repair surface'
        if(nodetype.hasnode && nodetype.hasface)
            [newdata.node,newdata.face]=meshcheckrepair(nodedata.node,nodedata.face,'meshfix');
            newtype=nodetype;
            prefix='RepairSurf';
        end
    case 'Smooth surface'
        if(nodetype.hasnode && nodetype.hasface)
            res = inputdlg({'Method (laplacian,laplacianhc,lowpass):','Iteration (integer):','Alpha (scalar):'},...
                'sms - smoothing a surface mesh',[1,1,1],{'lowpass','20','0.5'});
            if(isempty(res))
                return;
            end
            newdata=nodedata;
            newtype=nodetype;
            newdata.node=sms(nodedata.node,nodedata.face,str2num(res{2}),str2num(res{3}),res{1});
            prefix='SmoothSurf';
        end
    case 'Plot'
        if(isstruct(nodetype) && isfield(nodetype,'hasnode'))
            if(isfield(nodetype,'haselem') && nodetype.haselem)
                figure;plotmesh(nodedata.node,[],nodedata.elem);
            else
                figure;plotmesh(nodedata.node,nodedata.face);
            end
        else
            mcxplotvol(nodedata.vol);
        end
    case {'Or','And','Diff','All','First','Second'}
        if(isstruct(nodetype) && isfield(nodetype,'hasnode'))
            if(nodetype.haselem && nodetype.hasnode)
                pt=ginput(1);
                [nodedata2,nodetype2,nodeid2]=getnodeat(root,obj,pt);
                if(~nodetype2.hasnode || ~nodetype2.haselem)
                    throw('Second operand does not contain a surface');
                end
                op=source.Label;
                if(strcmp(op,'Intersect'))
                    op='inter';
                end
                [newdata.node,newdata.face]=surfboolean(nodedata.node,nodedata.face,lower(op),nodedata2.node,nodedata2.face(:,[1 3 2]));
                newtype.hasnode=1;
                newtype.hasface=1;
                prefix=source.Label;
            else
                warndlg('Selected node does not contain a surface mesh');
            end
        end
    case 'Delete'
        root.graph=rmnode(root.graph,root.graph.Nodes.Name{nodeid});
        updategraph(root,handles);
    case 'Export to JMesh'
        if(~nodetype.haselem && ~nodetype.hasnode)
            warndlg('selected data does not have a mesh');
            return;
        end
        filter = {'*.jmesh';'*.*'};
        [file, path] = uiputfile(filter,'Export mesh');
        if ~isequal(file,0) && ~isequal(path,0)
            if(nodetype.haselem)
                savejmesh(nodedata.node,nodedata.face,nodedata.elem,fullfile(path,file));
            else
                savejmesh(nodedata.node,nodedata.elem,fullfile(path,file));
            end
        end
end
if(exist('newdata','var') && exist('newtype','var'))
    newdata.preview=getpreview(handles,newdata,newtype,[100,100]);
    [newkey,root.graph]=addnodewithdata(handles,newdata,newtype,prefix);
    root.graph=addedge(root.graph,{root.graph.Nodes.Name{nodeid}},{newkey});
    if(strcmp(source.Parent.Type, 'uimenu') && strcmp(source.Parent.Label,'Surface boolean'))
        root.graph=addedge(root.graph,{root.graph.Nodes.Name{nodeid2}},{newkey});
    end
    updategraph(root,handles);
    imagesc(newdata.preview,'parent',handles.axFlow);
end

function [nodedata,nodetype,nodeid]=getnodeat(root,obj,pos)
nodedist=[obj.XData(:)-pos(1,1) obj.YData(:)-pos(1,2)];
nodedist=sum(nodedist.*nodedist,2);
[mindist, nodeid]=min(nodedist);
nodedata=root.graph.Nodes.Data{nodeid};
nodetype=root.graph.Nodes.Type{nodeid};

%----------------------------------------------------------------
function [newdata, newtype]=v2sgui(data)
prompt = {'Threshold (scalar or array):',...
    'Surface element radius bound (scalar):',...
    'Surface element distance bound (scalar)','Method: (cgalsurf,cgalmesh,simplify)'};
title = 'vol2surf - extracting surface mesh from volume';
dims = [1 1 1 1];
definput = {'0.5','5','1','cgalsurf'};
res = inputdlg(prompt,title,dims,definput);
newdata=[]; 
newtype=[];
if(isempty(res))
    return;
end

opt=struct('radbound',str2num(res{2}),'distbound',str2num(res{3}));
[newdata.node,newdata.face]=vol2surf(data.vol,eval(res{1}),...
   opt, res{4});
newtype.hasnode=1;
newtype.hasface=1;
%----------------------------------------------------------------
function [newdata, newtype]=v2mgui(data)
prompt = {'Threshold (scalar or []):',...
    'Surface element radius bound (scalar):',...
    'Surface element distance bound (scalar)',...
    'Max element volume (scalar):',...
    'Method (cgalsurf,cgalmesh,simplify):'};
title = 'vol2mesh - extracting tet mesh from volume';
dims = [1 1 1 1 1];
definput = {'[]','5','1','30','cgalmesh'};
res = inputdlg(prompt,title,dims,definput);
newdata=[]; 
newtype=[];
if(isempty(res))
    return;
end

opt=struct('radbound',str2num(res{2}),'distbound',str2num(res{3}));
[newdata.node,newdata.elem,newdata.face]=v2m(data.vol,eval(res{1}),...
   opt, res{4});
newtype.hasnode=1;
newtype.hasface=1;
newtype.haselem=1;

%----------------------------------------------------------------
function img=getpreview(handles,nodedata,nodetype,imsize)
set(handles.axPreview, 'Units','pixels','position',[1, 1, imsize(1), imsize(2)]);
if(isfield(nodetype,'haselem') && nodetype.haselem)
    plotmesh(nodedata.node,[],nodedata.elem,'linestyle','none','parent',handles.axPreview);
elseif(isfield(nodetype,'hasface') && nodetype.hasface)
    plotmesh(nodedata.node,nodedata.face,'linestyle','none','parent',handles.axPreview);
elseif(isfield(nodetype,'hasvol') && nodetype.hasvol)
    imagesc(nodedata.vol(:,:,ceil(size(nodedata.vol,3)/2)),'parent',handles.axPreview);
end
axis(handles.axPreview,'equal');
axis(handles.axPreview,'off');
img=getframe(gca);
if(any(size(img.cdata)<[imsize([2 1]) 3]))
    error('the requested rasterization grid is larger than the screen resolution');
end
img=img.cdata(1:imsize(2),1:imsize(1),:);
cla(handles.axPreview);

%----------------------------------------------------------------
function [newdata, newtype]=s2mgui(data)
prompt = {'Simplification ratio (%edges to keep, 0-1):',...
    'Max element volume (scalar):',...
    'Method (tetgen,tetgen1.5,cgalpoly):',...
    'Region seeds (N x 3 array):',...
    'Hole seeds (N x 3 array):'};
title = 'surf2mesh - creating tet mesh from surfaces';
dims = [1 1 1 1 1];
definput = {'1','30','tetgen','[]','[]'};
res = inputdlg(prompt,title,dims,definput);
newdata=[]; 
newtype=[];
if(isempty(res))
    return;
end

[newdata.node,newdata.elem,newdata.face]=...
   s2m(data.node,data.face,str2num(res{1}),...
     str2num(res{2}),res{3},eval(res{4}),eval(res{5}));
newtype.hasnode=1;
newtype.hasface=1;
newtype.haselem=1;

% --- Outputs from this function are returned to the command line.
function varargout = i2m_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function mFile_Callback(hObject, eventdata, handles)
% hObject    handle to mFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function miCreate_Callback(hObject, eventdata, handles)
% hObject    handle to miCreate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function miHelp_Callback(hObject, eventdata, handles)
% hObject    handle to miHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function miWeb_Callback(hObject, eventdata, handles)
% hObject    handle to miWeb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function miDoc_Callback(hObject, eventdata, handles)
% hObject    handle to miDoc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function miAbout_Callback(hObject, eventdata, handles)
% hObject    handle to miAbout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function miSphere_Callback(hObject, eventdata, handles)
prompt = {'Center:','Radius (scalar):',...
    'Surface element radius bound (scalar)',...
    'Max element volume (scalar, 0 - only create surface):'};
title = 'Create Mesh';
dims = [1 1 1 1];
definput = {'[0 0 0]','50','6','20'};
res = inputdlg(prompt,title,dims,definput);
if(isempty(res))
    return;
end
opt=str2num(res{3});
if(str2num(res{4})==0)
   [newdata.node,newdata.face]=meshasphere(eval(res{1}),...
     str2num(res{2}),opt);
else
   [newdata.node,newdata.face,newdata.elem]=meshasphere(eval(res{1}),...
     str2num(res{2}),opt, str2num(res{4}));
   newtype.haselem=1;
end
newtype.hasnode=1;
newtype.hasface=1;

if(exist('newdata','var') && exist('newtype','var'))
    newkey=addnodewithdata(handles,newdata,newtype,'Sphere');
end

% --------------------------------------------------------------------
function miBox_Callback(hObject, eventdata, handles)
prompt = {'Diagonal end point 1 (1x3 vector):','Diagonal end point 2 (1x3 vector):',...
    'Surface element radius bound (scalar)',...
    'Max element volume (scalar, 0 - only create surface):'};
title = 'Create Mesh';
dims = [1 1 1 1];
definput = {'[0 0 0]','[100 60 30]','6','30'};
res = inputdlg(prompt,title,dims,definput);
if(isempty(res))
    return;
end
opt=str2num(res{3});
if(str2num(res{4})==0)
   [newdata.node,newdata.face]=meshabox(eval(res{1}),eval(res{2}),opt);
else
   [newdata.node,newdata.face,newdata.elem]=meshabox(eval(res{1}),...
     eval(res{2}),opt, str2num(res{4}));
   newtype.haselem=1;
end
newtype.hasnode=1;
newtype.hasface=1;

if(exist('newdata','var') && exist('newtype','var'))
    newkey=addnodewithdata(handles,newdata,newtype,'Box');
end

% --------------------------------------------------------------------
function miCylinder_Callback(hObject, eventdata, handles)
prompt = {'Axis end-point 1','Axis end-point 2','Radius (scalar):',...
    'Surface element radius bound (scalar)',...
    'Max element volume (scalar, 0 - only create surface):',...
    'Circle division:'};
title = 'Create Mesh';
dims = [1 1 1 1 1 1];
definput = {'[0 0 0]','[0 0 50]','10','3','20','20'};
res = inputdlg(prompt,title,dims,definput);
if(isempty(res))
    return;
end
opt=str2num(res{4});
maxvol=str2num(res{5});

if(maxvol==0)
   [newdata.node,newdata.face]=meshacylinder(eval(res{1}),eval(res{2}),...
     str2num(res{3}),opt);
else
   [newdata.node,newdata.face,newdata.elem]=meshacylinder(eval(res{1}),eval(res{2}),...
     str2num(res{3}),opt,maxvol);
   newtype.haselem=1;
end
newtype.hasnode=1;
newtype.hasface=1;

if(exist('newdata','var') && exist('newtype','var'))
    newkey=addnodewithdata(handles,newdata,newtype,'Cyl');
end

% --------------------------------------------------------------------
function miLoadMesh_Callback(hObject, eventdata, handles)

nodedata=struct;
nodetype=struct;
filters={'*.jmesh;*.off;*.medit;*.smf;*.json','3D Mesh files (*.jmesh;*.off;*.medit;*.smf;*.json)',...
    '*.jmesh','JSON mesh (*.jmesh)',...
    '*.off','OFF file (*.off)',...
    '*.medit','Medit file (*.medit)',...
    '*.smf','Simple Model Format (*.smf)',...
    '*.json','JSON file (*.json)','*.*','All (*.*)'};
[file,path,idx] = uigetfile(filters);
if isequal(file,0)
   return;
else
   if(regexp(file,'\.[Oo][Oo][Ff]$'))
       [nodedata.node, nodedata.elem]=readoff(fullfile(path,file));
   elseif(regexp(file,'\.[Mm][Ee][Dd][Ii][Tt]$'))
       [nodedata.node, nodedata.elem]=readmedit(fullfile(path,file));
   elseif(regexp(file,'\.[Ss][Mm][Ff]$'))
       [nodedata.node, nodedata.elem]=readsmf(fullfile(path,file));
   elseif(regexp(file,'\.[Jj][Mm][Ee][Ss][Hh]$'))
       data=loadjson(fullfile(path,file));
       if(isfield(data,'MeshNode'))
           nodedata.node=data.MeshNode;
       end
       if(isfield(data,'MeshElem'))
           nodedata.elem=data.MeshElem;
       end
       if(isfield(data,'MeshSurf'))
           nodedata.face=data.MeshSurf;
       end
       if(isfield(data,'MeshNodeVal'))
           nodedata.node(:,end+1:end+size(data.MeshNodeVal,2))=data.MeshNodeVal;
       end
       if(isfield(data,'MeshTetraVal'))
           nodedata.elem(:,end+1:end+size(data.MeshTetraVal,2))=data.MeshTetraVal;
       end
   elseif(regexp(file,'\.[Jj][Ss][Oo][Nn]$'))
       nodedata=loadjson(fullfile(path,file));
   end
end
if(exist('nodedata','var'))
    nodetype=getnodetype(nodedata);
    if(nodetype.haselem)
        addnodewithdata(handles,nodedata,nodetype,'Tet');
    elseif(nodetype.hasface)
        addnodewithdata(handles,nodedata,nodetype,'Surf');
    elseif(nodetype.hasnode)
        addnodewithdata(handles,nodedata,nodetype,'Point');
    elseif(nodetype.hasvol)
        addnodewithdata(handles,nodedata,nodetype,'Vol');
    end
else
    warndlg('no valid mesh data found','Warning');
end

% --- Executes during object creation, after setting all properties.
function axFlow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axFlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axFlow


% --- Executes during object creation, after setting all properties.
function fgI2M_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fgI2M (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --------------------------------------------------------------------
function miLoadVol_Callback(hObject, eventdata, handles)

nodedata=struct;
nodetype=struct;
[file,path] = uigetfile('*.mat');
if isequal(file,0)
   return;
else
   data=load(fullfile(path,file));
   vars=fieldnames(data);
   [idx, isok]=listdlg('ListString',vars,...
       'PromptString','Select a 3D array:');
   if(~isok)
       return;
   end
   for i=1:length(idx)
       dat=data.(vars{idx(i)});
       nodedata.(vars{idx(i)})=dat;
   end
end

nodetype=getnodetype(nodedata);
addnodewithdata(handles,nodedata,nodetype,'Vol');

%--------------------------------------------------------------------
function nodetype=getnodetype(nodedata)
nodetype=struct;
if(~isstruct(nodedata))
    return;
end
names=fieldnames(nodedata);
nodetype.hasvol=0;
nodetype.hasnode=0;
nodetype.hasface=0;
nodetype.haselem=0;
for i=1:length(names)
      switch names{i}
           case 'node'
                nodetype.hasnode=1;
           case 'face'
                nodetype.hasface=1;
           case 'elem'
                nodetype.haselem=1;
           case 'vol'
                nodetype.hasvol=1;
      end
      dat=nodedata.(names{i});
      if((isnumeric(dat) || islogical(dat)) && ndims(dat)==3)
           nodetype.hasvol=1;
      end
end
% --------------------------------------------------------------------

function [key,newgraph]=addnodewithdata(handles,nodedata,nodetype,name)

root=get(handles.fgI2M,'userdata');

if(isempty(root))
    root=struct('graph',digraph,'menu',uicontextmenu);
end
if(nargin<4)
    name='x';
end

id=1;
if(~isempty(root.graph.Nodes))
  while(find(strcmp(root.graph.Nodes.Name,sprintf('%s%d',name,id))))
    id=id+1;
  end
end
key=sprintf('%s%d',name,id);

nodedata.preview=getpreview(handles,nodedata,nodetype,[100,100]);

nodeprop=table({key},{nodedata},{nodetype},'VariableNames',{'Name','Data','Type'});
root.graph=addnode(root.graph,nodeprop);
if(nargout>1)
    newgraph=root.graph;
end
updategraph(root, handles);
% hold(handles.axFlow,'on');
% imagesc(nodedata.preview,'parent',handles.axFlow);
% hold(handles.axFlow,'off');

function updategraph(root, handles)
set(handles.fgI2M,'userdata',root);
hg=plot(root.graph,'parent',handles.axFlow);
% set(hg,'Selected','on');
axis(handles.axFlow,'off');
set(hg,'UIContextMenu',root.menu);

% --------------------------------------------------------------------
function miDelete_Callback(hObject, eventdata, handles)
% hObject    handle to miDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function miPlot_Callback(hObject, eventdata, handles)
% hObject    handle to miPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function mePlot_Callback(hObject, eventdata, handles)
% hObject    handle to mePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function meEdit_Callback(hObject, eventdata, handles)
% hObject    handle to meEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function axFlow_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axFlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function miEllipsoid_Callback(hObject, eventdata, handles)
prompt = {'Center (1x3 vector):',...
    'Radii (a scalar, or 1x3 or 1x5 vector):',...
    'Max element volume (scalar, 0 - only create surface):',...
    'Circle division:'};
title = 'Create an Ellipsoid Mesh';
dims = [1 1 1 1];
definput = {'[0 0 0]','[50 30 20]','3','30'};
res = inputdlg(prompt,title,dims,definput);
if(isempty(res))
    return;
end
opt=str2num(res{4});
maxvol=str2num(res{5});

if(maxvol==0)
   [newdata.node,newdata.face]=meshanellip(eval(res{1}),eval(res{2}),opt);
else
   [newdata.node,newdata.face,newdata.elem]=meshanellip(eval(res{1}),...
     eval(res{2}),opt, maxvol);
   newtype.haselem=1;
end
newtype.hasnode=1;
newtype.hasface=1;

if(exist('newdata','var') && exist('newtype','var'))
    newkey=addnodewithdata(handles,newdata,newtype,'Cyl');
end

% --------------------------------------------------------------------
function miLattice_Callback(hObject, eventdata, handles)
prompt = {'X-lattice range (a vector):',...
    'Y-lattice range (a vector):',...
    'Z-lattice range (a vector):',...
    'Max element volume (scalar, 0 - only create surface):'};
title = 'Create Lattice Grid Mesh';
dims = [1 1 1 1];
definput = {'[1 100]','[1 50]','[1 10 30]','30'};
res = inputdlg(prompt,title,dims,definput);
if(isempty(res))
    return;
end
maxvol=str2num(res{4});
if(maxvol==0)
   [newdata.node,newdata.face]=latticegrid(eval(res{1}),eval(res{2}),eval(res{3}));
else
   [no,fc,c0]=latticegrid(eval(res{1}),eval(res{2}),eval(res{3}));
   [newdata.node,newdata.elem,newdata.face]=surf2mesh(no,fc,[],[],1,maxvol,c0);
   newtype.haselem=1;
end
newtype.hasnode=1;
newtype.hasface=1;

if(exist('newdata','var') && exist('newtype','var'))
    newkey=addnodewithdata(handles,newdata,newtype,'Lattice');
end

% --------------------------------------------------------------------
function miMeshgrid5_Callback(hObject, eventdata, handles)
% hObject    handle to miMeshgrid5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function miMeshgrid6_Callback(hObject, eventdata, handles)
% hObject    handle to miMeshgrid6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function miOpen_Callback(hObject, eventdata, handles)
filter = {'*.mat';'*.*'};
root=get(handles.fgI2M,'userdata');

[file, path] = uigetfile(filter,'Load workspace');
if isequal(file,0)
   return;
else
   data=load(fullfile(path,file));
end
if(isfield(data,'i2mworkspace'))
    root.graph=data.i2mworkspace;
    updategraph(root,handles);
else
    warndlg('no saved workspace found','Warning');
end

% --------------------------------------------------------------------
function miSaveAll_Callback(hObject, eventdata, handles)
root=get(handles.fgI2M,'userdata');
graph=root.graph;
filter = {'*.mat';'*.*'};
[file, path] = uiputfile(filter,'Save workspace');
if ~isequal(file,0) && ~isequal(path,0)
   save(fullfile(path,file),'i2mworkspace');
end


% --------------------------------------------------------------------
function miLoadVar_Callback(hObject, eventdata, handles)

nodedata=struct;
nodetype=struct;
[file,path] = uigetfile({'*.mat','MATLAB data (*.mat)'});
if isequal(file,0)
   return;
else
   data=load(fullfile(path,file));
   vars=fieldnames(data);
   [idx, isok]=listdlg('ListString',vars,...
       'PromptString','Select a 3D array:');
   if(~isok)
       return;
   end
   for i=1:length(idx)
       dat=data.(vars{idx(i)});
       if(ndims(dat)==3 && ~isfield(nodedata,'vol'))
           nodedata.vol=dat;
       else
           nodedata.(vars{idx(i)})=dat;
       end
   end
end

nodetype=getnodetype(nodedata);
if(nodetype.haselem)
    addnodewithdata(handles,nodedata,nodetype,'Tet');
elseif(nodetype.hasface)
    addnodewithdata(handles,nodedata,nodetype,'Surf');
elseif(nodetype.hasnode)
    addnodewithdata(handles,nodedata,nodetype,'Point');
elseif(nodetype.hasvol)
    addnodewithdata(handles,nodedata,nodetype,'Vol');
end
