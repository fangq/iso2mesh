function nii=nii2jnii(filename, format, varargin)
%
%    nii=nii2jnii(niifile, format, options)
%       or
%    nii2jnii(niifile, jniifile, options)
%    nii=nii2jnii(niifile)
%
%    A NIFTI-1/2 file parser and converter to the text and binary JNIfTI formats
%    defined in JNIfTI specification: https://github.com/fangq/jnifti
%
%    author: Qianqian Fang (q.fang <at> neu.edu)
%
%    input:
%        fname: the file name to the .nii file
%        format:'nii' for reading the nii data; 'jnii' to convert the nii data 
%               into an in-memory JNIfTI structure.
%
%               if format is not 'nii' or 'jnii' and nii2jnii is called without 
%               an output, format must be a string specifying the output JNIfTI
%               file name - *.jnii for text-based JNIfTI, or *.bnii for the 
%               binary version
%        options: (optional) if saving to a .bnii file, please see the options for
%               saveubjson.m (part of JSONLab); if saving to .jnii, please see the 
%               supported options for savejson.m (part of JSONLab).
%
%    output:
%        if the output is a JNIfTI data structure, it has the following subfield:
%          nii.NIFTIHeader -  a structure containing the 1-to-1 mapped NIFTI-1/2 header
%          nii.NIFTIData - the main image data array
%          nii.NIFTIExtension - a cell array contaiing the extension data buffers
%
%        when calling as nii=nii2jnii(file,'nii'), the output is a NIFTI object containing
%          nii.img: the data volume read from the nii file
%          nii.datatype: the data type of the voxel, in matlab data type string
%          nii.datalen: data count per voxel - for example RGB data has 3x
%                    uint8 per voxel, so datatype='uint8', datalen=3
%          nii.voxelbyte: total number of bytes per voxel: for RGB data,
%                    voxelbyte=3; also voxelbyte=header.bitpix/8
%          nii.hdr: file header info, a structure has the full nii header
%                    key subfileds include
%
%              sizeof_hdr: must be 348 (for NIFTI-1) or 540 (for NIFTI-2)
%              dim: short array, dim(2: dim(1)+1) defines the array size
%              datatype: the type of data stored in each voxel
%              bitpix: total bits per voxel
%              magic: must be 'ni1\0' or 'n+1\0'
%
%              For the detailed nii header, please see 
%              https://nifti.nimh.nih.gov/pub/dist/src/niftilib/nifti1.h
%
%    this file was initially developed for the MCX project: https://github.com/fangq/mcx/blob/master/utils/mcxloadnii.m
%
%    this file is part of JNIfTI specification: https://github.com/fangq/jnifti
%
%    License: Apache 2.0, see https://github.com/fangq/jnifti for details
%

header = memmapfile(filename,                ...
   'Offset', 0,                           ...
   'Writable', false,                     ...
   'Format', {                            ...
     'int32'   [1 1]  'sizeof_hdr'    ; %!< MUST be 348 	      %  % int sizeof_hdr;       %  ...
     'int8'    [1 10] 'data_type'     ; %!< ++UNUSED++  	      %  % char data_type[10];   %  ...
     'int8'    [1 18] 'db_name'       ; %!< ++UNUSED++  	      %  % char db_name[18];     %  ...
     'int32'   [1 1]  'extents'       ; %!< ++UNUSED++  	      %  % int extents;	         %  ...
     'int16'   [1 1]  'session_error' ; %!< ++UNUSED++  	      %  % short session_error;  %  ...
     'int8'    [1 1]  'regular'       ; %!< ++UNUSED++  	      %  % char regular;	     %  ...
     'int8'    [1 1]  'dim_info'      ; %!< MRI slice ordering.   %  % char hkey_un0;	     %  ...
     'uint16'  [1 8]  'dim'	          ; %!< Data array dimensions.%  % short dim[8];	     %  ...
     'single'  [1 1]  'intent_p1'     ; %!< 1st intent parameter. %  % short unused8/9;      %  ...
     'single'  [1 1]  'intent_p2'     ; %!< 2nd intent parameter. %  % short unused10/11;    %  ...
     'single'  [1 1]  'intent_p3'     ; %!< 3rd intent parameter. %  % short unused12/13;    %  ...
     'int16'   [1 1]  'intent_code'   ; %!< NIFTI_INTENT_* code.  %  % short unused14;       %  ...
     'int16'   [1 1]  'datatype'      ; %!< Defines data type!    %  % short datatype;       %  ...
     'int16'   [1 1]  'bitpix'        ; %!< Number bits/voxel.    %  % short bitpix;	     %  ...
     'int16'   [1 1]  'slice_start'   ; %!< First slice index.    %  % short dim_un0;	     %  ...
     'single'  [1 8]  'pixdim'        ; %!< Grid spacings.	      %  % float pixdim[8];      %  ...
     'single'  [1 1]  'vox_offset'    ; %!< Offset into .nii file %  % float vox_offset;     %  ...
     'single'  [1 1]  'scl_slope'     ; %!< Data scaling: slope.  %  % float funused1;       %  ...
     'single'  [1 1]  'scl_inter'     ; %!< Data scaling: offset. %  % float funused2;       %  ...
     'int16'   [1 1]  'slice_end'     ; %!< Last slice index.	  %  % float funused3;       %  ...
     'int8'    [1 1]  'slice_code'    ; %!< Slice timing order.   %				                ...
     'int8'    [1 1]  'xyzt_units'    ; %!< Units of pixdim[1..4] %				                ...
     'single'  [1 1]  'cal_max'       ; %!< Max display intensity %  % float cal_max;	     %  ...
     'single'  [1 1]  'cal_min'       ; %!< Min display intensity %  % float cal_min;	     %  ...
     'single'  [1 1]  'slice_duration'; %!< Time for 1 slice.	  %  % float compressed;     %  ...
     'single'  [1 1]  'toffset'       ; %!< Time axis shift.	  %  % float verified;       %  ...
     'int32'   [1 1]  'glmax'	      ; %!< ++UNUSED++  	      %  % int glmax;	         %  ...
     'int32'   [1 1]  'glmin'	      ; %!< ++UNUSED++  	      %  % int glmin;	         %  ...
     'int8'    [1 80] 'descrip'       ; %!< any text you like.    %  % char descrip[80];     %  ...
     'int8'    [1 24] 'aux_file'      ; %!< auxiliary filename.   %  % char aux_file[24];    %  ...
     'int16'   [1 1]  'qform_code'    ; %!< NIFTI_XFORM_* code.   %  %-- all ANALYZE 7.5 --- %  ...
     'int16'   [1 1]  'sform_code'    ; %!< NIFTI_XFORM_* code.   %  %below here are replaced%  ...
     'single'  [1 1]  'quatern_b'     ; %!< Quaternion b param.   %				...
     'single'  [1 1]  'quatern_c'     ; %!< Quaternion c param.   %				...
     'single'  [1 1]  'quatern_d'     ; %!< Quaternion d param.   %				...
     'single'  [1 1]  'qoffset_x'     ; %!< Quaternion x shift.   %				...
     'single'  [1 1]  'qoffset_y'     ; %!< Quaternion y shift.   %				...
     'single'  [1 1]  'qoffset_z'     ; %!< Quaternion z shift.   %				...
     'single'  [1 4]  'srow_x'        ; %!< 1st row affine transform.	%			...
     'single'  [1 4]  'srow_y'        ; %!< 2nd row affine transform.	%			...
     'single'  [1 4]  'srow_z'        ; %!< 3rd row affine transform.	%			...
     'int8'    [1 16] 'intent_name'   ; %!< 'name' or meaning of data.  %			...
     'int8'    [1 4]  'magic'	      ; %!< MUST be "ni1\0" or "n+1\0". %			...
     'int8'    [1 4]  'extension'	    %!< header extension	  %				...
   });

nii.hdr=header.Data(1);

[os,maxelem,dataendian]=computer;

if(nii.hdr.sizeof_hdr~=348 && nii.hdr.sizeof_hdr~=540)
    nii.hdr.sizeof_hdr=swapbytes(nii.hdr.sizeof_hdr);
end

if(nii.hdr.sizeof_hdr==540) % NIFTI-2 format
  header = memmapfile(filename,                ...
   'Offset', 0,                           ...
   'Writable', false,                     ...
   'Format', {                            ...
     'int32'   [1 1]  'sizeof_hdr'    ; %!< MUST be 540 	      %  % int sizeof_hdr;       %  ...
     'int8'    [1 8]  'magic'	      ; %!< MUST be "ni2\0" or "n+2\0". %			...
     'int16'   [1 1]  'datatype'      ; %!< Defines data type!    %  % short datatype;       %  ...
     'int16'   [1 1]  'bitpix'        ; %!< Number bits/voxel.    %  % short bitpix;	     %  ...
     'int64'   [1 8]  'dim'	          ; %!< Data array dimensions.%  % short dim[8];	     %  ...
     'double'  [1 1]  'intent_p1'     ; %!< 1st intent parameter. %  % short unused8/9;      %  ...
     'double'  [1 1]  'intent_p2'     ; %!< 2nd intent parameter. %  % short unused10/11;    %  ...
     'double'  [1 1]  'intent_p3'     ; %!< 3rd intent parameter. %  % short unused12/13;    %  ...
     'double'  [1 8]  'pixdim'        ; %!< Grid spacings.	      %  % float pixdim[8];      %  ...
     'int64'   [1 1]  'vox_offset'    ; %!< Offset into .nii file %  % float vox_offset;     %  ...
     'double'  [1 1]  'scl_slope'     ; %!< Data scaling: slope.  %  % float funused1;       %  ...
     'double'  [1 1]  'scl_inter'     ; %!< Data scaling: offset. %  % float funused2;       %  ...
     'double'  [1 1]  'cal_max'       ; %!< Max display intensity %  % float cal_max;	     %  ...
     'double'  [1 1]  'cal_min'       ; %!< Min display intensity %  % float cal_min;	     %  ...
     'double'  [1 1]  'slice_duration'; %!< Time for 1 slice.	  %  % float compressed;     %  ...
     'double'  [1 1]  'toffset'       ; %!< Time axis shift.	  %  % float verified;       %  ...
     'int64'   [1 1]  'slice_start'   ; %!< First slice index.    %  % short dim_un0;	     %  ...
     'int64'   [1 1]  'slice_end'     ; %!< Last slice index.	  %  % float funused3;       %  ...
     'int8'    [1 80] 'descrip'       ; %!< any text you like.    %  % char descrip[80];     %  ...
     'int8'    [1 24] 'aux_file'      ; %!< auxiliary filename.   %  % char aux_file[24];    %  ...
     'int32'   [1 1]  'qform_code'    ; %!< NIFTI_XFORM_* code.   %  %-- all ANALYZE 7.5 --- %  ...
     'int32'   [1 1]  'sform_code'    ; %!< NIFTI_XFORM_* code.   %  %below here are replaced%  ...
     'double'  [1 1]  'quatern_b'     ; %!< Quaternion b param.   %				...
     'double'  [1 1]  'quatern_c'     ; %!< Quaternion c param.   %				...
     'double'  [1 1]  'quatern_d'     ; %!< Quaternion d param.   %				...
     'double'  [1 1]  'qoffset_x'     ; %!< Quaternion x shift.   %				...
     'double'  [1 1]  'qoffset_y'     ; %!< Quaternion y shift.   %				...
     'double'  [1 1]  'qoffset_z'     ; %!< Quaternion z shift.   %				...
     'double'  [1 4]  'srow_x'        ; %!< 1st row affine transform.	%			...
     'double'  [1 4]  'srow_y'        ; %!< 2nd row affine transform.	%			...
     'double'  [1 4]  'srow_z'        ; %!< 3rd row affine transform.	%			...
     'int32'   [1 1]  'slice_code'    ; %!< Slice timing order.   %				                ...
     'int32'   [1 1]  'xyzt_units'    ; %!< Units of pixdim[1..4] %				                ...
     'int32'   [1 1]  'intent_code'   ; %!< NIFTI_INTENT_* code.  %  % short unused14;       %  ...
     'int8'    [1 16] 'intent_name'   ; %!< 'name' or meaning of data.  %			...
     'int8'    [1 1]  'dim_info'      ; %!< MRI slice ordering.   %  % char hkey_un0;	     %  ...
     'int8'    [1 15] 'reserved'	    %!< unused buffer	  %				...
     'int8'    [1 4]  'extension'	    %!< header extension	  %				...
   });

   nii.hdr=header.Data(1);
end

if(nii.hdr.dim(1)>7)
    names=fieldnames(nii.hdr);
    for i=1:length(names)
        nii.hdr.(names{i})=swapbytes(nii.hdr.(names{i}));
    end
    if(dataendian=='B')
        dataendian='little';
    else
        dataendian='big';
    end
end

type2byte=[
        0  0  % unknown                      %
        1  0  % binary (1 bit/voxel)         %
        2  1  % unsigned char (8 bits/voxel) %
        4  2  % signed short (16 bits/voxel) %
        8  4  % signed int (32 bits/voxel)   %
       16  4  % float (32 bits/voxel)        %
       32  8  % complex (64 bits/voxel)      %
       64  8  % double (64 bits/voxel)       %
      128  3  % RGB triple (24 bits/voxel)   %
      255  0  % not very useful (?)          %
      256  1  % signed char (8 bits)         %
      512  2  % unsigned short (16 bits)     %
      768  4  % unsigned int (32 bits)       %
     1024  8  % long long (64 bits)          %
     1280  8  % unsigned long long (64 bits) %
     1536 16  % long double (128 bits)       %
     1792 16  % double pair (128 bits)       %
     2048 32  % long double pair (256 bits)  %
     2304  4  % 4 byte RGBA (32 bits/voxel)  %
];

type2str={
    'uint8'    0   % unknown                       %
    'uint8'    0   % binary (1 bit/voxel)          %
    'uint8'    1   % unsigned char (8 bits/voxel)  %
    'uint16'   1   % signed short (16 bits/voxel)  %
    'int32'    1   % signed int (32 bits/voxel)    %
    'float32'  1   % float (32 bits/voxel)         %
    'float32'  2   % complex (64 bits/voxel)       %
    'float64'  1   % double (64 bits/voxel)        %
    'uint8'    3   % RGB triple (24 bits/voxel)    %
    'uint8'    0   % not very useful (?)           %
    'int8'     1   % signed char (8 bits)          %
    'uint16'   1   % unsigned short (16 bits)      %
    'uint32'   1   % unsigned int (32 bits)        %
    'long'     1   % long long (64 bits)           %
    'ulong'    1   % unsigned long long (64 bits)  %
    'uint8'    16  % long double (128 bits)        %
    'uint8'    16  % double pair (128 bits)        %
    'uint8'    32  % long double pair (256 bits)   %
    'uint8'    4   % 4 byte RGBA (32 bits/voxel)   %
};

typeidx=find(type2byte(:,1)==nii.hdr.datatype);

nii.datatype=type2str{typeidx,1};
nii.datalen=type2str{typeidx,2};
nii.voxelbyte=type2byte(typeidx,2);

if(type2byte(typeidx,2)==0)
    nii.img=[];
    return;
end

if(type2str{typeidx,2}>1)
    nii.hdr.dim=[nii.hdr.dim(1)+1 uint16(nii.datalen) nii.hdr.dim(2:end)]; 
end

fid=fopen(filename,'rb');
fseek(fid,nii.hdr.vox_offset,'bof');
nii.img=fread(fid,prod(nii.hdr.dim(2:nii.hdr.dim(1)+1)),[nii.datatype '=>' nii.datatype]);
fclose(fid);

nii.img=reshape(nii.img,nii.hdr.dim(2:nii.hdr.dim(1)+1));

if(nargin>1 && strcmp(format,'nii'))
    return;
end

nii0=nii;
nii=struct();
nii.NIFTIHeader.NIIHeaderSize=  nii0.hdr.sizeof_hdr;
if(isfield(nii0.hdr,'data_type'))
    nii.NIFTIHeader.A75DataTypeName=deblank(char(nii0.hdr.data_type));
    nii.NIFTIHeader.A75DBName=      deblank(char(nii0.hdr.db_name));
    nii.NIFTIHeader.A75Extends=     nii0.hdr.extents;
    nii.NIFTIHeader.A75SessionError=nii0.hdr.session_error;
    nii.NIFTIHeader.A75Regular=     nii0.hdr.regular;
end
nii.NIFTIHeader.DimInfo.Freq=   bitand(nii0.hdr.dim_info,7);
nii.NIFTIHeader.DimInfo.Phase=  bitand(bitshift(nii0.hdr.dim_info,-3),7);
nii.NIFTIHeader.DimInfo.Slice=  bitand(bitshift(nii0.hdr.dim_info,-6),7);
nii.NIFTIHeader.Dim=            nii0.hdr.dim(2:2+nii0.hdr.dim(1)-1);
nii.NIFTIHeader.Param1=         nii0.hdr.intent_p1;
nii.NIFTIHeader.Param2=         nii0.hdr.intent_p2;
nii.NIFTIHeader.Param3=         nii0.hdr.intent_p3;
nii.NIFTIHeader.Intent=         niicodemap('intent',nii0.hdr.intent_code);
nii.NIFTIHeader.DataType=       niicodemap('datatype',nii0.hdr.datatype);
nii.NIFTIHeader.BitDepth=       nii0.hdr.bitpix;
nii.NIFTIHeader.FirstSliceID=   nii0.hdr.slice_start;
nii.NIFTIHeader.VoxelSize=      nii0.hdr.pixdim(2:2+nii0.hdr.dim(1)-1);
nii.NIFTIHeader.Orientation=    struct('x','r','y','a','z','s');
if(nii0.hdr.pixdim(1)<0)
    nii.NIFTIHeader.Orientation=    struct('x','l','y','a','z','s');
end
nii.NIFTIHeader.NIIByteOffset=  nii0.hdr.vox_offset;
nii.NIFTIHeader.ScaleSlope=     nii0.hdr.scl_slope;
nii.NIFTIHeader.ScaleOffset=    nii0.hdr.scl_inter;
nii.NIFTIHeader.LastSliceID=    nii0.hdr.slice_end;
nii.NIFTIHeader.SliceType=      niicodemap('slicetype',nii0.hdr.slice_code);
nii.NIFTIHeader.Unit.L=         niicodemap('unit',bitand(nii0.hdr.xyzt_units, 7));
nii.NIFTIHeader.Unit.T=         niicodemap('unit',bitand(nii0.hdr.xyzt_units, 56));
nii.NIFTIHeader.MaxIntensity=   nii0.hdr.cal_max;
nii.NIFTIHeader.MinIntensity=   nii0.hdr.cal_min;
nii.NIFTIHeader.SliceTime=      nii0.hdr.slice_duration;
nii.NIFTIHeader.TimeOffset=     nii0.hdr.toffset;
if(isfield(nii0.hdr,'glmax'))
    nii.NIFTIHeader.A75GlobalMax=   nii0.hdr.glmax;
    nii.NIFTIHeader.A75GlobalMin=   nii0.hdr.glmin;
end
nii.NIFTIHeader.Description=    deblank(char(nii0.hdr.descrip));
nii.NIFTIHeader.AuxFile=        deblank(char(nii0.hdr.aux_file));
nii.NIFTIHeader.QForm=          nii0.hdr.qform_code;
nii.NIFTIHeader.SForm=          nii0.hdr.sform_code;
nii.NIFTIHeader.Quatern.b=      nii0.hdr.quatern_b;
nii.NIFTIHeader.Quatern.c=      nii0.hdr.quatern_c;
nii.NIFTIHeader.Quatern.d=      nii0.hdr.quatern_d;
nii.NIFTIHeader.QuaternOffset.x=nii0.hdr.qoffset_x;
nii.NIFTIHeader.QuaternOffset.y=nii0.hdr.qoffset_y;
nii.NIFTIHeader.QuaternOffset.z=nii0.hdr.qoffset_z;
nii.NIFTIHeader.Affine(1,:)=    nii0.hdr.srow_x;
nii.NIFTIHeader.Affine(2,:)=    nii0.hdr.srow_y;
nii.NIFTIHeader.Affine(3,:)=    nii0.hdr.srow_z;
nii.NIFTIHeader.Name=           deblank(char(nii0.hdr.intent_name));
nii.NIFTIHeader.NIIFormat=      deblank(char(nii0.hdr.magic));
nii.NIFTIHeader.NIIExtender=    nii0.hdr.extension;
nii.NIFTIHeader.NIIQfac_=       nii0.hdr.pixdim(1);
nii.NIFTIHeader.NIIEndian_=     dataendian;
if(isfield(nii0.hdr,'reserved'))
    nii.NIFTIHeader.NIIUnused_= nii0.hdr.reserved;
end

nii.NIFTIData=nii0.img;

if(nii0.hdr.extension(1)>0)
    fid=fopen(filename,'rb');
    fseek(fid,nii0.hdr.sizeof_hdr+4,'bof');
    nii.NIFTIExtension=cell();
    count=1;
    while(ftell(fid)<nii0.vox_offset)
       nii.NIFTIExtension{count}.Size=fread(fid,1,'int32=>int32');
       nii.NIFTIExtension{count}.Type=fread(fid,1,'int32=>int32');
       nii.NIFTIExtension{count}.x0x5F_ByteStream_=fread(fid,nii.NIFTIExtension{count}.Size-8,'uint8=>uint8');
       count=count+1;
    end
    fclose(fid);
end

if(nargout==0 && strcmp(format,'nii')==0 && strcmp(format,'jnii')==0)
    if(~exist('savejson','file'))
        error('you must first install JSONLab from http://github.com/fangq/jsonlab/');
    end
    if(regexp(format,'\.jnii$'))
        savejson('',nii,'FileName',format,varargin{:});
    elseif(regexp(format,'\.bnii$'))
        saveubjson('',nii,'FileName',format,varargin{:});
    else
        error('file suffix must be .jnii for text JNIfTI or .bnii for binary JNIfTI');
    end
end
