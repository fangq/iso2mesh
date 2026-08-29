function varargout = test_iso2mesh(testname, fhandle, input, expected, varargin)
%
% test_iso2mesh(testname, fhandle, input, expected)
%   or
% test_iso2mesh('reset')
% [total, failed, faillist] = test_iso2mesh('summary')
%
% run a single unit test and record whether it passed
%
% authors:Qianqian Fang (q.fang <at> neu.edu)
%
% input:
%      testname: a string describing the tested feature; the reserved names
%           'reset' and 'summary' are used to control the pass/fail tally
%      fhandle: a function handle used to serialize the output, i.e. @savejson
%      input: the value produced by the tested function
%      expected: the expected serialized output, as a string
%
% output:
%      when called as test_iso2mesh('summary'):
%      total: the number of tests run since the last 'reset'
%      failed: how many of those failed
%      faillist: a cell array with the names of the failed tests
%
% license:
%     GPL version 3, see LICENSE_{BSD,GPLv3}.txt files for details
%
% -- this function is part of Iso2Mesh toolbox (http://iso2mesh.sf.net/)
%

persistent total failed faillist

if (isempty(total))
    total = 0;
    failed = 0;
    faillist = {};
end

if (nargin == 1 && ischar(testname))
    if (strcmp(testname, 'reset'))
        total = 0;
        failed = 0;
        faillist = {};
        return
    elseif (strcmp(testname, 'summary'))
        varargout = {total, failed, faillist};
        return
    end
end

res = fhandle('', input, 'compact', 1, varargin{:});
total = total + 1;

if (~isequal(strtrim(res), expected))
    failed = failed + 1;
    faillist{end + 1} = testname;
    warning('Test %s: failed: expected ''%s'', obtained ''%s''', testname, expected, res);
else
    fprintf(1, 'Testing %s: ok\n\toutput:''%s''\n', testname, strtrim(res));
end
