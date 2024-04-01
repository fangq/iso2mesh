function starray=soa2aos(st)
%
%    starray=soa2aos(st)
%
%    Convert a struct-of-arrays (SoA) to an array-of-structs (AoS)
%
%    author: Qianqian Fang (q.fang <at> neu.edu)
%
%    input:
%        st: a struct with subfield of equal length of numeric elements
%
%    output:
%        starray: a struct array with each element being a simple struct
%             containing the same number of subfields as st with each
%             subfield length of 1
%
%    example:
%        a=struct('f1',[1,2,3],'f2',[-1,-2,-3])
%        starray=soa2aos(a)
%
%    this file is part of JSNIRF specification: https://github.com/NeuroJSON/jsnirf
%
%    License: GPLv3 or Apache 2.0, see https://github.com/NeuroJSON/jsnirf for details
%


if(nargin<1 || ~isstruct(st))
    error('you must give an array of struct');
end

fn=fieldnames(st);

if(length(st)>1)
    error('you must give a struct of length 1');
end

if(isempty(fn))
    starray=st;
    return;
end

elemlen=numel(st.(fn{1}));

if(~all(structfun(@(x) numel(x(:))==elemlen, st)))
    error('all subfield must have the same length');
end

starray=struct;
for i=1:elemlen
    for j=1:length(fn)
        starray(i).(fn{j})=st.(fn{j})(i);
    end
end