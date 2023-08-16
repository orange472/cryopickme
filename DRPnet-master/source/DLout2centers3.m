%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Program Name: DRPnet Particle Picking
%
%  Filename: DLout2centers3.m
%
%  Description: Return the coordinates of particles from probability map of
%  an image
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

function [clist,peaks]=DLout2centers2(out,sigma,T)
%-----------------------------------
%out=imread('out.tif');
%im=imread('img2.tif');
%im0=im;
%out0=out;

fsize=sigma*6;
f=fspecial('gaussian',fsize,sigma);
out=conv2(double(out),f,'same');

for k=1:3
    peaks(:,:,k)=imextendedmax(out,T*k);
    L=bwlabel(peaks(:,:,k));
    stat=regionprops(L,'Centroid');
    temp=[stat.Centroid];
    clist(k).centers(:,1)=temp(1:2:end);
    clist(k).centers(:,2)=temp(2:2:end);
end
