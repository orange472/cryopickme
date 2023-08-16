%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Program Name: DRPnet Particle Picking
%
%  Filename: ClassifyPrediction.m
%
%  Description: Classify detected particles from CNN-1
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


function  [mask2 prob filterList_screen p_array_test] = ClassifyPrediction(net_test, class_cutoff, centers2, particleMeans_org, particleStd_org, particlePatches_org, filter_particle, pct_mean_predict, pct_std_predict);


pm_low = prctile(particleMeans_org, pct_mean_predict);
pm_high = prctile(particleMeans_org, 100-0);
ps_low = prctile(particleStd_org, pct_std_predict);
ps_high = prctile(particleStd_org, 100-0);

%     if customize_pct_predict == 0
%         pct_mean_predict = 1;
%         pct_std_predict = 10;
%         pm_low = prctile(particleMeans_org, pct_mean_predict);
%         pm_high = prctile(particleMeans_org, 100-0);
%         ps_low = prctile(particleStd_org, pct_std_predict);
%         ps_high = prctile(particleStd_org, 100-0);
%
%     else
%         if exist('pm_low_fix') == 1
%             pm_low = pm_low_fix;
%         else
%             pm_low = prctile(particleMeans_org, pct_mean_predict);
%         end
%
%         if exist('pm_high_fix') == 1
%             pm_high = pm_high_fix;
%         else
%             pm_high = prctile(particleMeans_org, 100-0);
%         end
%
%         if exist('ps_low_fix') == 1
%             ps_low = ps_low_fix;
%         else
%             ps_low = prctile(particleStd_org, pct_std_predict);
%         end
%
%         if exist('ps_high_fix') == 1
%             ps_high = ps_high_fix;
%         else
%             ps_high = prctile(particleStd_org, 100-0);
%         end
%
%     end

if filter_particle == 1
    filterList_screen = (particleMeans_org > pm_low) & (particleMeans_org < pm_high) & (particleStd_org > ps_low) & (particleStd_org < ps_high);
else
    filterList_screen = ones(size(centers2, 1), 1);
end

%             centers3_std = centers2(filterList_screen, :);
%             imageParticleBoxes3_std = imageParticleBoxes2(filterList_screen, :);
%             particlePatches_org3 =  particlePatches_org(:, :, filterList_screen);
%             centers3 = centers3_std;
%             imageParticleBoxes3 = imageParticleBoxes3_std;


%  particlePatches3 = particlePatches;
particleCount = size(centers2, 1);
%     particleRec = [(centers2(:,1)-rbox_scale) (centers2(:,2)-rbox_scale) repmat(2*rbox_scale,[particleCount 1]) repmat(2*rbox_scale,[particleCount 1])];

prob = zeros(particleCount, 2);
layer = 'softmax';

for j = 1:particleCount
    
    tempParticle = particlePatches_org(:,:,j);
    tempParticle2 = imresize(tempParticle, [64 64]);
    prob(j, :) =  activations(net_test, tempParticle2, layer);
    
end

%  mask = (prob(:, 1) <= prob(:, 2));
mask = (prob(:, 1) < prob(:, 2)) | (prob(:, 1) < class_cutoff);
mask2 = mask & filterList_screen;


p_array_test = [pm_low pm_high ps_low ps_high];



end