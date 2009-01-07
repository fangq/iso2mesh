function [node,elem]=vol2restrictedtri(vol,thres,cent,brad,ang,radbound,distbound)

exesuff=getexeext;
saveinr(vol,mwpath('pre_extract.inr'));
%writeinr(mwpath('pre_extract.inr'),vol>thres,'uint8');
deletemeshfile('post_extract.off');
system([' "' mcpath('cgalsurf') exesuff '" "' mwpath('pre_extract.inr') ...
    '" ' sprintf('%f %f %f %f %f %f %f %f ',thres,cent,brad,ang,radbound,distbound) ...
    ' "' mwpath('post_extract.off') '"']);
[node,elem]=readoff(mwpath('post_extract.off'));
