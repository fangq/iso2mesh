function centroid=meshcentroid(v,f)

ec=reshape(v(f(:,1:size(f,2))',:)', [size(v,2) size(f,2) size(f,1)]);
centroid=squeeze(mean(ec,2))';

