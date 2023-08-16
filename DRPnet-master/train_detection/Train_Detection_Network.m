%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Program Name: DRPnet Particle Picking
% 
%  Filename: Train_Detection_Network.m
%
%  Description: 
%        Input:
%       Output:
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


close all;
clc;

global box_size rbox_scale;


addpath('../source');

%% Set figure for display and save
set(0,'DefaultFigureWindowStyle','docked');
rate = 150; % pixels per inch (DEFAULT)

%% Prepare the data
% load training samples

load('TRPV_32_64_bin_train.mat');
imdb.images.data = im2double(uint8(images.data));
imdb.images.label = im2double(uint8(images.labels));
imdb.images.data = single(imdb.images.data(:,:,1,:));
imdb.images.label = single(imdb.images.label);

% load validation samples
load('TRPV_32_64_bin_val.mat');
imdb_val.images.data = im2double(uint8(images.data));
imdb_val.images.label = im2double(uint8(images.labels));
imdb_val.images.data = single(imdb_val.images.data(:,:,1,:));
imdb_val.images.label = single(imdb_val.images.label);

idx = 30;





%BatchSize = 16;
%train_iter = round(N * ratio(1) / BatchSize);



%% Define network
%imageSize = [64 64 1];
%imageSize = [46 46 1];

imageSize = [rbox_scale*2 rbox_scale*2 1];

convLayers = [
%     imageInputLayer(imageSize);
    imageInputLayer(imageSize, 'Normalization', 'none')
    
    convolution2dLayer([9, 9], 32, 'Padding', 4, 'Name', 'conv_1')
%     batchNormalizationLayer
    reluLayer
    
    convolution2dLayer([3, 3], 32, 'Padding', 1, 'Name', 'conv_2')
%     batchNormalizationLayer
    reluLayer
    
    convolution2dLayer([1, 7], 32,'Padding', [0 0 3 3], 'Name', 'conv_3')
%     batchNormalizationLayer
    reluLayer
    
    convolution2dLayer([7, 1], 32, 'Padding', [3 3 0 0], 'Name', 'conv_4')
%     batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2, 'Stride', 1, 'Padding', [0 1 0 1], 'Name', 'pooling_1')
    
    convolution2dLayer([3, 3], 1, 'Padding', 1, 'Name', 'conv_5')
    
%    RegressionMAELayer('reg_mae_loss')
    RegressionMSELayer('reg_mse_loss')
    ];

%% Training Options

BatchSize = 16;
train_iter = round(size(imdb.images.data, 4) / BatchSize);


options = trainingOptions('adam',...    
    'MaxEpochs',7,...   
    'MiniBatchSize',BatchSize,...
    'CheckpointPath','check_points',...
    'Shuffle','every-epoch',...
    'InitialLearnRate',0.001,...     
    'LearnRateSchedule','piecewise',...
    'LearnRateDropFactor',0.1,...
    'LearnRateDropPeriod',train_iter,...
    'ValidationData',{imdb_val.images.data, imdb_val.images.label},...
    'ValidationFrequency',train_iter,...
    'VerboseFrequency',train_iter,...
    'Plots','none');
    %'ValidationData',{valImages,valLabels},...
%'Plots','training-progress');


%% Train network

% cnet = trainNetwork(imdb.images.data, imdb.images.label, convLayers, options);

%cnet = trainNetwork(trainImages, trainLabels, convLayers, options);



%[cnet,info] = trainNetwork(trainImages, trainLabels, convLayers, options);
[cnet,info] = trainNetwork(imdb.images.data, imdb.images.label, convLayers, options);


save('../models/trained_cnet_1.mat', 'cnet');

% check directory exists
if ~exist('./plots', 'dir')
   mkdir('./plots')
end




%% Select particle to test
idx2 = 12;
val_im = imdb.images.data(:, :, :, idx2);
val_lb = imdb.images.label(:, :, :, idx2);

%f1 = figure('Visible', 'off'); imshow(val_im , []); saveas(f1, './plots/figure1.png');
%f2 = figure('Visible', 'off'); imshow(val_lb, []); colormap gray; saveas(f2, './plots/figure2.png');
%f3 = figure('Visible', 'off'); imshow(val_lb, [], 'colormap', jet); saveas(f3, './plots/figure3.png');
%f4 = figure('Visible', 'off'); mesh(val_lb); saveas(f4, './plots/figure4.png');

%% Test to predict particle's map
YPred = predict(cnet, val_im);
YPred = imgaussfilt(YPred, 8);

%f5 = figure('Visible', 'off'); imshow(YPred, []); colormap gray; saveas(f5, './plots/figure5.png');
%f6 = figure('Visible', 'off'); imshow(YPred, [], 'colormap', jet); colorbar; saveas(f6, './plots/figure6.png');
%f7 = figure('Visible', 'off'); mesh(YPred); saveas(f7, './plots/figure7.png');


%%f8 = figure('Visible', 'off');
%plot(info.TrainingLoss)
%hold on
%plot(info.ValidationLoss)
%xlabel('Epoch')
%ylabel('Loss')
%grid on
%legend('Training', 'Validation')

% save the figure
%saveas(f8, './plots/training_validation_loss.png');
clear global box_size rbox_scale;
