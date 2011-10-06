function json=savejson(rootname,obj,varargin)
%
% json=savejson(rootname,obj,opt)
%
% convert a MATLAB object (cell, struct or array) into a JSON (JavaScript
% Object Notation) string
%
% authors:Qianqian Fang (fangq<at> nmr.mgh.harvard.edu)
%            date: 2011/09/09
%
% input:
%      rootname: name of the root-object, if set to '', will use variable name
%      obj: a MATLAB object (array, cell, cell array, struct, struct array)
%      opt: additional options, use [] if no option
%
% output:
%      json: a string in the JSON format
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

varname=inputname(2);
if(~isempty(rootname))
   varname=rootname;
end
json=obj2json(varname,obj,1,varargin{:});
json=sprintf('{\n%s\n}\n',json);

%%----------------------------------------------
function txt=obj2json(name,item,level,varargin)

cname=class(item);
varname=inputname(2);
if(isempty(name))
   name=varname;
end

if(iscell(item))
    txt=cell2json(name,item,level,varargin{:});
elseif(isstruct(item))
    txt=struct2json(name,item,level,varargin{:});
elseif(ischar(item))
    txt=str2json(name,item,level,varargin{:});
else
    txt=mat2json(name,item,level,varargin{:});
end

%%----------------------------------------------
function txt=cell2json(name,item,level,varargin)
txt='';
if(~iscell(item))
        error('input is not a cell');
end

dim=size(item);
len=numel(item); % let's handle 1D cell first
padding1=repmat(sprintf('\t'),1,level-1);
padding0=repmat(sprintf('\t'),1,level);
if(len>1) txt=sprintf('%s"%s": [\n',padding0, name); name=''; end
for i=1:len
    txt=sprintf('%s%s%s',txt,padding1,obj2json(name,item{i},level+(len>1),varargin{:}));
    if(i<len) txt=sprintf('%s%s',txt,sprintf(',\n')); end
end
if(len>1) txt=sprintf('%s\n%s]',txt,padding0); end

%%----------------------------------------------
function txt=struct2json(name,item,level,varargin)
txt='';
if(~isstruct(item))
	error('input is not a struct');
end
len=numel(item);
padding1=repmat(sprintf('\t'),1,level);
padding0=repmat(sprintf('\t'),1,level+1);
sep=',';

if(~isempty(name)) 
    if(len>1) txt=sprintf('%s"%s": [\n',padding1,name); end
else
    if(len>1) txt=sprintf('%s[\n',padding1); end
end
for e=1:len
  names = fieldnames(item(e));
  if(~isempty(name) && len==1)
        txt=sprintf('%s%s"%s": {\n',txt,padding1, name); 
  else
        txt=sprintf('%s%s{\n',txt,padding1); 
  end
  if(~isempty(names))
    for i=1:length(names)
	    txt=sprintf('%s%s',txt,obj2json(names{i},getfield(item(e),names{i}),level+1+(len>1),varargin{:}));
        if(i<length(names)) txt=sprintf('%s%s',txt,','); end
        txt=sprintf('%s%s',txt,sprintf('\n'));
    end
  end
  txt=sprintf('%s%s}',txt,repmat(sprintf('\t'),1,level+(len>1)));
  if(e==len) sep=''; end
  if(e<len) txt=sprintf('%s%s',txt,sprintf(',\n')); end
end
if(len>1) txt=sprintf('%s\n%s]',txt,padding1); end

%%----------------------------------------------
function txt=str2json(name,item,level,varargin)
txt='';
if(~ischar(item))
        error('input is not a string');
end
len=size(item,1);
sep=',\n';

if(len>1) txt=sprintf('%s[\n',repmat('\t',1,level+1)); end
for e=1:len
    val=regexprep(item(e,:),'([^\\])"','$1\\"');
    val=regexprep(val,'^"','\\"');
    if(len==1)
        obj=['"' name '": ' '"',val,'"'];
	if(isempty(name)) obj=['"',val,'"']; end
        txt=sprintf('%s%s%s%s',txt,repmat(sprintf('\t'),1,level+(len>1)),obj);
    else
        txt=sprintf('%s%s%s%s',txt,repmat(sprintf('\t'),1,level+1+(len>1)),['"',val,'"']);
    end
    if(e==len) sep=''; end
    txt=sprintf('%s%s',txt,sep);
end
if(len>1) txt=sprintf('%s%s%s',txt,repmat(sprintf('\t'),1,level+1),']'); end

%%----------------------------------------------
function txt=mat2json(name,item,level,varargin)
if(~isnumeric(item) && ~islogical(item))
        error('input is not an array');
end

padding1=repmat(sprintf('\t'),1,level);
padding0=repmat(sprintf('\t'),1,level+1);

if(length(size(item))>2 || issparse(item))
    if(isempty(name))
    	txt=sprintf('%s{\n%s"_ArrayType": "%s",\n%s"_ArraySize": %s,\n',padding1,padding0,class(item),padding0,regexprep(mat2str(size(item)),'\s+',',') );
    else
    	txt=sprintf('%s"%s": {\n%s"_ArrayType": "%s",\n%s"_ArraySize": %s,\n',padding1,name,padding0,class(item),padding0,regexprep(mat2str(size(item)),'\s+',',') );
    end
else
    if(isempty(name))
    	txt=sprintf('%s%s',padding1,matdata2json(item,level+1));
    else
    	txt=sprintf('%s"%s": %s',padding1,name,matdata2json(item,level+1));
    end
    return;
end
dataformat='%s%s%s%s%s';

if(issparse(item))
    [ix,iy]=find(item);
    txt=sprintf(dataformat,txt,padding0,'"_ArrayIsSparse": ','1', sprintf(',\n'));
    if(find(size(item)==1))
        txt=sprintf(dataformat,txt,padding0,'"_ArrayData": ',matdata2json([ix,item(find(item))],level+2), sprintf('\n'));
    else
        txt=sprintf(dataformat,txt,padding0,'"_ArrayData": ',matdata2json([ix,iy,item(find(item))],level+2), sprintf('\n'));
    end
else
    txt=sprintf(dataformat,txt,padding0,'"_ArrayData": ',matdata2json(item(:)',level+2), sprintf('\n'));
end
txt=sprintf('%s%s%s',txt,padding1,'}');

%%----------------------------------------------
function txt=matdata2json(mat,level)
if(size(mat,1)==1)
    pre='';
    post='';
    level=level-1;
else
    pre=sprintf('[\n');
    post=sprintf('\n%s]',repmat(sprintf('\t'),1,level-1));
end
if(isempty(mat))
    txt='null';
    return;
end
txt=regexprep(mat2str(mat),'\s+',',');
txt=regexprep(txt,';',sprintf('],\n['));
if(nargin>=2 && size(mat,1)>1)
    txt=regexprep(txt,'\[',[repmat(sprintf('\t'),1,level) '[']);
end
txt=[pre txt post];
if(any(isinf(mat)))
    txt=regexprep(txt,'([-+]*)Inf','"$1_Inf"');
end
if(any(isnan(mat)))
    txt=regexprep(txt,'NaN','"_NaN"');
end