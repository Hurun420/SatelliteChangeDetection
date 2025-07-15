function [alignedImagesGray, alignedImagesRGB, transformParams, successIndices] = register_images(folderPath, imageList)
% REGISTER_IMAGES with SURF + RANSAC (with fallback)
% Registers all images in imageList to the first image as reference using mutual SURF feature matching.

    numImages = numel(imageList);
    alignedImagesGray = cell(1, numImages);
    alignedImagesRGB  = cell(1, numImages);
    transformParams   = cell(1, numImages);
    successIndices    = [];
    
    j = 1;

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
            refGrayEq = currGrayEq;
            alignedImagesGray{j} = currGrayEq;
            alignedImagesRGB{j}  = currRGB;
            transformParams{j}   = affine2d(eye(3));
            j = j + 1;
            successIndices(end+1) = i;
            continue;
        end

        % --- SURF Feature Detection ---
        surfpointsRef  = detectSURFFeatures(refGrayEq);
        surfpointsCurr = detectSURFFeatures(currGrayEq);

        N = 1000;
        pointsRef  = surfpointsRef.selectStrongest(N);
        pointsCurr = surfpointsCurr.selectStrongest(N);

        [featuresRef, validPtsRef]   = extractFeatures(refGrayEq, pointsRef);
        [featuresCurr, validPtsCurr] = extractFeatures(currGrayEq, pointsCurr);

        % --- Bidirectional Matching ---
        forwardMatches = matchFeatures(featuresRef, featuresCurr, 'Unique', true, 'MaxRatio', 1, 'MatchThreshold', 100);
        backwardMatches = matchFeatures(featuresCurr, featuresRef, 'Unique', true, 'MaxRatio', 1, 'MatchThreshold', 100);
        backwardFlipped = fliplr(backwardMatches);
        mutualMatches = intersect(forwardMatches, backwardFlipped, 'rows');

        if size(mutualMatches, 1) < 10
            warning('⚠️ Too few mutual matches for %s. Skipping.', currName);
            continue;
        end

        matchedRef  = validPtsRef(mutualMatches(:,1));
        matchedCurr = validPtsCurr(mutualMatches(:,2));

        % --- Transformation Estimation: Fast Attempt ---
        condBad = true;
        try
            [tform, inlierIdx] = estimateGeometricTransform2D(matchedCurr, matchedRef, ...
                'similarity', 'MaxDistance', 3, 'Confidence', 99.9, 'MaxNumTrials', 10000);

            R = tform.T(1:2,1:2);
            scale = sqrt(sum(R(:,1).^2));
            inlierRatio = numel(inlierIdx) / size(matchedCurr, 1);

            condBad = inlierRatio < 0.3 || scale < 0.7 || scale > 1.3 || rcond(R) < 1e-6;
        catch
            warning('⚠️ Fast SURF transform crashed.');
        end

        % --- Fallback if fast transform fails ---
        if condBad
            try
                warning('⚠️ Retrying with more iterations (fallback)...');
                [tform, inlierIdx] = estimateGeometricTransform2D(matchedCurr, matchedRef, ...
                    'similarity', 'MaxDistance', 5, 'Confidence', 99.9, 'MaxNumTrials', maxNumTrials);

                R = tform.T(1:2,1:2);
                scale = sqrt(sum(R(:,1).^2));
                inlierRatio = numel(inlierIdx) / size(matchedCurr, 1);
                condBad = inlierRatio < 0.3 || scale < 0.7 || scale > 1.3 || rcond(R) < 1e-6;
            catch
                warning('❌ Fallback transform failed for %s.', currName);
                continue;
            end
        end

        % Final check
        if condBad || isempty(tform) || ~isobject(tform)
            warning('❌ Final registration rejected for %s.', currName);
            continue;
        end

        % Apply transformation
        outputView = imref2d(size(refGrayEq));
        alignedGray = imwarp(currGrayEq, tform, 'OutputView', outputView);
        alignedRGB  = imwarp(currRGB, tform, 'OutputView', outputView);

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
