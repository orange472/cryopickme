function [im3]=markcontours(im,contours,color,varargin)
%-------------------------------------------------------
% Author: Filiz Bunyak
%-------------------------------------------------------
color=double(color);
if (isempty(varargin))
   mix_ratio=[0 1];
else
   mix_ratio=double(varargin{1});
   mix_ratio=mix_ratio/sum(mix_ratio);
end
[rows,cols,channels]=size(im);
max_im=max(max(max(im)));
if (max_im>2)
    im=double(im)/255;
end
if (channels==1)
    R=im;
    G=im;
    B=im;
else
    R=im(:,:,1);
    G=im(:,:,2);
    B=im(:,:,3);
end
R(contours==1)=mix_ratio(1)*R(contours==1)+ mix_ratio(2)*color(1);
G(contours==1)=mix_ratio(1)*G(contours==1)+ mix_ratio(2)*color(2);
B(contours==1)=mix_ratio(1)*B(contours==1)+ mix_ratio(2)*color(3);

im3(:,:,1)=R;
im3(:,:,2)=G;
im3(:,:,3)=B;

    