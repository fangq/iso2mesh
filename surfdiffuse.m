function valnew=surfdiffuse(node,tri,val,ddt,iter,type1,opt)
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

if(iscell(tri))
	conn=tri;
else
	conn=meshconn(tri,size(node,1));
end
valnew=val;
nn=size(node,1);

nontype1=1:nn;
nontype1(type1)=[];
ninner=length(nontype1);

if(strcmp(opt,'grad'))
    for i=1:iter
       for j=1:ninner
           jj=nontype1(j);
           neighbors=conn{jj};
           dist=node(neighbors,:);
           dist(:,1)=dist(:,1)-node(jj,1);
           dist(:,2)=dist(:,2)-node(jj,2);
           dist(:,3)=dist(:,3)-node(jj,3);
           c0=sqrt(sum((dist.*dist)'));
           neighbors(find(c0==0))=[];
           valnew(jj)=val(jj)+ddt*sum((val(neighbors)'-val(jj))./c0);
       end
       val=valnew;
    end
elseif(strcmp(opt,'simple'))
    for i=1:iter
       for j=1:ninner
           jj=nontype1(j);
           if(~isempty(conn{jj}))
               valnew(jj)=(1-ddt)*val(jj)+ddt*mean((val(conn{jj})'));
           end
       end
       val=valnew;
    end
end
