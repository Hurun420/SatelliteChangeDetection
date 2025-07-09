%% test_register.m
clc; clear

% Input image folder
imageFolder = 'Data/Columbia Glacier';

% 获取图像文件列表
imageFiles = dir(fullfile(imageFolder, '*.jpg'));
if isempty(imageFiles)
    error('No .jpg images found in %s. Please check the folder path or file extensions.', imageFolder);
end
imageList = {imageFiles.name};

% 调用 register_images（无多余参数）
[alignedImages, transformParams] = register_images(imageFolder, imageList);

disp('All images registered successfully!');
