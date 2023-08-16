function ConvertBoxesToStars(boxFolder, starFolder)
    if ~exist(starFolder, 'dir')
        mkdir(starFolder);
    end

    % get a list of all files and directories 
    items = dir(boxFolder);

    % loop through
    for i = 1:numel(items)
        % if this item is a directory, process it recursively
        if items(i).isdir
            if ~strcmp(items(i).name, '.') && ~strcmp(items(i).name, '..')
                % create the corresponding subdirectory in starFolder
                newStarFolder = fullfile(starFolder, items(i).name);
                if ~exist(newStarFolder, 'dir')
                    mkdir(newStarFolder);
                end

                % process the subdirectory
                newBoxFolder = fullfile(boxFolder, items(i).name);
                ConvertBoxesToStars(newBoxFolder, newStarFolder);
            end
        % if this item is a box file, convert it to a star file
        elseif ~isempty(regexp(items(i).name, '\.box$', 'once'))
            % get the current box file name
            boxFile = fullfile(boxFolder, items(i).name);

            % make star file name
            [~, boxFileName, ~] = fileparts(boxFile);
            starFile = fullfile(starFolder, [boxFileName '.star']);

            % convert box file to star file
            ConvertBoxToStar(boxFile, starFile);
        end
    end
end

function ConvertBoxToStar(boxFile, starFile)
    % read box
    boxData = dlmread(boxFile, '\t');

    % convert data 
    starData = [boxData(:, 1) boxData(:, 2)];

    % write to star file
    starFileID = fopen(starFile, 'w');
    fprintf(starFileID, 'data_\n');
    fprintf(starFileID, '\n');
    fprintf(starFileID, 'loop_\n');
    fprintf(starFileID, '_rlnCoordinateX #1\n');
    fprintf(starFileID, '_rlnCoordinateY #2\n');
    fprintf(starFileID, '%f %f\n', starData');
    fclose(starFileID);
end
