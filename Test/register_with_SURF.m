function [tform, matchedPointsCurr, matchedPointsRef] = register_with_SURF(refImage, movingImage)
    pointsRef = detectSURFFeatures(refImage);
    pointsCurr = detectSURFFeatures(movingImage);

    [featuresRef, validPointsRef] = extractFeatures(refImage, pointsRef);
    [featuresCurr, validPointsCurr] = extractFeatures(movingImage, pointsCurr);

    indexPairs = matchFeatures(featuresRef, featuresCurr, 'MaxRatio', 0.7, 'Unique', true);
    matchedPointsRef = validPointsRef(indexPairs(:, 1));
    matchedPointsCurr = validPointsCurr(indexPairs(:, 2));

    tform = estimateGeometricTransform2D(matchedPointsCurr, matchedPointsRef, 'affine');
end
