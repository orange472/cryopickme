function [x1]=prepareData2test(data3,block_size)
%---------------------------------------------------------
n=size(data3,1);
if (n>100)
    batch_size=100;
else
    batch_size=floor(n*0.75);
end
    
n_o_r=floor(size(data3,1)/batch_size)*batch_size;

%norx1=n_o_r-batch_size;
%norx2=n_o_r-norx1;

norx1=n_o_r-batch_size;
%norx2=n-n_o_r;
%norx2=n-norx1;
norx2=n_o_r-norx1;

%x1  = double(reshape(data3(1:norx1,:)',block_size,block_size,3,norx1)); % dataset regions
%x2  = double(reshape(data3(norx1+1:n_o_r,:)',block_size,block_size,3,norx2));

s1=1; e1=norx1;
s2=e1+1; e2=s2+norx2-1;

x1  = double(reshape(data3(s1:e1,:)',block_size,block_size,3,norx1)); % dataset regions
x2  = double(reshape(data3(s2:e2,:)',block_size,block_size,3,norx2));
% Xn = horzcat(x1,x2);

%y1=double(theclass(1:norx1,:)'); %  labels of classes -> training
%y2=double(theclass(norx1+1:n_o_r,:)'); %  labels of classes -> validiation

% y1=double(theclass(s1:e1,:)'); %  labels of classes -> training
% y2=double(theclass(s2:e2,:)'); %  labels of classes -> validiation
