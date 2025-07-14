function [alignedImagesGray, alignedImagesRGB, transformParams, successIndices] = register_images(folderPath, imageList,maxNumTrials)
% REGISTER_IMAGES
% Registers all images in imageList (within folderPath) to the first image as reference.
%
% Inputs:
%   folderPath: string, path to the folder containing the images
%   imageList:  cell array of image file names (e.g. {'2020 01.jpg', '2023 04.jpg'})
%
% Outputs:
%   alignedImagesGray: cell array of aligned grayscale images
%   alignedImagesRGB:  cell array of aligned RGB images
%   transformParams:   cell array of geometric transform objects
%   successIndices:    indices of imageList that were successfully aligned

numImages = numel(imageList);

% Preallocate with max size
alignedImagesGray = cell(1, numImages);
alignedImagesRGB  = cell(1, numImages);
transformParams   = cell(1, numImages);
successIndices    = [];

j = 1;  % Index for successful registrations

for i = 1:numImages
    currName = imageList{i};
    currPath = fullfile(folderPath, currName);

    try
        currRGB = im2double(imread(currPath));
    catch
        warning('⚠️ Could not read image: %s. Skipping.', currName);
        continue;
    end

    currGray = rgb2gray(currRGB);
    currGrayEq = adapthisteq(currGray);

    if i == 1
        % First image is the reference
        refGrayEq = currGrayEq;
        alignedImagesGray{j} = currGrayEq;
        alignedImagesRGB{j}  = currRGB;
        transformParams{j}   = affine2d(eye(3));
        successIndices(end+1) = i;
        j = j + 1;
        continue;
    end

    % Detect SURF features
    surfpointsRef  = detectSURFFeatures(refGrayEq);
    surfpointsCurr = detectSURFFeatures(currGrayEq);

    % Select strongest features
    N = 1000;
    pointsRef  = surfpointsRef.selectStrongest(N);
    pointsCurr = surfpointsCurr.selectStrongest(N);

    [featuresRef, validPtsRef]   = extractFeatures(refGrayEq, pointsRef);
    [featuresCurr, validPtsCurr] = extractFeatures(currGrayEq, pointsCurr);

    indexPairs = matchFeatures(featuresRef, featuresCurr, ...
        'Unique', true, ...
        'MaxRatio', 1, ...
        'MatchThreshold', 99.9);

    if isempty(indexPairs)
        warning('⚠️ No matches found for %s. Skipping.', currName);
        continue;
    end

    matchedRef  = validPtsRef(indexPairs(:, 1));
    matchedCurr = validPtsCurr(indexPairs(:, 2));

    % Estimate transformation
    try
        tform = estgeotform2d(matchedCurr, matchedRef, ...
            'similarity', ...
            'MaxDistance', 5, ...
            'Confidence', 99.9, ...
            'MaxNumTrials', maxNumTrials);
    catch
        warning('⚠️  Transformation estimation failed for %s. Skipping.', currName);
        continue;
    end

    % Check transform quality
    R = tform.T(1:2, 1:2);
    scale = sqrt(sum(R(:,1).^2));
    if scale < 0.8 || scale > 1.2 || rcond(R) < 1e-6
        warning('❌ Registration rejected for %s. Scale: %.2f, rcond: %.2e', ...
            currName, scale, rcond(R));
        continue;
    end

    % Apply transformation
    outputView = imref2d(size(refGrayEq));
    alignedGray = imwarp(currGrayEq, tform, 'OutputView', outputView);
    alignedRGB  = imwarp(currRGB, tform, 'OutputView', outputView);

    % Store results
    alignedImagesGray{j} = alignedGray;
    alignedImagesRGB{j}  = alignedRGB;
    transformParams{j}   = tform;
    successIndices(end+1) = i;

    j = j + 1;
end

% Trim unused cells
alignedImagesGray = alignedImagesGray(1:j-1);
alignedImagesRGB  = alignedImagesRGB(1:j-1);
transformParams   = transformParams(1:j-1);
end
