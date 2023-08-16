function [MatchMatrix,n12,n1,n2]=LabelCooccurence(L1,L2,alpha_mask)
%------------------------------------------------
%---------------------------------------------
%
% Copyright(C)
% Filiz Bunyak Ersoy
% University of Missouri-Columbia 
% bunyak@missouri.edu
% & 
% Mingzhai Sun
% Princeton University
% mingzhai@gmail.com
%---------------------------------------------
% Find L1,L2 label correspondences where alpha_mask~=0

[rows,cols]=size(L1);

A1=reshape(L1,[rows*cols 1]);
A2=reshape(L2,[rows*cols 1]);
alpha=reshape(alpha_mask, [rows*cols 1]);

A1(alpha==0)=[];
A2(alpha==0)=[];

nv=length(A1);
C=zeros(nv,2);

C(:,1)=A1;
C(:,2)=A2;

[MatchMatrix,m,ind]=unique(C,'rows');
n12=size(MatchMatrix,1);
n1=length(unique(MatchMatrix(:,1)));
n2=length(unique(MatchMatrix(:,2)));

h=hist(ind,n12);
MatchMatrix(:,3)=h';
