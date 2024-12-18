function vol = thinbinvol(varargin)
%
% vol=thinbinvol(vol,layer,mask)
%
% thinning a binary volume by a given pixel width
% this is similar to bwmorph(vol,'thin',n) except
% this does it in 3d and only run thinning for
% non-zero elements (and hopefully faster)
%
% author: Qianqian Fang, <q.fang at neu.edu>
%
% input:
%     vol: a volumetric binary image
%     layer: number of iterations for the thickenining
%     nobd: (optional) if set to 1, boundaries will not
%            erode. if not given, nobd=0.
%
% output:
%     vol: the volume image after the thinning operations
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

vol = volshrink(varargin{:});
