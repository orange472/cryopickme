function [GT]=ConvertGT_Cornea(GT_RGB)
%--------------------------
ma=max(max(max(GT_RGB)));

R=GT_RGB(:,:,1);
G=GT_RGB(:,:,2);
B=GT_RGB(:,:,3);


R(G>R)=0;
G(R>G)=0;
R(R<ma*0.5)=0;
R(R>0)=1;
B(B<ma*0.3)=0;
B(B>0)=1;
% if (sum(sum(B))>100)
%    imshow(B); 
% end
G(G<ma*0.5)=0;
G(G>0)=1;
%------------------------------
GT=ones(size(R));
GT(G==1)=2;
GT(B==1)=0;
GT(R==1)=0;
