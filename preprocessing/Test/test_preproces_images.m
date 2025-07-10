%% test_preprocess_images.m
clc; clear;

% Define input folder path
folderPath = 'C:/Users/pol/OneDrive - TUM/SS 2025/Computer Vision/SatelliteChangeDetection/Preprocessing/Pol/GlacierToTest';

% Get list of .jpg images in the folder
imageFiles = dir(fullfile(folderPath, '*.jpg'));

% Check if any image found
if isempty(imageFiles)
    error('No .jpg images found in %s. Please check the folder path or file extensions.', folderPath);
end

% Extract filenames into a cell array
imageList = {imageFiles.name};

% Register images (grayscale + RGB)
[alignedImagesGray, alignedImagesRGB, transformParams] = register_images(folderPath, imageList);

disp('✅ All images registered successfully!');

for i = 2:length(imageList)
    
    % 📷 Load raw unaligned image (for comparison)
    rawImageRGB = im2double(imread(fullfile(folderPath, imageList{i})));
    rawImageGray = rgb2gray(rawImageRGB);

    % 🎨 Plot grayscale: reference vs raw vs aligned
    plot_preprocessing_comparison_Pol( ...
        alignedImagesGray{1}, rawImageGray, alignedImagesGray{i});

    % 🎨 Plot RGB side-by-side: reference vs aligned
    plot_image_pair_Pol( ...
        alignedImagesRGB{1}, alignedImagesRGB{i}, ...
        'Reference RGB', sprintf('Registered RGB (%s)', imageList{i}));

end


% 🖼️ Plot grayscale comparison: reference vs aligned
%plot_image_pair_Pol(alignedImagesGray{1}, alignedImagesGray{2}, 'Reference Image', 'Registered Image');

% 📷 Load the raw second image (before preprocessing) for comparison
%secondImageRaw = im2double(rgb2gray(imread(fullfile(folderPath, imageList{2}))));

% 🖼️ Plot grayscale: raw vs aligned vs reference
%plot_preprocessing_comparison_Pol(alignedImagesGray{1}, secondImageRaw, alignedImagesGray{2});

% 🖼️ Plot RGB comparison
%plot_image_pair_Pol(alignedImagesRGB{1}, alignedImagesRGB{2}, 'Reference RGB', 'Registered RGB');

% 🖼️ Plot RGB: raw vs aligned vs
