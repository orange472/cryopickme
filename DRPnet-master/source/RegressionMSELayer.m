%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Program Name: DRPnet Particle Picking
%
%  Filename: RegressionMSELayer.m
%
%  Description: Create regression layer (the last layer) of FCRN (CNN-1)
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

classdef RegressionMSELayer < nnet.layer.RegressionLayer
               
    methods
        
        function layer = RegressionMSELayer(name)
            % Create an RegressionMSELayer

            % Set layer name
            if nargin == 1
                layer.Name = name;
            end

            % Set layer description
            layer.Description = 'Regression layer with MSE loss';
        end
        
        function loss = forwardLoss(layer, Y, T)
            % Returns the MSE loss between the predictions Y and the training targets T      
            dims = size(Y);
            vol = dims(1) * dims(2) * dims(4);
            
            delta = Y - T ;
            ssDelta = sum(delta(:).^2) ;
            loss = ssDelta / vol  ;  % normalize by image size and batch size 
        end
        
        function dLdY = backwardLoss(layer, Y, T)
            % Returns the derivatives of the MSE loss with respect to the predictions Y   
            dims = size(Y);
            vol = dims(1) * dims(2) * dims(4);
            
            df = 2 * (Y - T);
            dLdY = df / vol;  % normalize by image size and batch size
        end
        
    end
    
end



