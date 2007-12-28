function savesurfpoly(v,f,p0,p1,fname)
% meshconn: create node neighbor list from a mesh
% author: fangq (fangq<at> nmr.mgh.harvard.edu)
% date: 2007/11/21
%
% parameters:
%      v: input, surface node list, dimension (nn,3)
%      f: input, surface face element list, dimension (be,3)
%      p0: input, coordinates of one corner of the bounding box, p0=[x0 y0 z0]
%      p1: input, coordinates of the other corner of the bounding box, p1=[x1 y1 z1]
%      fname: output file name

edges=surfedge(v,f);
bbxnum=0;
node=v;
if(length(edges))
    loops=extractloops(edges);
    if(length(loops)<3)
        error('degenerated loops detected');
    end
    seg=[0,find(isnan(loops))];
    segnum=length(seg)-1;

    bbxnum=6;
    loopcount=zeros(bbxnum,1);
    loopid=zeros(segnum,1);
    for i=1:segnum     % walk through the edge loops
        subloop=loops(seg(i)+1:seg(i+1)-1);
        boxfacet=find(sum(abs(diff(v(subloop,:))))<1e-2); % find a flat loop
        if(length(boxfacet))   % if the loop is flat along x/y/z dir
            bf=boxfacet(1);    % no degeneracy allowed
            if(sum(abs(v(subloop(1),bf)-p0(bf)))<1e-2)
                loopcount(bf)=loopcount(bf)+1;
                v(subloop,bf)=p0(bf);
                loopid(i)=bf;
            elseif(sum(abs(v(subloop(1),bf)-p1(bf)))<1e-2)
                loopcount(bf+3)=loopcount(bf+3)+1;
                v(subloop,bf)=p1(bf);
                loopid(i)=bf+3;
            end
        end
    end
    nn=size(v,1);

    boxnode=[p0;p1(1),p0(2:3);p1(1:2),p0(3);p0(1),p1(2),p0(3);
              p0(1:2),p1(3);p1(1),p0(2),p1(3);p1;p0(1),p1(2:3)];
    boxelem=[
        4 nn nn+3 nn+7 nn+4 0;   % x=xmin
        4 nn nn+1 nn+5 nn+4 0;   % y=ymin
        4 nn nn+1 nn+2 nn+3 0;   % z=zmin
        4 nn+1 nn+2 nn+6 nn+5 0; % x=xmax
        4 nn+2 nn+3 nn+7 nn+6 0; % y=ymax
        4 nn+4 nn+5 nn+6 nn+7 0];% z=zmax

    node=[v;boxnode];
end
node=[(0:size(node,1)-1)',node];

fp=fopen(fname,'wt');
fprintf(fp,'#node list\n%d 3 0 0\n',length(node));
fprintf(fp,'%d %f %f %f\n',node');

fprintf(fp,'#facet list\n%d 1\n',length(f)+bbxnum);
elem=[3*ones(length(f),1),f-1,ones(length(f),1)];
fprintf(fp,'1 0\n%d %d %d %d %d\n',elem');

if(length(edges))
    for i=1:bbxnum
        fprintf(fp,'%d %d %d\n',1+loopcount(i),loopcount(i),loopcount(i));
        fprintf(fp,'%d %d %d %d %d %d 1\n',boxelem(i,:));
        if(loopcount(i)&&length(find(loopid==i)))
            endid=find(loopid==i);
            for k=1:length(endid)
                j=endid(k);
                subloop=loops(seg(j)+1:seg(j+1)-1);
                fprintf(fp,'%d ',length(subloop));
                fprintf(fp,'%d ',subloop-1);
                fprintf(fp,'\n');
            end
            for k=1:length(endid)
                j=endid(k);
                subloop=loops(seg(j)+1:seg(j+1)-1);
                fprintf(fp,'%d %f %f %f\n',k,mean(v(subloop,:)));
            end
        end
    end
end

fprintf(fp,'#hole list\n0\n');
fclose(fp);
