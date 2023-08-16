%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Program Name: DRPnet Particle Picking
%
%  Filename: cropsquare_up.m
%
%  Description: Crop particle patches to prepare training samples for 
%  detection network (CNN-1 or FCRN)
%
%  Author: Nguyen Phuoc Nguyen
%
%  Copyright (C) 2018-2019. 
%       Nguyen Phuoc Nguyen, Ilker Ersoy, Filiz Bunyak, 
%       Tommi A. White, and Curators of the
%       University of Missouri, a public corporation.
%       All Rights Reserved.
%
%  Created by:
%     Nguyen Phuoc Nguyen, Ilker Ersoy, Filiz Bunyak, Tommi A. White
%     Dept. of Biochemistry & Electron Microscopy Core
%     and Dept. of Electrical Engineering and Computer Science,
%     University of Missouri-Columbia.
%
%  For more information, contact:
%     Dr. Tommi A. White
%     W117 Veterinary Medicine Building
%     University of Missouri, Columbia
%     Columbia, MO 65211
%     (573) 882-8304
%     whiteto@missouri.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function IC=cropsquare_up(I,X,Y,R)
%--------------------------------------
channels=size(I,3);
X1=X-R;
X2=X+R;
Y1=Y-R;
Y2=Y+R;
% w=1*R;
w=2*R;



indexX = find(X1<=0);
indexY = find(Y1<=0);
imgwidth = size(I,1);
indeX2 = X2>imgwidth;
indeY2 = Y2>imgwidth;
X2(indeX2)=imgwidth;
Y2(indeY2)= imgwidth;
X1(indexX)=1; Y1(indexY)=1;

count = length(X1);
IC = zeros(w,w,channels,count);
for i=1:count
    
    img=I(X1(i):X2(i),Y1(i):Y2(i),:);
    [x,y,~] = size(img);
    if x ~=w || y~=w
        img = imresize(img,[w w]);
    end
    IC(:,:,:,i) = img;
end
