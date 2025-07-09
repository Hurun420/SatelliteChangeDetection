function [alignedImages, transformParams] = register_images(folderPath, imageList)
% REGISTER_IMAGES: Aligns images using Harris and SURF features
% and saves outputs (.png and .mat) in designated folders.

% Default output folders
outputImageFolder = 'output/match_figures';
outputMatFolder = 'output/match_data';

% Create directories if not exist
if ~exist(outputImageFolder, 'dir')
    mkdir(outputImageFolder);
end
if ~exist(outputMatFolder, 'dir')
    mkdir(outputMatFolder);
end

% Initialization
numImages = length(imageList);
alignedImages = cell(1, numImages);
transformParams = cell(1, numImages);

% Load and convert the reference image
refImage = imread(fullfile(folderPath, imageList{1}));
refGray = im2gray(refImage);
alignedImages{1} = refGray;
transformParams{1} = affine2d(eye(3));

% Harris keypoints for reference
pts_ref = detectHarrisFeatures(refGray);

fprintf("\n Registering %d images\n", numImages);

for i = 2:numImages
    currName = imageList{i};
    currPath = fullfile(folderPath, currName);
    img = imread(currPath);
    imgGray = im2gray(img);

    % Harris keypoints for current image
    pts_img = detectHarrisFeatures(imgGray);
    fprintf("\n Registering image %d / %d: %s\n", i, numImages, currName);
    fprintf("Harris: %d points in reference | %d in current.\n", pts_ref.Count, pts_img.Count);

    % SURF-based matching (Computer Vision Toolbox)
    [cor, matchedCount] = match_features_cv(refGray, imgGray, pts_ref.Location', pts_img.Location');
    fprintf("Matched %d SURF feature pairs.\n", matchedCount);

    % Estimate transformation
    if matchedCount >= 3
        tform = fitgeotrans(cor(3:4,:)', cor(1:2,:)', 'affine');
        registered = imwarp(imgGray, tform, 'OutputView', imref2d(size(refGray)));
        alignedImages{i} = registered;
        transformParams{i} = tform;

        % Save visual overlay (colored matches)
        saveName = sprintf('%s_matches.png', currName(1:end-4));
        savePath = fullfile(outputImageFolder, saveName);
        plot_matches(refGray, imgGray, cor(1:2,:), cor(3:4,:), savePath);

        % Save .mat with point correspondences
        matName = sprintf('%s_points.mat', currName(1:end-4));
        save(fullfile(outputMatFolder, matName), 'cor');

        fprintf("Aligned image %d / %d successfully.\n", i, numImages);
    else
        warning("Not enough matches to estimate transform for image %s", currName);
        alignedImages{i} = imgGray;
        transformParams{i} = affine2d(eye(3));
    end
end
end
