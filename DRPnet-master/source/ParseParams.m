%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Program Name: DRPnet Particle Picking
%
%  Filename: ParseParams.m
%
%  Description: Read and compute parameters from input filel
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



function [names vals inputParams]=ParseParams(filename)
%=========================
fid=fopen(filename,'r');
names = {};
vals = [];

i = 1;

while 1
    tline = fgetl(fid);
    
    if ~ischar(tline)  
        break   
    end
    
    param=findstr(tline,'=');
    
    
    if (~isempty(param))
        Loc(1)=findstr(tline,'=');
        Loc(2)=findstr(tline,';');
        
        name=strtrim(tline(1:Loc(1)-1));
        str=strtrim(tline(Loc(1)+1:Loc(2)-1));
        [val, status] = str2num(str);
        if ~status
            val=str;
        end
        names{i} = name;
        % vals(i) = val;
        vals{i} = val;
        
        i = i + 1;
        
    end
end

fclose(fid);


% for i=1:length(names)
%     eval([genvarname(names{i}) ' = ' num2str(vals(i))]);
% end

% for i=1:length(names)
%     eval([genvarname(names{i}) ' = ' vals{i}]);
% end


for k = 1:length(names)
     CurrVarname=cell2mat(names(k));
     % CurrValue=vals(k);
     CurrValue=cell2mat(vals(k));
     inputParams.(CurrVarname)=CurrValue;
end




end