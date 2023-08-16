function [class_im,class_rgb]=mapclass2label(label_im,labelclass)
%------------------------------------------------------
% Copyright Filiz Bunyak
%------------------------------------------------------

% 0: black
% 1: red
% 2: green
% -1: gray

class_im=zeros(size(label_im));
for j=1:length(labelclass)
    class_im(label_im==labelclass(j,1))=labelclass(j,2);
end
[rows,cols,channels]=size(class_im);
class_rgb=zeros(rows,cols,3);
class_rgb=markcontours(class_rgb,class_im==-1,[0.5 0.5 0.5]);
class_rgb=markcontours(class_rgb,class_im==1,[1 0 0]);
class_rgb=markcontours(class_rgb,class_im==2,[0 1 0]);
