function data = readjson(fname)
%
% data=readjson(fname)
%
% parse a JSON (JavaScript Object Notation) file or string
%
% authors:Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
%            date: 2011/09/09
%         Nedialko Krouchev: http://www.mathworks.com/matlabcentral/fileexchange/25713
%            date: 2009/11/02
%         François Glineur: http://www.mathworks.com/matlabcentral/fileexchange/23393
%            date: 2009/03/22
%         Joel Feenstra: http://www.mathworks.com/matlabcentral/fileexchange/20565
%            date: 2008/07/03
%
% input:
%      fname: input file name, if fname contains "{", fname
%      will be interpreted as a JSON string
%
% output:
%      dat: a cell array, where {...} blocks are converted into cell arrays,
%           and [...] are converted to arrays
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

global pos inStr len  esc index_esc len_esc

if(regexp(fname,'[\{\}]'))
   string=fname;
elseif(exist(fname,'file'))
   fid = fopen(fname,'rt');
   string = fscanf(fid,'%c');
   fclose(fid);
else
   error('input file does not exist');
end

pos = 1; len = length(string); inStr = string;

% String delimiters and escape chars identified to improve speed:
esc = find(inStr=='"' | inStr=='\' ); % comparable to: regexp(inStr, '["\\]');
index_esc = 1; len_esc = length(esc);

if pos <= len
    switch(next_char)
        case '{'
            data = parse_object;
        case '['
            data = parse_array;
        otherwise
            error_pos('Outer level structure must be an object or an array');
    end
end % if

function object = parse_object
    parse_char('{');
    object = [];
    if next_char ~= '}'
        while 1
            str = parseStr;
            if isempty(str)
                error_pos('Name of value at position %d cannot be empty');
            end
            parse_char(':');
            val = parse_value;
            eval( sprintf( 'object.%s  = val;', valid_field(str) ) );
            if next_char == '}'
                break;
            end
            parse_char(',');
        end
    end
    parse_char('}');
%----------------------------------------------------------------

function object = parse_array
    parse_char('[');
    object = cell(0, 1);
    if next_char ~= ']'
        while 1
            val = parse_value;
            object{end+1} = val;
            if next_char == ']'
                break;
            end
            parse_char(',');
        end
    end
    parse_char(']');
%----------------------------------------------------------------

function parse_char(c)
    global pos inStr len
    skip_whitespace;
    if pos > len | inStr(pos) ~= c
        error_pos(sprintf('Expected %c at position %%d', c));
    else
        pos = pos + 1;
        skip_whitespace;
    end
%----------------------------------------------------------------

function c = next_char
    global pos inStr len
    skip_whitespace;
    if pos > len
        c = [];
    else
        c = inStr(pos);
    end
%----------------------------------------------------------------

function skip_whitespace
    global pos inStr len
    while pos <= len && isspace(inStr(pos))
        pos = pos + 1;
    end

%----------------------------------------------------------------
function str = parseStr
    global pos inStr len  esc index_esc len_esc
 % len, ns = length(inStr), keyboard
    if inStr(pos) ~= '"'
        error_pos('String starting with " expected at position %d');
    else
        pos = pos + 1;
    end
    str = '';
    while pos <= len
        while index_esc <= len_esc & esc(index_esc) < pos
            index_esc = index_esc + 1;
        end
        if index_esc > len_esc
            str = [str inStr(pos:len)];
            pos = len + 1;
            break;
        else
            str = [str inStr(pos:esc(index_esc)-1)];
            pos = esc(index_esc);
        end
        nstr = length(str); switch inStr(pos)
            case '"'
                pos = pos + 1;
                return;
            case '\'
                if pos+1 > len
                    error_pos('End of file reached right after escape character');
                end
                pos = pos + 1;
                switch inStr(pos)
                    case {'"' '\' '/'}
                        str(nstr+1) = inStr(pos);
                        pos = pos + 1;
                    case {'b' 'f' 'n' 'r' 't'}
                        str(nstr+1) = sprintf(['\' inStr(pos)]);
                        pos = pos + 1;
                    case 'u'
                        if pos+4 > len
                            error_pos('End of file reached in escaped unicode character');
                        end
                        str(nstr+(1:6)) = inStr(pos-1:pos+4);
                        pos = pos + 5;
                end
            otherwise % should never happen
                str(nstr+1) = inStr(pos), keyboard
                pos = pos + 1;
        end
    end
    error_pos('End of file while expecting end of inStr');
%----------------------------------------------------------------

function num = parse_number
    global pos inStr len
    currstr=inStr(pos:end);
    numstr=0;
    if(exist('OCTAVE_VERSION')~=0)
        numstr=regexp(currstr,'^\s*-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+\-]?\d+)?','end');
        [num, one] = sscanf(currstr, '%f', 1);
        delta=numstr+1;
    else
        [num, one, err, delta] = sscanf(currstr, '%f', 1);
        if ~isempty(err)
            error_pos('Error reading number at position %d');
        end
    end
    pos = pos + delta-1;
%----------------------------------------------------------------

function val = parse_value
    global pos inStr len
    true = 1; false = 0;

    switch(inStr(pos))
        case '"'
            val = parseStr;
            return;
        case '['
            val = parse_array;
            return;
        case '{'
            val = parse_object;
            return;
        case {'-','0','1','2','3','4','5','6','7','8','9'}
            val = parse_number;
            return;
        case 't'
            if pos+3 <= len & strcmp(lower(inStr(pos:pos+3)), 'true')
                val = true;
                pos = pos + 4;
                return;
            end
        case 'f'
            if pos+4 <= len & strcmp(lower(inStr(pos:pos+4)), 'false')
                val = false;
                pos = pos + 5;
                return;
            end
        case 'n'
            if pos+3 <= len & strcmp(lower(inStr(pos:pos+3)), 'null')
                val = [];
                pos = pos + 4;
                return;
            end
    end
    error_pos('Value expected at position %d');
%----------------------------------------------------------------

function error_pos(msg)
    global pos inStr len
    poShow = max(min([pos-15 pos-1 pos pos+20],len),1);
    if poShow(3) == poShow(2)
        poShow(3:4) = poShow(2)+[0 -1];  % display nothing after
    end
    msg = [sprintf(msg, pos) ': ' ...
    inStr(poShow(1):poShow(2)) '<error>' inStr(poShow(3):poShow(4)) ];
    error( ['JSONparser:invalidFormat: ' msg] );
%----------------------------------------------------------------

function str = valid_field(str)
% From MATLAB doc: field names must begin with a letter, which may be
% followed by any combination of letters, digits, and underscores.
% Invalid characters will be converted to underscores, and the prefix
% "s_" will be added if first character is not a letter.
    if ~isletter(str(1))
        str = ['s_' str];
    end
    str(~isletter(str) & ~('0' <= str & str <= '9')) = '_';
%----------------------------------------------------------------
