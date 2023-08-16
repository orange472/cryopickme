function im=PadImage4BlockCNN(im0,block_size)
%-----------------------------------------------------
% Authors: Zahra Al-Milaji & Filiz Bunyak
%-----------------------------------------------------
[rows,cols,channels]=size(im0);
rp=ceil(rows/block_size);
cp=ceil(cols/block_size);
r_pad=abs((rp*block_size)-rows); 
c_pad=abs((cp*block_size)-cols);
im=padarray(im0,[r_pad c_pad],'symmetric','post');
 

