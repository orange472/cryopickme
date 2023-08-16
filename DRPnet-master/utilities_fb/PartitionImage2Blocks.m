function mask=PartitionImage2Blocks(rows1,cols1,block_size)
%-----------------------------------------------------
% Authors: Zahraa Al-Milaji & Filiz Bunyak
%-----------------------------------------------------
% Traverse the matrix column-wise because im2col works colum-wise
mask=zeros(rows1,cols1);
%     block_size=32;
label=1;
 for j=1:block_size:cols1
   for i=1:block_size:rows1
      if i(i>=rows1-block_size || j>=cols1-block_size )
        mask(i:rows1,j:cols1)  =label;
      else
           mask(i:i+block_size,j:j+block_size)  =label;
      end
      label=label+1;
  end
end
