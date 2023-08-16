%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Program Name: DRPnet Particle Picking
%
%  Filename: DetectParticles.m
%
%  Description: Detect particles in a preprocessed image.
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

function [clist, centers2 particleMeans_org particleStd_org particlePatches_org] = DetectParticles(im, cnet, rbox_scale, sigma_gauss, f3, sigma, threshold, k_level, name)






   % ================= DETECT PARTICLES ====================
    imageDims = size(im);
    originImage = im;
   
    I2 = im2double(im);
    I2 = imgaussfilt(I2, sigma_gauss);
    
    if f3 == 1
        fout_DL = activations(cnet, I2, 'conv_5', 'OutputAs', 'channels');
    else
        fout_DL = activations(cnet, imresize(I2, 1/f3), 'conv_5', 'OutputAs', 'channels');
        fout_DL = imresize(fout_DL, f3);
    end
    
        % Create the new directory path
    filtered_dir = 'images/filtered';

    % Check if directory exists, if not, make directory
    if ~exist(filtered_dir, 'dir')
        mkdir(filtered_dir);
    end



filtered_path = fullfile(filtered_dir, [name, '_filtered.png']);
imwrite(fout_DL, filtered_path);  % Use imwrite to save the image directly




    % colormap gray;
    % f12 = figure, imshow(fout_DL, [], 'colormap', jet);
    % colorbar;
    % f13 = figure, mesh(fout_DL);
    
    fout_DL2 = fout_DL / max(fout_DL(:)); % will be thresholded after writing down
    fout_DL2 = uint8(fout_DL2 * 255);
    out_DL = fout_DL2;
    out_DL = imgaussfilt(fout_DL2, 2);
    % figure, imshow(out_DL);
    % figure, imshow(out_DL, 'colormap', jet);
    % figure, mesh(out_DL);
    
    
    
    [clist,peaks]=DLout2centers3(out_DL, sigma, threshold);
    K=size(peaks,3);
    centers=clist(k_level).centers;

    
    % ================== Extract particles' boxes, Remove points near borders =============
    tempBoxes = round([(centers(:,2)-rbox_scale) (centers(:,1)-rbox_scale) (centers(:,2)+rbox_scale-1) (centers(:,1)+rbox_scale-1)]); % need to check outside 4 corner points
    rpad = rbox_scale/2;
    filterList_bound = tempBoxes(:,1)-rpad >=1 & tempBoxes(:,2)-rpad >= 1 & tempBoxes(:,3)+rpad <= imageDims(1) & tempBoxes(:,4)+rpad <= imageDims(2);
    imageParticleBoxes2 = tempBoxes(filterList_bound, :);
    centers2 = centers(filterList_bound, :);
    
    
    numCenters2 = size(imageParticleBoxes2, 1);
    particleMeans = zeros(numCenters2, 1);
    particleStd = zeros(numCenters2, 1);
    particleMeans_org = zeros(numCenters2, 1);
    particleStd_org = zeros(numCenters2, 1);
    
    particlePatches = zeros(2*rbox_scale, 2*rbox_scale, []);
    particlePatches_org = zeros(2*rbox_scale, 2*rbox_scale, []);
    
    
    
    % ==================== Extract particles' patches ==================
    for j = 1:numCenters2
        tempParticle = out_DL(imageParticleBoxes2(j,1):imageParticleBoxes2(j,3), imageParticleBoxes2(j,2):imageParticleBoxes2(j,4));
        tempParticle_org = originImage(imageParticleBoxes2(j,1):imageParticleBoxes2(j,3), imageParticleBoxes2(j,2):imageParticleBoxes2(j,4));
        
        % Apply filter
        % h = fspecial('average', round(rbox_scale/3));
        % tempParticle2 = uint8(filter2(h, tempParticle, 'same'));
        tempParticle2 = tempParticle;
        particleMeans(j) = mean(tempParticle2(:));
        particleStd(j) = std(double(tempParticle2(:)));
                        
%         tempParticle2_org = imgaussfilt(tempParticle_org, rbox_scale/4);
        tempParticle2_org = tempParticle_org;
        
        particleMeans_org(j) = mean(tempParticle2_org(:));
        particleStd_org(j) = std(double(tempParticle2_org(:)));
        
        
        if sum(size( tempParticle2)) == 2*(2*rbox_scale)
            particlePatches(:, :, j) = tempParticle2;
            particlePatches_org(:, :, j) = tempParticle2_org;
        else
            particlePatches(1:size(tempParticle2,1), 1:size(tempParticle2,2), j) = tempParticle2;
            particlePatches_org(1:size(tempParticle2,1), 1:size(tempParticle2,2), j) = tempParticle2_org;
        end
        
    end   
    
    
    
end