function facenb=faceneighbors(t,opt)

faces=[t(:,[1,2,3]);
       t(:,[1,2,4]);
       t(:,[1,3,4]);
       t(:,[2,3,4])];
faces=sort(faces,2);
[foo,ix,jx]=unique(faces,'rows');
if(isoctavemesh)
        u=unique(jx);
        qx=u(hist(jx,u)==2);
else
        vec=histc(jx,1:max(jx));
        qx=find(vec==2);
end
%vec=histc(jx,1:max(jx));
%qx=find(vec==2);  % duplicate only twice

nn=max(t(:));
ne=size(t,1);
facenb=zeros(size(t));

% now I need to find all repeatitive elements
% that share a face, to do this, unique('first')
% will give me the 1st element, and 'last' will
% give me the second. There will be no more than 2

% doing this is 60 times faster than doing find(jx==qx(i))
% inside the loop

[ujx,ii]=unique(jx,'first');
[ujx,ii2]=unique(jx,'last');

% iddup is the list of all pairs that share a common face

iddup=[ii(qx) ii2(qx)];
faceid=ceil(iddup/ne);
eid=mod(iddup,ne);
eid(eid==0)=ne;

% now rearrange this list into an element format

for i=1:length(qx)
	facenb(eid(i,1),faceid(i,1))=eid(i,2);
	facenb(eid(i,2),faceid(i,2))=eid(i,1);
end

% facenb may contain 0s, that just means the corresponding
% face is a boundary face and has no neighbor.

% if the second option is 'surface', I am going to find 
% and return surface patches only

if(nargin==2)
  if(strcmp(opt,'surface'))
	facenb=faces(find(facenb==0),:);
  end
end
