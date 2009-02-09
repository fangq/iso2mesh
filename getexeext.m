function exesuff=getexeext()

exesuff='.exe';
if(isunix) 
	exesuff=['.',mexext];
	if(strcmp(exesuff,'.mexmaci'))
		exesuff='.mexmac'; % will use universal binary for Mac
	end
end
if(isoctavemesh)
      if(isempty(strfind(computer,'msdos')))
	    exesuff='.mexglx';
      else
          exesuff='.exe';
      end
end
