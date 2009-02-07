function exesuff=getexeext()

exesuff='.exe';
if(isunix) 
	exesuff=['.',mexext];
end
if(isoctavemesh)
      if(isempty(strfind(computer,'msdos')))
	    exesuff='.mexglx';
      else
          exesuff='.exe';
      end
end
