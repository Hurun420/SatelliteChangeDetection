clc; clear;

addpath('preprocessing');

imageFolder = 'Data/Frauenkirche';
outputImageFolder = 'output/match_figures';
outputMatFolder = 'output/match_data';

if ~exist(outputImageFolder, 'dir'), mkdir(outputImageFolder); end
if ~exist(outputMatFolder, 'dir'), mkdir(outputMatFolder); end

imageFiles = dir(fullfile(imageFolder, '*.jpg'));
if isempty(imageFiles)
    error('❌ No .jpg images found in %s. Please check the folder path or file extensions.', imageFolder);
end
imageList = {imageFiles.name};

[alignedImages, transformParams] = register_images(imageFolder, imageList);

% 可视化首尾图像
validIdx = find(~cellfun(@isempty, alignedImages));
if numel(validIdx) >= 2
    first = alignedImages{validIdx(1)};
    last = alignedImages{validIdx(end)};
    figure; imshowpair(first, last); title('Overlay: First vs. Last');
end

fprintf("✔ Test finished. %d / %d images successfully aligned.\n", ...
    sum(~cellfun(@isempty, alignedImages)), numel(imageList));
disp('✅ All images registered successfully!');
