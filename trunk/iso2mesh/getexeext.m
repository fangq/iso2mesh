function exesuff=getexeext()

exesuff='.exe';
if(isunix) 
	exesuff=['.',mexext];
end
if(isoctavemesh)
	exesuff=".mexglx";
end
