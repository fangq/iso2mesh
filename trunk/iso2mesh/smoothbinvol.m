function vol=smoothbinvol(vol,layer)
% this is similar (but not exactly) to applying convn(vol,1/9*ones(3)) for 
% layer times it does convolution for non-zero elements (and hopefully faster)

dim=size(vol);
dxy=dim(1)*dim(2);
fulllen=prod(dim);

weight=1./9.;
for i=1:layer
	idx=find(vol);
	nextidx=[idx+1; idx-1;idx+dim(1);idx-dim(1);idx+dxy;idx-dxy]';
    val=repmat(vol(idx),1,6);
	goodidx=find(nextidx>0 & nextidx<fulllen);
	vol(nextidx(goodidx))=vol(nextidx(goodidx))+weight*val(goodidx);
end
