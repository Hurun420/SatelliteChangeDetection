function [alignedImages, transformParams] = register_images(folderPath, imageList)
% REGISTER_IMAGES robustly aligns a sequence of satellite images using Harris + SURF + RANSAC,
% and saves the aligned images, visual comparisons, and correspondence data.

% Output folders
outputImageFolder = 'output/match_figures';
outputMatFolder = 'output/match_data';
if ~exist(outputImageFolder, 'dir'), mkdir(outputImageFolder); end
if ~exist(outputMatFolder, 'dir'), mkdir(outputMatFolder); end

% Initialize
numImages = length(imageList);
alignedImages = cell(1, numImages);
transformParams = cell(1, numImages);

% Load reference image (first image)
refImage = imread(fullfile(folderPath, imageList{1}));
refGray = im2gray(refImage);
alignedImages{1} = refGray;
transformParams{1} = affine2d(eye(3));

% Detect Harris features in reference
pts_ref = detectHarrisFeatures(refGray);

fprintf("\n⚙️ Registering %d images\n", numImages);

for i = 2:numImages
    currName = imageList{i};
    currPath = fullfile(folderPath, currName);
    img = imread(currPath);
    imgGray = im2gray(img);
    pts_img = detectHarrisFeatures(imgGray);

    fprintf("\n⚙️ Registering image %d / %d: %s\n", i, numImages, currName);
    fprintf("🔧 Harris: %d points in reference | %d in current.\n", ...
        pts_ref.Count, pts_img.Count);

    % Match using SURF descriptors
    [cor, matchedCount] = match_features_cv(refGray, imgGray, pts_ref.Location', pts_img.Location');
    fprintf("🔍 Matched %d SURF feature pairs.\n", matchedCount);

    if matchedCount >= 10
        try
            % === Robust estimation using RANSAC ===
            [tform, inlierIdx] = estimateGeometricTransform2D( ...
                cor(3:4,:)', cor(1:2,:)', 'affine', ...
                'MaxNumTrials', 2000, 'Confidence', 99.9, 'MaxDistance', 3);

            cor = cor(:, inlierIdx);  % Keep inliers only
            refFrame = imref2d(size(refGray));

            % Warp image
            registered = imwarp(imgGray, tform, ...
                'OutputView', refFrame, 'FillValues', 0);

            % Save result
            alignedImages{i} = registered;
            transformParams{i} = tform;

            % Save visuals
            save_registration_outputs(refGray, imgGray, registered, cor, currName, outputImageFolder, outputMatFolder);

            fprintf("✅ Aligned image %d / %d successfully.\n", i, numImages);
        catch ME
            warning("❌ Failed to estimate transform for %s: %s", currName, ME.message);
            alignedImages{i} = [];
            transformParams{i} = [];
        end
    else
        warning("⚠️ Not enough matches for image %s. Skipping.", currName);
        alignedImages{i} = [];
        transformParams{i} = [];
    end
end
end
