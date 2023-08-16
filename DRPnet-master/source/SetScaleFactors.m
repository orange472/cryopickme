%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Program Name: DRPnet Particle Picking
%
%  Filename: RegressionMSELayer.m
%
%  Description: Computes the scaling factors based on input particle size
%        Input: 
%               + box_size: particle box size
%       Output:
%               + scale_factor:
%               + sigma_gauss:
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


function [scale_factor, rbox_scale, sigma_gauss, f3] = SetScaleFactors(training_folder, box_size)

IM_SIZE_REF = 1800;
r_factor = 1.5;
rbox_ref = 32;
rbox_large = 96;


%-------------------------------------------------------------------------



flist_train = dir(fullfile(training_folder, '*.mrc'));

% Check if the file list is empty
if isempty(flist_train)
    error('No files found in the specified (training) directory.');
end

fname=flist_train(1).name;

folder=flist_train(1).folder;

startSlice=1;
numSlices=1;
debug=0;
%[map0,s,hdr,extraHeader]=ReadMRC(fullfile(training_folder,fname), startSlice, numSlices, debug);
[map0,s,hdr,extraHeader]=ReadMRC(fullfile(folder,fname), startSlice, numSlices, debug);  % use folder instead inpath

dims = size(map0); 




%---- box_size: input particle size (in pixels) 
rbox = box_size/2;
%-----rbox_ref: reference particle radius, will be used to scale the input image 


if rbox > rbox_large * r_factor
    rbox_ref = rbox_ref * r_factor; % rbox_ref = 48;
end
%----- given input particle size and reference particle radius estimates input image scaling factor 
if (rbox / rbox_ref > 2) %--- large input particles
    f1 = ceil(rbox / rbox_ref);
elseif (rbox / rbox_ref > 1)  %--- medium sized particles
    f1 = 2;
else  %--- small particles
    f1 = 1;
end

f2 = 1;
if dims(1)/f1 > IM_SIZE_REF
    f2 = ceil(dims(1)/IM_SIZE_REF);
end


scale_factor = f1*f2;

rbox_scale = floor(rbox / scale_factor);

% sigma_gauss = ceil(rbox_scale/10);
% sigma_gauss = 3;
%----- sigma to smooth output of CNN-1 (larger particles smoothed more)
if rbox_scale < rbox_ref
    f3 = 1;
    sigma_gauss = 3;
else
    f3 = 2; 
    sigma_gauss = 4;
end

end