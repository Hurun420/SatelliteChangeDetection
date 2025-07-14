function [alignedImagesGray, alignedImagesRGB, transformParams] = register_images(folderPath, imageList) 
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

    numImages = numel(imageList);  % Total number of images

    % Preallocate output arrays to avoid dynamic resizing during loop
    alignedImagesGray = cell(1, numImages);
    alignedImagesRGB  = cell(1, numImages);
    transformParams   = cell(1, numImages);

    j = 1;  % Counter for successful registrations

    % Loop through each image in the list
    for i = 1:numel(alignedImagesGray)
        currName = imageList{i};  % Get current image filename
        currPath = fullfile(folderPath, currName);  % Construct full path

        % Try reading the image; skip if file is unreadable
        try
            currRGB = im2double(imread(currPath));  % Read and convert to double precision
        catch
            warning('⚠️ Could not read image: %s. Skipping.', currName);
            continue;
        end

        % Convert to grayscale and enhance contrast
        currGray = rgb2gray(currRGB);
        currGrayEq = adapthisteq(currGray);

        % Use the first successfully read image as the reference
        if i == 1
            refGrayEq = currGrayEq;                  % Set reference grayscale image
            alignedImagesGray{j} = currGrayEq;       % Store reference image in output
            alignedImagesRGB{j}  = currRGB;          % Store original RGB reference
            transformParams{j}   = affine2d(eye(3));  % Identity transform for reference
            j = j + 1;
            continue;
        end

        % Detect SURF features in both reference and current image
        surfpointsRef  = detectSURFFeatures(refGrayEq);
        surfpointsCurr = detectSURFFeatures(currGrayEq);

        % Select top N strongest features to reduce computation
        N = 1000;
        pointsRef  = surfpointsRef.selectStrongest(N);
        pointsCurr = surfpointsCurr.selectStrongest(N);

        % Extract descriptors from selected points
        [featuresRef, validPtsRef]   = extractFeatures(refGrayEq, pointsRef);
        [featuresCurr, validPtsCurr] = extractFeatures(currGrayEq, pointsCurr);

        % Match features between reference and current image
        indexPairs = matchFeatures(featuresRef, featuresCurr, 'Unique', true, 'MaxRatio', 1,'MatchThreshold', 5);

        % Skip if no matches were found
        if isempty(indexPairs)
            warning('⚠️ No matches found for %s. Skipping.', currName);
            continue;
        end

        % Get matched points
        matchedRef  = validPtsRef(indexPairs(:, 1));
        matchedCurr = validPtsCurr(indexPairs(:, 2));

        % Estimate geometric transformation using matched points
        try
            tform = estgeotform2d(matchedCurr, matchedRef, 'similarity', 'MaxDistance', 5, 'Confidence', 99.9, 'MaxNumTrials', 10000);
        catch
            warning('⚠️  Transformation failed for %s. Skipping.', currName);
            continue;
        end

        % Evaluate transformation quality
        R = tform.T(1:2, 1:2);            % Extract rotation/scaling matrix
        scale = sqrt(sum(R(:,1).^2));     % Estimate scale from transformation
        %rotation = atan2(R(2,1), R(1,1)) * (180 / pi);  % [Optional] Compute rotation

        % Reject unrealistic or unstable transformations
        if scale < 0.7 || scale > 1.3 || rcond(R) < 1e-6
            warning('❌ Registration rejected for %s. Scale: %.2f, rcond: %.2e', currName, scale, rcond(R));
            continue;
        end

        % Define output view the same size as reference image
        outputView = imref2d(size(refGrayEq));

        % Warp current image using the estimated transformation
        alignedGray = imwarp(currGrayEq, tform, 'OutputView', outputView);  % Aligned grayscale
        alignedRGB  = imwarp(currRGB, tform, 'OutputView', outputView);     % Aligned RGB

        % Store aligned images and transformation
        alignedImagesGray{j} = alignedGray;
        alignedImagesRGB{j}  = alignedRGB;
        transformParams{j}   = tform;

        j = j + 1;  % Move to next output slot
    end

    % Trim arrays to include only successfully registered images
    alignedImagesGray = alignedImagesGray(1:j-1);
    alignedImagesRGB  = alignedImagesRGB(1:j-1);
    transformParams   = transformParams(1:j-1);
end
