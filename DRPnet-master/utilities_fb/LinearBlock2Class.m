function [count,class]=LinearBlock2Class(X_GT,min_percent)
%-------------------------------
[rows,cols]=size(X_GT);
classlist=unique(X_GT);
nclass=length(classlist);
count=zeros(rows,nclass);


for c=1:nclass
    class=classlist(c);
    mask=X_GT==class; 
    count(:,c)=sum(mask,2);
end

[val,ind]=max(count,[],2);

undecided=zeros(size(val));
pval=100*double(val)/double(cols);
undecided(pval<min_percent)=1;
class(undecided==1)=-1;
class(undecided==0)=classlist(ind(undecided==0));
class=class';
