function vol=smoothbinvol(vol,layer)
%
% vol=smoothbinvol(vol,layer)
%
% convolve a 3x3 gaussian kernel to a binary image multiple times
% 
% author: Qianqian Fang <fangq at nmr.mgh.harvard.edu>
%
% input:
%     vol: a 3D volumetric image to be smoothed
%     layer: number of iterations for the smoothing
%
% output:
%     vol: the volumetric image after smoothing
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

dim=size(vol);
dxy=dim(1)*dim(2);
fulllen=prod(dim);

weight=1./6.;
step=4000;

% in case vol is a logical
vol=double(vol);

for i=1:layer
    % find all non-zero values
	idx=find(vol);
    % get the neighbors of all the non-zero values
    % this may cause wrapping -- TODO
	nextidx=[idx+1; idx-1;idx+dim(1);idx-dim(1);idx+dxy;idx-dxy]';
    val=repmat(vol(idx),1,6);
    % find all 1-valued voxels that are located within the domain
	goodidx=find(nextidx>0 & nextidx<fulllen);
    % for all neighboring voxels, add a fraction from the non-0 voxels
    % problematic when running in parallel (racing)
    len=length(goodidx);
    
    % control granualarity with step
    for j=1:step:len-step
        vol(nextidx(goodidx(j:j+step-1)))=vol(nextidx(goodidx(j:j+step-1)))+weight*val(goodidx(j:j+step-1));
    end
    vol(nextidx(goodidx(j+step:end)))=vol(nextidx(goodidx(j+step:end)))+weight*val(goodidx(j+step:end));
    % the above line may change the values of the non-zero voxels, recover
    % them
    vol(idx)=val(:,1);
end
