function newvol = volclose(varargin)
%
% vol = volclose(vol, layer, mask)
%
% close a binary volume by applying layer-counter of growth operation
% followed by layer-count of shrinkage operation
%
% author: Qianqian Fang, <q.fang at neu.edu>
%
% input:
%     vol: a volumetric binary image
%     layer: number of iterations for the thickenining
%     mask: (optional) a 3D neighborhood mask
%
% output:
%     vol: the volume image after closing
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if (isempty(varargin))
    error('must provide a volume');
end

newvol = volgrow(varargin{:});
newvol = volshrink(newvol, varargin{2:end});
