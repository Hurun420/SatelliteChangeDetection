function [alignedImagesGray, alignedImagesRGB, transformParams] = register_images(folderPath, imageList)
% REGISTER_IMAGES_POL
% Registers all images in imageList (within folderPath) to the first image as reference.
%
% Inputs:
%   folderPath: string, path to the folder containing the images
%   imageList:  cell array of image file names (e.g. {'2020 01.jpg', '2023 04.jpg'})
%
% Outputs:
%   alignedImagesGray: grayscale aligned versions of the images
%   alignedImagesRGB:  color (RGB) aligned versions
%   transformParams:   transformation objects used for each image

    % Read and preprocess reference image
    refRGB = im2double(imread(fullfile(folderPath, imageList{1})));
    refGray = rgb2gray(refRGB);
    refGrayEq = adapthisteq(refGray);

    numImages = numel(imageList);
    alignedImagesGray = cell(1, numImages);
    alignedImagesRGB  = cell(1, numImages);
    transformParams   = cell(1, numImages);

    % Store reference image directly
    alignedImagesGray{1} = refGrayEq;
    alignedImagesRGB{1}  = refRGB;
    transformParams{1}   = affine2d(eye(3));  % Identity transform

    for i = 2:numImages
        % Read current image
        currRGB = im2double(imread(fullfile(folderPath, imageList{i})));
        currGray = rgb2gray(currRGB);
        currGrayEq = adapthisteq(currGray);

        % Detect SURF features
        pointsRef = detectSURFFeatures(refGrayEq);
        pointsCurr = detectSURFFeatures(currGrayEq);

        [featuresRef, validPtsRef] = extractFeatures(refGrayEq, pointsRef);
        [featuresCurr, validPtsCurr] = extractFeatures(currGrayEq, pointsCurr);

        indexPairs = matchFeatures(featuresRef, featuresCurr, 'Unique', true);
        matchedRef = validPtsRef(indexPairs(:, 1));
        matchedCurr = validPtsCurr(indexPairs(:, 2));

        % Estimate transform
        try
            tform = estgeotform2d(matchedCurr, matchedRef, 'similarity', 'MaxDistance', 5, 'Confidence', 99,'MaxNumTrials', 5000); % Ransac does not get Geometry right for some Rainforest/Frauenkirche images
        catch
            warning('⚠️  Transformation failed for %s. Keeping original image.', imageList{i});
            alignedImagesGray{i} = currGrayEq;
            alignedImagesRGB{i}  = currRGB;
            transformParams{i}   = [];
            continue;
        end

        % Apply transform to grayscale
        outputView = imref2d(size(refGrayEq));
        alignedGray = imwarp(currGrayEq, tform, 'OutputView', outputView);
        alignedImagesGray{i} = alignedGray;

        % Apply same transform to RGB
        alignedRGB = imwarp(currRGB, tform, 'OutputView', outputView);
        alignedImagesRGB{i} = alignedRGB;

        % Save transform
        transformParams{i} = tform;
    end
end
