%% match_features_cv.m
function [cor, matchedCount] = match_features_cv(im1, im2, pts1, pts2)
    % Convert to cornerPoints
    points1 = cornerPoints(pts1');
    points2 = cornerPoints(pts2');

    % Extract SURF descriptors
    [features1, valid1] = extractFeatures(im1, points1, 'Method', 'SURF');
    [features2, valid2] = extractFeatures(im2, points2, 'Method', 'SURF');

    % Match features using standard constraints
    indexPairs = matchFeatures(features1, features2, ...
        'MatchThreshold', 10, 'MaxRatio', 0.8, 'Unique', true);

    % Retrieve matched coordinates
    matched1 = valid1(indexPairs(:,1)).Location';
    matched2 = valid2(indexPairs(:,2)).Location';
    cor = [matched1; matched2];
    matchedCount = size(cor, 2);
end




