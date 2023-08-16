%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Program Name: DRPnet Particle Picking
%
%  Filename: GetTrainingClassificationSamples.m
%
%  Description: Prepare training sample for classification network (CNN-2)
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


function [patches_pos patches_neg mask2_pos centers_neg2 p_array_train] = GetTrainingClassificationSamples(patches_pos, patches_neg, im, rbox_scale, k_level, clist, centers2, particleMeans_org, particleStd_org, particlePatches_org, pct_mean_training, pct_std_training);

imageDims = size(im);
originImage = im;

rpad = rbox_scale/4;

pm_pos_low = prctile(particleMeans_org, pct_mean_training);
pm_pos_high = prctile(particleMeans_org, 100-0);
ps_pos_low = prctile(particleStd_org, pct_std_training);
ps_pos_high = prctile(particleStd_org, 100-0);

p_array_train = [pm_pos_low pm_pos_high ps_pos_low ps_pos_high];

% ----------- Postive samples -------------------

filterList_pos = (particleMeans_org > pm_pos_low) & (particleMeans_org < pm_pos_high) & (particleStd_org > ps_pos_low) & (particleStd_org < ps_pos_high);
% num_pos_mic = sum(filterList_pos);
% centers_pos = centers2(filterList_pos, :);
% mask2_pos = filterList_pos;

if k_level == 1
    centers_k2 = clist(2).centers; 
    [idx, dist] = rangesearch(centers2, centers_k2, rbox_scale/4);
    idmask_pos = zeros(size(centers2, 1), 1);
    for j = 1:length(idx)
        idmask_pos(idx{j}) = 1;
    end
    mask2_pos = filterList_pos & idmask_pos;
else
    mask2_pos = filterList_pos;
end

num_pos_mic = sum(mask2_pos);
centers_pos = centers2(mask2_pos, :);

patches_pos_mic = zeros(2*rbox_scale, 2*rbox_scale, 1, num_pos_mic);
patches_pos_mic(:, :, 1, :) = particlePatches_org(:, :, mask2_pos);
patches_pos = cat(4, patches_pos, patches_pos_mic);
% figure, imshow(patches_pos(:, :, 1, 1), []);

% figure(mrcFig);
% for j = 1:numCenters2
%     if (filterList_pos(j) == 0)
%         text(centers2(j,1), centers2(j,2), sprintf('%d', j), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'red');
%     else
%         text(centers2(j,1), centers2(j,2), sprintf('%d', j), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'blue');
%     end
% end


% ------------ Negative samples -----------------
centers_k1 = clist(1).centers;
% centers_k3 = clist(3).centers;

% [idx, dist] = rangesearch(centers_k1, centers2, rbox_scale/2);
[idx, dist] = rangesearch(centers_k1, centers_pos, rbox_scale/3);
idmask_neg = zeros(size(centers_k1, 1), 1);
for j = 1:length(idx)
    idmask_neg(idx{j}) = 1;
end

centers_neg = centers_k1(idmask_neg == 0, :);
% centers_neg = setdiff(centers_k1 , centers_k3,  'rows');
% hold on;
% plot(centers_neg(:,1), centers_neg(:,2), 'o', 'Color', 'green', 'LineWidth', linew/2, 'MarkerSize', rbox_scale/2);
% plot(centers_k3(:,1), centers_k3(:,2), 'o', 'Color', 'blue', 'LineWidth', linew/2, 'MarkerSize', rbox_scale/2);


rec_neg = round([(centers_neg(:,2)-rbox_scale) (centers_neg(:,1)-rbox_scale) (centers_neg(:,2)+rbox_scale-1) (centers_neg(:,1)+rbox_scale-1)]); % need to check outside 4 corner points
filterList_bound_k1 = (rec_neg(:,1)-rpad >=1 & rec_neg(:,2)-rpad >= 1 & rec_neg(:,3)+rpad <= imageDims(1) & rec_neg(:,4)+rpad <= imageDims(2));
rec_neg2 = rec_neg(filterList_bound_k1, :);
centers_neg2 = centers_neg(filterList_bound_k1, :);


num_neg_mic = size(centers_neg2, 1);
patches_neg_mic = zeros(2*rbox_scale, 2*rbox_scale, 1, num_neg_mic);

for j = 1:num_neg_mic
    % text(rec_neg2(j,2)+rbox_scale,rec_neg2(j,1)+rbox_scale, sprintf('%d', j), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'cyan');
    tempParticle_neg = originImage(rec_neg2(j,1):rec_neg2(j,3), rec_neg2(j,2):rec_neg2(j,4));
    patches_neg_mic(:, :, 1, j) = tempParticle_neg;
end

patches_neg = cat(4, patches_neg, patches_neg_mic);

end