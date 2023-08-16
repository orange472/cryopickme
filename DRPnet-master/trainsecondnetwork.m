
function trainsecondnetwork(training_folder, validation_folder, inpath, params_file, box_size_str)
box_size = str2double(box_size_str);


set(0,'DefaultFigureWindowStyle','docked');
close all;

clc;

addpath('source');
warning('on', 'all');
%warning('off', 'all');

%% SET UP PARAMETERS

tic1 = tic; % Start timer 1


[names vals inputParams]=ParseParams(params_file);

for i=1:length(names)
    if isnumeric(vals{i})
        eval([genvarname(names{i}) ' = ' num2str(vals{i}) ';']);
    else
        eval([genvarname(names{i}) ' = ' vals{i} ';']);
    end
end


[scale_factor, rbox_scale, sigma_gauss, f3] = SetScaleFactors(inpath, box_size);




%% load detection network
convLayers = CreateDetectionNet();

%loads the trained one, unless doesn't exist. specifies which was loaded
trained = 'models/trained_cnet_1.mat';
pretrained = 'models/cnet_1.mat';

if exist(trained, 'file') == 2
    load(trained);
    disp(['Using trained cnet1 to train cnet2: ' trained]);
else
    load(pretrained);
    disp(['Using pretrained cnet1 to train cnet 2: ' pretrained]);
end




%% DETECT AND CLASSIFY PARTICLE
training = retrain;
linewidth = 2;

%patches_pos = [];
%patches_neg = [];
patches_pos_train = [];
patches_neg_train = [];

patches_pos_val = [];
patches_neg_val = [];

store_struct = [];




flist_all = dir(fullfile(inpath,'*.mrc'));

flist_train = dir(fullfile(training_folder, '*.mrc'));
flist_val = dir(fullfile(validation_folder, '*.mrc'));

flist_train_names = {flist_train.name};
flist_val_names = {flist_val.name};

% Find the indices of training and validation files in the main list
[~, train_indices] = ismember(flist_train_names, {flist_all.name});
[~, val_indices] = ismember(flist_val_names, {flist_all.name});

% Remove training and validation file names from the main list
flist_testing = flist_all;
flist_testing([train_indices, val_indices]) = [];

% Concatenate the names of training, validation, and the remaining (testing) files
flist = [flist_train; flist_val; flist_testing];

num_images = length(flist);
num_images_train = length(flist_train);
num_images_val = length(flist_val);






index = 1;

while index <= num_images
   
    % ============================= PRE-PROCESS ===========================




fname = flist(index).name;
store_struct(index).FileName = fname;



preprocessed_dir = 'images/preprocessedimages';
if ~exist(preprocessed_dir, 'dir')
   mkdir(preprocessed_dir);
end





full_file_path = fullfile(flist(index).folder, flist(index).name);  % Get the full file path from 'flist'
[~, name, ~] = fileparts(full_file_path);
preprocessed_fname = fullfile(preprocessed_dir, [name, '_preprocessed.png']);

if ~exist(preprocessed_fname, 'file')
    PreprocessAndStoreImage(full_file_path, preprocessed_dir, scale_factor, is_negative_stain_data, 0);  % use 'full_file_path' instead of 'fullfile(inpath, fname)'
end


im = imread(preprocessed_fname);

    imageDims = size(im);
    %figure, imshow(im);
    originImage = im;
    
    % ======================== DETECT PARTICLES ===========================
    [clist centers2 particleMeans_org particleStd_org particlePatches_org] = DetectParticles(im, cnet, rbox_scale, sigma_gauss, f3, sigma_detect, mythreshold, k_level, name);
    K=size(clist, 2);
    numCenters2 = size(centers2, 1);
    



    % =================== RE-TRAIN CLASSIFICATION NETWORK =================
if training == 1
        
    % --- prepare training samples ---
    if customize_pct_training == 0
        pct_mean_training = 2;
        pct_std_training = 20;
    end



  %REPIC change

  if index >= 1 && index <= num_images_train
    [patches_pos_train, patches_neg_train, mask2_pos, centers_neg2, p_array_train] = ...
    GetTrainingClassificationSamples(patches_pos_train, patches_neg_train, ...
                                    im, rbox_scale, k_level, clist, centers2, ...
                                    particleMeans_org, particleStd_org, particlePatches_org, ...
                                    pct_mean_training, pct_std_training);
elseif index > num_images_train && index <= (num_images_train + num_images_val)
    [patches_pos_val, patches_neg_val, mask2_pos, centers_neg2, p_array_train] = ...
    GetTrainingClassificationSamples(patches_pos_val, patches_neg_val, ...
                                    im, rbox_scale, k_level, clist, centers2, ...
                                    particleMeans_org, particleStd_org, particlePatches_org, ...
                                    pct_mean_training, pct_std_training);
end








    % --- Re-train the classification network ---
    if index == num_images_train + num_images_val
        disp('started training classification');

        tic2 = tic; % Start timer 2

        %num_pos = size(patches_pos, 4);
        %num_neg = size(patches_neg, 4);

        num_pos_train = size(patches_pos_train , 4);
        num_neg_train = size(patches_neg_train , 4);
        num_pos_val = size(patches_pos_val , 4);
        num_neg_val = size(patches_neg_val , 4);


        %num_class_min = min(num_pos, num_neg);
        num_class_min_train = min(num_pos_train, num_neg_train);
        num_class_min_val = min(num_pos_val, num_neg_val);

        %trainX = cat(4, patches_pos(:, :, 1, 1:num_class_min), patches_neg(:, :, 1, 1:num_class_min));
        trainX = cat(4, patches_pos_train(:, :, 1, 1:num_class_min_train), patches_neg_train(:, :, 1, 1:num_class_min_train));
        valX = cat(4, patches_pos_val(:, :, 1, 1:num_class_min_val), patches_neg_val(:, :, 1, 1:num_class_min_val));

        %trainY = zeros(2*num_class_min, 1);
        %trainY(1:num_class_min, :) = 1;
        %trainY = categorical(trainY);
        
        trainY = zeros(2*num_class_min_train, 1);
        trainY(1:num_class_min_train, :) = 1;
        trainY = categorical(trainY);
        
        valY = zeros(2*num_class_min_val, 1);
        valY(1:num_class_min_val, :) = 1;
        valY = categorical(valY);


        
        %net2 = TrainClassificationNet(trainX, trainY, num_epochs);
        net2 = TrainClassificationNet(trainX, trainY, valX, valY, num_epochs);

        save('./models/trained_cnet_2.mat', 'net2');

        disp('finished training classification');
        elapsedTime2 = toc(tic2);  % get elapsed time
        fprintf('train classification time: %.2f seconds.\n', elapsedTime2);

        training = 0;
        index = 1;
        continue
    else
        index = index + 1;
        continue
    end
end




    
    % ========================== NEXT IMAGE ===============================
    index = index + 1;
%     close all;
    
end

elapsedTime1 = toc(tic1);
fprintf('total time: %.2f seconds\n', elapsedTime1);

end



