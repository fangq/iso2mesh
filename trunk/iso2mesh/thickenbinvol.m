function vol=thickenbinvol(vol,layer)
% this is similar to bwmorph(vol,'thicken',3) except this does it
% in 3d and only does thickening for non-zero elements (and hopefully faster)

dim=size(vol);
dxy=dim(1)*dim(2);
fulllen=prod(dim);

for i=1:layer
	idx=find(vol);
	idxnew=[idx+1; idx-1;idx+dim(1);idx-dim(1);idx+dxy;idx-dxy];
	idxnew=idxnew(find(idxnew>0 & idxnew<fulllen));
	vol(idxnew)=1;
end
