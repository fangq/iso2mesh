function newvol = volopen(varargin)
%
% vol = volopen(vol, layer, mask)
%
% open a binary volume by applying layer-counter of shrink operation
% followed by layer-count of growth operation
%
% author: Qianqian Fang, <q.fang at neu.edu>
%
% input:
%     vol: a volumetric binary image
%     layer: number of iterations for the thickenining
%     mask: (optional) a 3D neighborhood mask
%
% output:
%     vol: the volume image after opening
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if (isempty(varargin))
    error('must provide a volume');
end

newvol = volshrink(varargin{:});
newvol = volgrow(newvol, varargin{2:end});
