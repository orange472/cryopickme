function GetDetectionTrainingSamples_bin(training_truth, training_folder, validation_truth, validation_folder, params_file, box_size_str)  
global box_size rbox_scale;

box_size = str2double(box_size_str);


set(0,'DefaultFigureWindowStyle','docked');
warning('off','all');
clc;


addpath('../source');
addpath('../utilities_fb');

%% SET UP PARAMETERS

[names vals inputParams]=ParseParams(params_file);

for i=1:length(names)
    if isnumeric(vals{i})
        eval([genvarname(names{i}) ' = ' num2str(vals{i}) ';']);
    else
        eval([genvarname(names{i}) ' = ' vals{i} ';']);
    end
end


[scale_factor, rbox_scale, sigma_gauss, f3] = SetScaleFactors(training_folder, box_size);



ConvertBoxesToStars(training_truth, '../trainingdata/training_stars/10057/train');

%incorporate repic coord converter here, set path better
training_truth_stars = '../trainingdata/training_stars/10057/train';


% list of training micrographs
flist_train = dir(fullfile(training_folder, '*.mrc'));


r_patch = rbox_scale;


patches = [];
images.data = [];
images.labels = [];



% Training loop
images.data = [];
images.labels = [];
patches = [];

num_prev = 0;

num_training = numel(flist_train);


for i = 1:num_training

    fname = flist_train(i).name;



preprocessed_dir1 = '../images/preprocessedimages1';
if ~exist(preprocessed_dir1, 'dir')
   mkdir(preprocessed_dir1);
end

[~, name, ~] = fileparts(fname);
preprocessed_fname1 = fullfile(preprocessed_dir1, [name, '_preprocessed1.png']);

if ~exist(preprocessed_fname1, 'file')
    PreprocessAndStoreImage(fullfile(training_folder, fname), preprocessed_dir1, scale_factor, is_negative_stain_data, 1);

end

im = imread(preprocessed_fname1);



    dims = size(im);


     cname = [fname(1:end-4) '.star'];
    


    try
        coordinates = ReadCoordinateStar(fullfile(training_truth_stars, cname));  %read donated data
    catch
        continue
    end


    



     coordinates2 = coordinates(:, 1:2)/scale_factor;
    
    


     % make directories if do not exist
if ~exist('./micrographplots', 'dir')
   mkdir('./micrographplots');
end

if ~exist('./micrographplots/truth', 'dir')
   mkdir('./micrographplots/truth');
end

if ~exist('./micrographplots/binary', 'dir')
   mkdir('./micrographplots/binary');
end




    rgb = im;
    numCenters = size(coordinates,1);
    rgb = insertShape(rgb,'Circle',[coordinates2, repmat(rbox_scale, numCenters, 1)],'LineWidth', 3, 'Color', 'Y'); % Already bin 3
%     regcoor2 = [(coordinates2(:,1)-r) (coordinates2(:,2)-r) repmat(2*r, [numCenters 1]) repmat(2*r, [numCenters 1])];
%     rgb = insertShape(rgb, 'rectangle', regcoor2, 'LineWidth', 3, 'Color', 'g');
   % figure, imshow(rgb);
   imwrite(rgb, ['./micrographplots/truth/' fname(1:end-4) '_truth.png']); % save the image with the correct name
 
    
    cim = zeros(dims);
    cim = insertShape(cim,'FilledCircle',[coordinates2, repmat(floor(rbox_scale/2), numCenters, 1)],'LineWidth', 1, 'Color', 'White'); % Already bin 3
    cim = im2bw(cim);
  %  figure, imshow(cim);
    imwrite(cim, ['./micrographplots/binary/' fname(1:end-4) '_binary.png']); % save the image with the correct name

     
    cim(:,:,1)=imagerange(cim(:,:,1));
%     cim(:,:,2)=imagerange(cim(:,:,2));
%     cim(:,:,3)=uint8(zeros(size(im,1),size(im,1)));

    [rows,cols,channels] = size(im);
    mask_centers = zeros(rows,cols);
    
    R=cim(:,:,1);
    L=bwlabel(double(R));
    stat=regionprops(L,'Centroid');
    xy=[stat.Centroid];
    n=length(xy);
    x=xy(1:2:end);
    y=xy(2:2:end);
    
    ind = sub2ind(size(mask_centers),y,x);
    if (sum(ind<1)>0)
        ind
    end
    mask_centers(round(ind))=1;
    
    
    circles = [x' y' repmat(floor(rbox_scale/3), n/2, 1)];
    mask_centers2 = insertShape(mask_centers, 'FilledCircle',  circles, 'LineWidth', 2);
    mask_centers3 = im2bw(mask_centers2, 0.5);
%     figure, imshow(mask_centers3);
    
    %----distance to the center
    d_center=bwdist(mask_centers3);
%     figure, imshow(d_center, []);

    %----distance to boundary
    cells=d_center<floor(rbox_scale/3);
    d_border=bwdist(1-cells);
    K=d_border.^2;
%     figure, imshow(K, []);
%     figure, mesh(K);
%     colormap jet;
   
%     rgb=markcontours(im,mask_centers,[0 1 0]);
%     rgb=markcontours(rgb,cells,[0 0 1],[0.5 0.5]);
    

    GT_NEW=cropsquare_up(K,y,x,r_patch);
    original_image=cropsquare_up(im,y,x,r_patch);
    
    
%      mask=d<rad;
    %[~, imgnameOR]=fileparts(file_list(i).name);
    [~, imgnameOR]=fileparts(flist_train(i).name);

%     [~, imgnameGT]=fileparts(Flist2(i).name);
    imgnameGT = imgnameOR;
    
    num_patches = size(GT_NEW,4);

    
%     patch_names = cell(num_patches, 1);
%     patch_names = [];

   num_prev = size(patches, 2);


    for k=1:num_patches

         image_name1 = [imgnameGT '_' int2str(k) '.png'];
    imwrite(uint8(GT_NEW(:,:,:,k)),['GT_bin/train/' image_name1]);
    
    image_name2 = [imgnameOR '_' int2str(k) '.png'];
    imwrite(uint8(original_image(:,:,:,k)),['OR_bin/train/' image_name2]);



%         patch_names(k) = {image_name2};
%         patch_names(k) = image_name2;
        patches(num_prev + k).names = image_name2;
    end
    
     
     images.data = cat(4, images.data, original_image);
     images.labels = cat(4, images.labels, GT_NEW);
%      images.names = cat(2, images.names, patches.names);

     
     
%      figure, imshow(original_image(:, :, :, 41), []);
%      figure, imshow(GT_NEW(:, :, :, 41), []);
%      
%      figure, imshow(original_image(:, :, :, 66), []);
%      figure, imshow(GT_NEW(:, :, :, 66), []);
     
%      figure, imshow(original_image(:, :, :, end), []);
%      figure, imshow(GT_NEW(:, :, :, end), []);
     
     disp([fname '  ' num2str(i)]);
    

end





disp('training set processed');

save('TRPV_32_64_bin_train.mat', 'images', 'patches', '-v7.3'); % Save training data











ConvertBoxesToStars(validation_truth, '../trainingdata/training_stars/10057/val');

validation_truth_stars = '../trainingdata/training_stars/10057/val';


flist_val= dir(fullfile(validation_folder, '*.mrc'));
num_validation = numel(flist_val);

images.data = [];
images.labels = [];
patches = [];

num_prev = 0;


for i = 1:num_validation
    fname = flist_val(i).name;
    
    preprocessed_dir1 = '../images/preprocessedimages1';
    if ~exist(preprocessed_dir1, 'dir')
        mkdir(preprocessed_dir1);
    end
    
    [~, name, ~] = fileparts(fname);
    preprocessed_fname1 = fullfile(preprocessed_dir1, [name, '_preprocessed1.png']);
    
    if ~exist(preprocessed_fname1, 'file')
        PreprocessAndStoreImage(fullfile(validation_folder, fname), preprocessed_dir1, scale_factor, is_negative_stain_data, 1);
    end
    
    im = imread(preprocessed_fname1);
    
    dims = size(im);



    
    
    cname = [fname(1:end-4) '.star'];
    try
        coordinates = ReadCoordinateStar(fullfile(validation_truth_stars, cname));

    catch
        continue
    end
    






    coordinates2 = coordinates(:, 1:2)/scale_factor;
    
    rgb = im;
    numCenters = size(coordinates,1);
    rgb = insertShape(rgb,'Circle',[coordinates2, repmat(rbox_scale, numCenters, 1)],'LineWidth', 3, 'Color', 'Y');
    
    imwrite(rgb, ['./micrographplots/truth/' fname(1:end-4) '_truth.png']);
    
    cim = zeros(dims);
    cim = insertShape(cim,'FilledCircle',[coordinates2, repmat(floor(rbox_scale/2), numCenters, 1)],'LineWidth', 1, 'Color', 'White');
    cim = im2bw(cim);
    imwrite(cim, ['./micrographplots/binary/' fname(1:end-4) '_binary.png']);
    
    cim(:,:,1)=imagerange(cim(:,:,1));
    
    [rows,cols,channels] = size(im);
    mask_centers = zeros(rows,cols);
    
    R=cim(:,:,1);
    L=bwlabel(double(R));
    stat=regionprops(L,'Centroid');
    xy=[stat.Centroid];
    n=length(xy);
    x=xy(1:2:end);
    y=xy(2:2:end);
    
    ind = sub2ind(size(mask_centers),y,x);
    if (sum(ind<1)>0)
        ind
    end
    mask_centers(round(ind))=1;
    
    circles = [x' y' repmat(floor(rbox_scale/3), n/2, 1)];
    mask_centers2 = insertShape(mask_centers, 'FilledCircle',  circles, 'LineWidth', 2);
    mask_centers3 = im2bw(mask_centers2, 0.5);
    
    d_center=bwdist(mask_centers3);
    cells=d_center<floor(rbox_scale/3);
    d_border=bwdist(1-cells);
    K=d_border.^2;
    
    GT_NEW=cropsquare_up(K,y,x,r_patch);
    original_image=cropsquare_up(im,y,x,r_patch);
    
    [~, imgnameOR]=fileparts(flist_val(i).name);
    imgnameGT = imgnameOR;
    
    num_patches = size(GT_NEW,4);
    num_prev = size(patches, 2);
    
    for k=1:num_patches
        image_name1 = [imgnameGT '_' int2str(num_prev + k) '.png'];
        imwrite(uint8(GT_NEW(:,:,:,k)),['GT_bin/validation/' image_name1]);
        
        image_name2 = [imgnameOR '_' int2str(num_prev + k) '.png'];
        imwrite(uint8(original_image(:,:,:,k)),['OR_bin/validation/' image_name2]);
        
        patches(num_prev + k).names = image_name2;
    end
    
    images.data = cat(4, images.data, original_image);
    images.labels = cat(4, images.labels, GT_NEW);
    
    disp([fname '  ' num2str(i)]);
end

disp('validation set processed');

save('TRPV_32_64_bin_val.mat', 'images', 'patches', '-v7.3'); % Save validation data





%% ======= SAVE CNN Training Files
%  save TRPV_32_64_star.mat images -v7.3; %to save file larger than 2GB
%  save TRPV_32_64_star.mat patches -v7.3; %to save file larger than 2GB

%save('TRPV_32_64_bin.mat', 'images', 'patches', '-v7.3');


end