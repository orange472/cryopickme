%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Program Name: DRPnet Particle Picking
%
%  Filename: ReadCoordinateStar.m
%
%  Description: Read coordinates of particles from RELION's star file
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

function array = ReadCoordinateStar(filename)      
    fileID = fopen(filename,'r');
    A=[]; 
    while ~feof(fileID)
        try
            A=[A;str2num(fgetl(fileID))];
        catch
        end
    end
    fclose(fileID);
    array = A;
end