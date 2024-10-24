function test_iso2mesh(testname, fhandle, input, expected, varargin)
res = fhandle('', input, 'compact', 1, varargin{:});
if (~isequal(strtrim(res), expected))
    warning('Test %s: failed: expected ''%s'', obtained ''%s''', testname, expected, res);
else
    fprintf(1, 'Testing %s: ok\n\toutput:''%s''\n', testname, strtrim(res));
end
