function ConvertStarsToBoxes(starFolder, boxFolder, boxSize)
    % get a list of all files and directories 
    items = dir(starFolder);

    % loop through
    for i = 1:numel(items)
        % if this item is a directory, process it recursively
        if items(i).isdir
            if ~strcmp(items(i).name, '.') && ~strcmp(items(i).name, '..')
                % create the corresponding subdirectory in boxFolder
                newBoxFolder = fullfile(boxFolder, items(i).name);
                if ~exist(newBoxFolder, 'dir')
                    mkdir(newBoxFolder);
                end

                % process the subdirectory
                newStarFolder = fullfile(starFolder, items(i).name);
                ConvertStarsToBoxes(newStarFolder, newBoxFolder, boxSize);
            end
        % if this item is a star file, convert it to a box file
        elseif ~isempty(regexp(items(i).name, '\.star$', 'once'))
            % get the current star file name
            starFile = fullfile(starFolder, items(i).name);

            % make box file name
            [~, starFileName, ~] = fileparts(starFile);
            boxFile = fullfile(boxFolder, [starFileName '.box']);

            % convert star file to box file
            ConvertStarToBox(starFile, boxFile, boxSize);
        end
    end
end

function ConvertStarToBox(starFile, boxFile, boxSize)
    % read the star file
    starData = importdata(starFile);

    % extract X,Y coords
    coordinates = round(starData.data(:, 1:2));

 %%%%%%%%%   % create the box data with X, Y, width, and height columns
  %%%%%%%%%  boxData = [coordinates, repmat(boxSize, size(coordinates, 1), 2)];
%%%temporarily add in fake weights

    % create the box data with X, Y, width, height columns and a default fifth column of 0.8
    boxData = [coordinates, repmat(boxSize, size(coordinates, 1), 2), repmat(0.8, size(coordinates, 1), 1)];


    % write the box data to the box file
    dlmwrite(boxFile, boxData, 'delimiter', '\t', 'precision', 6);
end

