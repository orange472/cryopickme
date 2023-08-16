function Fmat2=LinearizeBlocks_blockfast(im,block_size,labels)
%==========================================
%---------------------------------------------
% Copyright(C)
% Filiz Bunyak Ersoy
% University of Missouri-Columbia 
% bunyak@missouri.edu
%--------------------------------------------- 
temp=Linearize(labels,block_size);
R=temp(:,1);
[val,ind]=sort(R);
Fmat2=Linearize(im,block_size);
%---sort according to labels
channels=size(Fmat2,3);
for ch=1:channels
    temp=Fmat2(:,:,ch);
    Fmat2(:,:,ch)=temp(ind,:);
end


function Fmat2=Linearize(im,block_size)
%--------------------------------
channels=size(im,3);
Fmat2=[];
for ch=1:channels
    temp=im2col(im(:,:,ch),[block_size block_size],'distinct');
    Fmat2(:,:,ch)=temp';
end
     