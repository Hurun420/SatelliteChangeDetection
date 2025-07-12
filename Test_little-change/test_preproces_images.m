%% test_preprocess_images.m
clc; clear;

% Define input folder path
folderPath = 'Data/Dubai';

% Get list of .jpg images in the folder
imageFiles = dir(fullfile(folderPath, '*.jpg'));
if isempty(imageFiles)
    error('No .jpg images found in %s. Please check the folder path and file extensions.', folderPath);
end

% Extract filenames
fileNames = {imageFiles.name};

% Extract date info from filename: e.g. "3_2015.jpg" → "2015" or "2015_08"
dates = regexp(fileNames, '\d{4}_?\d{0,2}', 'match', 'once');
[~, sortIdx] = sort(dates);
imageList = fileNames(sortIdx);  % Now sorted chronologically

% Register images (grayscale + RGB)
[alignedImagesGray, alignedImagesRGB, transformParams] = register_images(folderPath, imageList);

disp('✅ All images registered successfully!');

% Loop through aligned images and visualize results
for i = 2:length(imageList)
    rawImageRGB = im2double(imread(fullfile(folderPath, imageList{i})));
    rawImageGray = rgb2gray(rawImageRGB);

    plot_preprocessing_comparison_Pol( ...
        alignedImagesGray{1}, rawImageGray, alignedImagesGray{i});

    plot_image_pair_Pol( ...
        alignedImagesRGB{1}, alignedImagesRGB{i}, ...
        'Reference RGB', sprintf('Registered RGB (%s)', imageList{i}));
end
