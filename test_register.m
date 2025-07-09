clc; clear;

% Set the image folder path (at the same level as preprocessing)
imageFolder = fullfile('Data', 'Columbia Glacier');

% Retrieve all image filenames and sort them in chronological order
imageFiles = dir(fullfile(imageFolder, '*.jpg'));
imageList = sort({imageFiles.name});

if isempty(imageList)
    error('× No image files found in %s. Please check the path and file naming!', imageFolder);
end

% Perform image registration (pairwise alignment)
[alignedImages, transformParams] = register_images(imageFolder, imageList);

% Display the first image
figure; imshow(alignedImages{1}, []);
title('First Aligned Image');

% Display the last image
validIdx = find(~cellfun(@isempty, alignedImages));
if length(validIdx) >= 2
    first = alignedImages{validIdx(1)};
    last = alignedImages{validIdx(end)};
    
    % Optional difference map (for debugging/display purposes)
    % show_difference(first, last, 'Difference: First vs. Last');
    
    figure; imshowpair(first, last);
    title('Overlay: First vs. Last');
end

fprintf("✔ Test finished. %d / %d images successfully aligned.\n", ...
    sum(~cellfun(@isempty, alignedImages)), length(imageList));
