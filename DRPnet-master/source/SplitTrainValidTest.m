%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Program Name: DRPnet Particle Picking
%
%  Filename: SplitTrainValidTest.m
%
%  Description: Split train, validation and test set for samples stored in
%  Matlab array (memory)
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

function [X_train, X_valid, X_test, Y_train, Y_valid, Y_test] = SplitTrainValidTest(X, Y, ratio)

num_classes = size(unique(Y), 1);
num_total_samples = size(Y, 1);

num_samples_per_class = num_total_samples / num_classes;

num_train_per_class = floor(num_samples_per_class * ratio(1));
num_test_per_class = floor(num_samples_per_class * ratio(3));
num_valid_per_class = num_samples_per_class - num_train_per_class - num_test_per_class;

idx = randperm(num_samples_per_class);

idx_class_train = idx(1:num_train_per_class);
idx_class_valid = idx(num_train_per_class+1:num_train_per_class+num_valid_per_class);
idx_class_test = idx(num_train_per_class+num_valid_per_class+1:end);

id_train = [];
id_valid = [];
id_test = [];


for i = 1:num_classes
    it_train = (i - 1) * num_samples_per_class + idx_class_train;
    it_valid = (i - 1) * num_samples_per_class + idx_class_valid;
    it_test = (i - 1) * num_samples_per_class + idx_class_test;
    
    id_train = [id_train, it_train];
    id_valid = [id_valid, it_valid];
    id_test = [id_test, it_test];
end

X_train = X(:, :, :, id_train);
X_valid = X(:, :, :, id_valid);
X_test = X(:, :, :, id_test);

Y_train = Y(id_train);
Y_valid = Y(id_valid);
Y_test = Y(id_test);


end