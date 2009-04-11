function p=smoothsurf(node,mask,conn,iter,useralpha,usermethod,userbeta)
% p=smoothsurf(node,mask,conn,iter,useralpha,usermethod,userbeta)
%
% smoothsurf: smooth a surface mesh by Laplace smoothing
%
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/11/21
%
% input:
%    node:  node coordinates of a surface mesh
%    mask: of length of node number, =0 for internal nodes, =1 for edge nodes
%    conn:  input, a cell structure of length size(node), conn{n}
%           contains a list of all neighboring node ID for node n
%    iter:  smoothing iteration number
%    useralpha: scaler, smoothing parameter, v(k+1)=alpha*v(k)+(1-alpha)*mean(neighbors)
%    usermethod: smoothing method, including 'laplacian','laplacianhc' and 'lowpass'
%    userbeta: scaler, smoothing parameter, for 'laplacianhc'
% output:
%    p: output, the smoothed node coordinates
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

p=node;
idx=find(mask==0)';
nn=length(idx);

alpha=0.5;
method='laplacian';
beta=0.5;
if(nargin>4)
    alpha=useralpha;
    if(nargin>5)
        method=usermethod;
        if(nargin>6)
            beta=userbeta;
        end
    end
end
ibeta=1-beta;
ialpha=1-alpha;
lambda=-1.02*alpha;

for i=1:nn
    if(length(conn{idx(i)})==0)
        idx(i)=0;
    end
end
idx=idx(idx>0);
nn=length(idx);

if(strcmp(method,'laplacian'))
    for j=1:iter
        for i=1:nn
            p(idx(i),:)=alpha*p(idx(i),:)+ialpha*mean(node(conn{idx(i)},:)); 
        end
        node=p;
    end
elseif(strcmp(method,'laplacianhc'))
    for j=1:iter
        q=p;
        for i=1:nn
            p(idx(i),:)=mean(node(conn{idx(i)},:));
        end
        b=p-(alpha*node+ialpha*q);
        for i=1:nn
            p(idx(i),:)=p(idx(i),:)-(beta*b(i,:)+ibeta*mean(b(conn{idx(i)},:))); 
        end
    end
elseif(strcmp(method,'lowpass'))
    for j=1:iter
        for i=1:nn
            p(idx(i),:)=alpha*p(idx(i),:)+ialpha*mean(node(conn{idx(i)},:)); 
        end
        node=p;
        for i=1:nn
            p(idx(i),:)=alpha*p(idx(i),:)-1.02*ialpha*(mean(node(conn{idx(i)},:))-p(idx(i),:)); 
        end
        node=p;
    end
end
