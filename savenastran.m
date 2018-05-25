function savenastran(v, el, fname)
% savenastran(v, el, fname)
%
% save a volume mesh in NASTRAN format.
%
% author: Salvatore Cunsolo (sal.cuns@gmail.com)
% date: 2012/9/23
%
% input:
%      v: input, volume node list, dimension (nn, 3)
%      el: input, volume tetra element list, dimension (te, 5)
%      fname: output file name
% Start section

    fid=fopen(fname,'wt');
    fprintf(fid,'CEND\nBEGIN BULK\n');
    
    v = v - repmat(min(v), size(v, 1), 1) + 1e-6;
    
    scale = ceil(log10(max(max(abs(v(:, 1:3))))));
    afterdecimal = min(6, 8 - (scale + 1));
    
    nodestring = sprintf('GRID%%12d        %%8.%df%%8.%df%%8.%df\n', afterdecimal, afterdecimal, afterdecimal);
    fprintf(fid, nodestring, [1:size(v, 1); v(:, 1:3)']);
    
    if any(el)
        fprintf(fid, 'CTETRA%10d%8d%8d%8d%8d%8d\n', [1:size(tel, 1); circshift(tel, [0 1])']);
    end
    fprintf(fid, 'ENDDATA');
    fclose(fid);
end