function elem=removedupelem(elem)
% remove doubly duplicated elements

[el,count1,count2]=unique(sort(elem')','rows');
bins=hist(count2,1:size(elem,1));
cc=bins(count2);
elem(find(cc>0&mod(cc,2)==0),:)=[];