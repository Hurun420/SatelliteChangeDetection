clc; clear;

% 设置数据文件夹
imageFolder = fullfile('Data', 'Frauenkirche');  % 可改为任意文件夹

% 执行配准
batch_register_satellite(imageFolder);

% 显示一组对比图
figure;
img = imread(fullfile(imageFolder, 'output', 'comparison', 'compare_2015_08.png'));
imshow(img);
title('Reference vs Registered Image');
