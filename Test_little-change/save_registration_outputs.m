function save_registration_outputs(imageList, alignedGray, alignedRGB, transformParams, folderPath)
% SAVE_REGISTRATION_OUTPUTS
% Saves registration results into subfolders named after the input folder.
%
% Inputs:
%   imageList: list of original filenames (sorted)
%   alignedGray: cell array of grayscale registered images
%   alignedRGB:  cell array of RGB registered images
%   transformParams: cell array of geometric transforms
%   folderPath: original image folder (used for naming subfolder)

    % Extract location name from folderPath (e.g., 'Brazilian Rainforest')
    [~, locationName] = fileparts(folderPath);

    % Define output subfolders
    outputFolder = 'output';
    grayFolder = fullfile(outputFolder, 'aligned_gray', locationName);
    rgbFolder  = fullfile(outputFolder, 'aligned_rgb', locationName);
    matFolder  = fullfile(outputFolder, 'aligned_mat', locationName);
    compFolder = fullfile(outputFolder, 'comparison', locationName);

    % Create output folders if not exist
    if ~exist(grayFolder, 'dir'), mkdir(grayFolder); end
    if ~exist(rgbFolder,  'dir'), mkdir(rgbFolder);  end
    if ~exist(matFolder,  'dir'), mkdir(matFolder);  end
    if ~exist(compFolder, 'dir'), mkdir(compFolder); end

    % Prepare name count map
    nameCount = containers.Map();

    for i = 1:numel(imageList)
        % Extract timestamp (e.g., "2015" or "2015_08") from filename
        match = regexp(imageList{i}, '\d{4}_?\d{0,2}', 'match', 'once');
        if isempty(match)
            [~, baseName, ~] = fileparts(imageList{i});
            name = baseName;
        else
            name = match;
        end

        % Add numeric suffix if duplicate
        if isKey(nameCount, name)
            count = nameCount(name) + 1;
            nameCount(name) = count;
            name = sprintf('%s_%d', name, count);
        else
            nameCount(name) = 1;
        end

        % Save grayscale image
        imwrite(alignedGray{i}, fullfile(grayFolder, [name '.png']));

        % Save RGB image
        imwrite(alignedRGB{i}, fullfile(rgbFolder, [name '.png']));

        % Save transformation matrix
        tform = transformParams{i};
        save(fullfile(matFolder, [name '_tform.mat']), 'tform');

        % Save visualization: false-color overlay
        if i > 1 && ~isempty(tform)
            comp = imfuse(alignedGray{1}, alignedGray{i}, ...
                          'falsecolor', 'Scaling', 'independent', ...
                          'ColorChannels', [1 2 0]);
            imwrite(comp, fullfile(compFolder, [name '_comparison.png']));
        end
    end
end