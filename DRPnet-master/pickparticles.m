
function pickparticles(training_folder, validation_folder, outpath, inpath, params_file, box_size_str, outofbox_str)

box_size = str2double(box_size_str);

set(0,'DefaultFigureWindowStyle','docked');
close all;

clc;

addpath('source');
warning('on', 'all');

%% SET UP PARAMETERS

tic1 = tic; % Start timer 1

%disp(params_file);
%disp(outpath);
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




outofbox = str2double(outofbox_str);

trained = 'models/trained_cnet_1.mat';
pretrained = 'models/cnet_1.mat';

outofbox = str2double(outofbox_str);

if outofbox == 1
    load(pretrained);
    disp(['Using pretrained cnet1 to pick: ' pretrained]);

else 
    load(trained);
    disp(['Using trained cnet1 to pick: ' trained]);
end




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








    % Load Trained Classification Network

if outofbox == 1
    disp('using pretrained classification network to pick');
    load ('models/cnet_2.mat');
    net_test = net;

else
    disp('using trained classification network to pick');
    load('models/trained_cnet_2.mat');
    net_test = net2;
end






index = 1;

while index <= num_images
   




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
    

    
    % ========================= CLASSIFICATION ============================




    if customize_pct_training == 0
        pct_mean_predict = 1;
        pct_std_predict = 10;
    end
    [mask2 prob filterList_screen p_array_test] = ClassifyPrediction(net_test, class_cutoff, centers2, ...
                               particleMeans_org, particleStd_org, particlePatches_org, ...
                               filter_particle, pct_mean_predict, pct_std_predict);





    
    % Classification results
    centers3 = centers2(mask2, :);
    particlePatches_org3 =  particlePatches_org(:, :, mask2);
    





% Check and create the main output folder if it doesn't exist
if ~isfolder(outpath)
    mkdir(outpath);
end

% Define the subfolders and create them if they don't exist
subfolders = ["train", "val", "test"];

for i = 1:length(subfolders)
    if ~isfolder(fullfile(outpath, subfolders(i)))
        mkdir(fullfile(outpath, subfolders(i)));
    end
end







% Extract directory and base name from outpath
[outpath_dir, outpath_base, ~] = fileparts(outpath);

% Construct the new output directory by appending 'star' to the base name
new_outpath = fullfile(outpath_dir, [outpath_base 'star']);

% Determine the type of the micrograph
if ismember(fname, flist_train_names)
    sub_folder = 'train';
elseif ismember(fname, flist_val_names)
    sub_folder = 'val';
else % Assume it's a testing file if it's not in the other lists
    sub_folder = 'test';
end

% Create the subdirectory in the new output directory, if it doesn't exist
current_new_outpath = fullfile(new_outpath, sub_folder);
if ~exist(current_new_outpath, 'dir')
    mkdir(current_new_outpath);
end

% Write output into the correct folder
WriteStarFile(fname, current_new_outpath, centers3, 'auto', scale_factor);







disp([fname ' ' num2str(index)]);



    
    
    % ========================== NEXT IMAGE ===============================
    index = index + 1;
%     close all;
    
end
store_table = struct2table(store_struct);

ConvertStarsToBoxes(new_outpath, outpath, box_size);




elapsedTime1 = toc(tic1);
fprintf('total time: %.2f seconds\n', elapsedTime1);

end



