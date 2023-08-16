%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Program Name: DRPnet Particle Picking
%
%  Filename: ReadCoordinateStar.m
%
%  Description: Read coordinates of particles from DAT file
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

function csvarray = ReadCoordinateTRPV(filename)

fileID = fopen(filename,'r');

formatSpec = '%d %d %d %d';
sizeA = [4 Inf];
A = fscanf(fileID,formatSpec,sizeA);
csvarray = A';

fclose(fileID);

end