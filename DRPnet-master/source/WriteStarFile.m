%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Program Name: DRPnet Particle Picking
%
%  Filename: WriteStarFile.m
%
%  Description: Write coordinates of particles to star file
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

function WriteStarFile(sourceFile, targetDir, coordinates, suf, scale_factor)

% Multiply the coordinates by a factor of 3
scaled_coordinates = coordinates * scale_factor;


%if suf == 'auto'
 %   suffix = '_autopick';
%else
%    suffix = '_manual';
%end

[file_path, file_name, ext] = fileparts(sourceFile);
%file_name = [file_name suffix '.star'];
file_name = [file_name '.star'];

fullStarName = fullfile(targetDir, file_name);
starFile = fopen(fullStarName, 'w');

fprintf(starFile, '\n');
fprintf(starFile, 'data_\n');
fprintf(starFile, '\n');
fprintf(starFile, 'loop_\n');
fprintf(starFile, '_rlnCoordinateX #1\n');
fprintf(starFile, '_rlnCoordinateY #2\n');
fprintf(starFile, '%5.6f %5.6f\n', scaled_coordinates');

fclose(starFile);
clear starFile;


end