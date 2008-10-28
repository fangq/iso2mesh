function flag=deletemeshfile(fname)
if(exist(mwpath(fname))) 
	delete(mwpath(fname)); 
end
