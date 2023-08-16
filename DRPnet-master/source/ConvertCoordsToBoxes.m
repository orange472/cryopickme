function ConvertCoordsToBoxes(coordFolder, boxFolder, boxSize)
    coordFiles = dir(fullfile(coordFolder, '*.coord'));

    for i = 1:numel(coordFiles)
        coordFile = fullfile(coordFolder, coordFiles(i).name);
        
        [~, coordFileName, ~] = fileparts(coordFile);
        boxFile = fullfile(boxFolder, [coordFileName '.box']);
        
        ConvertCoordToBox(coordFile, boxFile, boxSize);
    end
end

function ConvertCoordToBox(coordFile, boxFile, boxSize)
    coordData = importdata(coordFile);
        coordinates = round(coordData);
        boxData = [coordinates, repmat(boxSize, size(coordinates, 1), 2)];
        dlmwrite(boxFile, boxData, 'delimiter', '\t', 'precision', 6);
end