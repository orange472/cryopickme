function Fmat=LinearizeBlocks_labels(im,block_size,labels)
%==========================================
%---------------------------------------------
% Copyright(C)
% Filiz Bunyak Ersoy & Zahraa Al-Milaji
% University of Missouri-Columbia 
% bunyak@missouri.edu
%--------------------------------------------- 

im1=im(:,:,1);
im2=im(:,:,2);
im3=im(:,:,3);

% Fmat: Each row is a block, column: 32x32 block reshaped to 1D array     
Fmat=[];
bl_size=block_size*block_size;
for fm=1:max(max(labels))
    if size(im(labels==fm))<bl_size
        RCFmat_train(fm,2) =-2;
        Fmat(fm,:,:)=zeros(1,bl_size,3);
    else
        Fmat(fm,:,1)=im1(labels==fm);
        Fmat(fm,:,2)=im2(labels==fm);
        Fmat(fm,:,3)=im3(labels==fm);
    end
end
     