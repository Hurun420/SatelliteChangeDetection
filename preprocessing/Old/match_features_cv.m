function [cor, matchedCount] = match_features_cv(im1, im2, pts1, pts2)
points1 = cornerPoints(pts1');
points2 = cornerPoints(pts2');

[features1, valid1] = extractFeatures(im1, points1, 'Method', 'SURF');
[features2, valid2] = extractFeatures(im2, points2, 'Method', 'SURF');

indexPairs = matchFeatures(features1, features2, ...
    'MatchThreshold', 10, 'MaxRatio', 0.8, 'Unique', true);

matched1 = valid1(indexPairs(:,1)).Location';
matched2 = valid2(indexPairs(:,2)).Location';
cor = [matched1; matched2];
matchedCount = size(cor, 2);
end
