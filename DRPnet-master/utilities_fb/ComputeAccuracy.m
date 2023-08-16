function [Acc,M11,M22,M12,M21]=ComputeAccuracy(GT,L2)
%---------------------------------------------
%% Copyright(C)
% Filiz Bunyak Ersoy
% University of Missouri-Columbia 
% bunyak@missouri.edu
%---------------------------------------------
% GT: ground truth
% L2: classifier output
% Values: 
% 0-> ignore
% 1-> class 1
% 2-> class 2
% alpha_mask: 1-> evaluate; 0->ignore
%---------------------------------------------
alpha_mask=ones(size(L2));
alpha_mask(GT==0)=0;

[MatchMatrix,n12,n1,n2]=LabelCooccurence(GT,L2,alpha_mask);

c1=MatchMatrix(:,1);
c2=MatchMatrix(:,2);
c3=MatchMatrix(:,3);

M11=sum(c3.*(c1==1).*(c2==1)); % TP
M22=sum(c3.*(c1==2).*(c2==2)); % TN
M12=sum(c3.*(c1==1).*(c2==2));%FP
M21=sum(c3.*(c1==2).*(c2==1));%FN

Acc=(M11+M22)/(M11+M22+M12+M21);
