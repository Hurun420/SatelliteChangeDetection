clc; clear;

% input folder path
folderPath = 'C:\Users\janja\Documents\etechnik_master\CV_CHALLENGE\Datasets\Dubai';

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

% save processed images rgb
savePath = 'C:\Users\janja\Documents\etechnik_master\CV_CHALLENGE\datasets_processed\Dubai';

if ~exist(savePath, 'dir')
    mkdir(savePath);
end

for i = 1:length(imageList)
    filename = fullfile(savePath, imageList{i});
    disp(transformParams(i));
    disp(filename);
    imwrite(alignedImagesGray{i}, filename);
end