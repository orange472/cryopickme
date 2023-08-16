%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Program Name: DRPnet Particle Picking
%
% Filename: CreateDetectionNet.m
%
%  Description: Create detection network (CNN-1 or FCRN)
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

function convLayers = CreateDetectionNet()

%imageSize = [64 64 1];
%imageSize = [rbox_scale*2 rbox_scale*2 1];
imageSize = [46 46 1];

convLayers = [
    % imageInputLayer(imageSize);
    imageInputLayer(imageSize, 'Normalization', 'none')
    
    convolution2dLayer([9, 9], 32, 'Padding', 4, 'Name', 'conv_1')
    % batchNormalizationLayer
    reluLayer
    
    convolution2dLayer([3, 3], 32, 'Padding', 1, 'Name', 'conv_2')
    % batchNormalizationLayer
    reluLayer
    
    convolution2dLayer([1, 7], 32,'Padding', [0 0 3 3], 'Name', 'conv_3')
    % batchNormalizationLayer
    reluLayer
    
    convolution2dLayer([7, 1], 32, 'Padding', [3 3 0 0], 'Name', 'conv_4')
    % batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2, 'Stride', 1, 'Padding', [0 1 0 1], 'Name', 'pooling_1')
    
    convolution2dLayer([3, 3], 1, 'Padding', 1, 'Name', 'conv_5')
    
    % RegressionMAELayer('reg_mae_loss')
    RegressionMSELayer('reg_mse_loss')
    ];

end