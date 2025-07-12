function [alignedImagesGray, alignedImagesRGB, transformParams] = register_images(folderPath, imageList)
% REGISTER_IMAGES
% Registers all images to the first image in the list.

    % Read reference image
    refRGB = im2double(imread(fullfile(folderPath, imageList{1})));
    refGray = rgb2gray(refRGB);
    refGrayEq = adapthisteq(refGray);

    numImages = numel(imageList);
    alignedImagesGray = cell(1, numImages);
    alignedImagesRGB = cell(1, numImages);
    transformParams = cell(1, numImages);

    alignedImagesGray{1} = refGrayEq;
    alignedImagesRGB{1} = refRGB;
    transformParams{1} = affine2d(eye(3)); % identity transform

    for i = 2:numImages
        currRGB = im2double(imread(fullfile(folderPath, imageList{i})));
        currGray = rgb2gray(currRGB);
        currGrayEq = adapthisteq(currGray);

        % Feature detection and matching
        pointsRef = detectSURFFeatures(refGrayEq);
        pointsCurr = detectSURFFeatures(currGrayEq);
        [featuresRef, validPtsRef] = extractFeatures(refGrayEq, pointsRef);
        [featuresCurr, validPtsCurr] = extractFeatures(currGrayEq, pointsCurr);
        indexPairs = matchFeatures(featuresRef, featuresCurr, 'Unique', true);
        matchedRef = validPtsRef(indexPairs(:,1));
        matchedCurr = validPtsCurr(indexPairs(:,2));

        % Estimate transformation
        try
            tform = estgeotform2d(matchedCurr, matchedRef, 'similarity', ...
                                  'MaxDistance', 5, 'Confidence', 99, 'MaxNumTrials', 5000);
        catch
            warning('⚠️ Transformation failed for %s. Using original image.', imageList{i});
            alignedImagesGray{i} = currGrayEq;
            alignedImagesRGB{i} = currRGB;
            transformParams{i} = [];
            continue;
        end

        % Apply transformation
        outputView = imref2d(size(refGrayEq));
        alignedImagesGray{i} = imwarp(currGrayEq, tform, 'OutputView', outputView);
        alignedImagesRGB{i} = imwarp(currRGB, tform, 'OutputView', outputView);
        transformParams{i} = tform;
    end

    % Save all outputs to subfolder named after folderPath
    save_registration_outputs(imageList, alignedImagesGray, alignedImagesRGB, transformParams, folderPath);
end
