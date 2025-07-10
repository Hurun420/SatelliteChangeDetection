function save_registration_outputs(refGray, currGray, registered, cor, currName, outputImageFolder, outputMatFolder)
% SAVE_REGISTRATION_OUTPUTS saves aligned image, visual comparison, match figure, and matched points.
% 
% Parameters:
%   refGray           - Reference grayscale image (first image in the sequence)
%   currGray          - Current grayscale image to be aligned
%   registered        - Registered version of currGray aligned to refGray
%   cor               - 4xN matrix of matched points [ref_x; ref_y; curr_x; curr_y]
%   currName          - Filename of the current image (with extension)
%   outputImageFolder - Folder to save PNG images (aligned image, overlay, matches)
%   outputMatFolder   - Folder to save matched points (.mat file)

% Extract base name (remove .jpg or .png extension)
baseName = currName(1:end-4);

%% 1. Save aligned image as PNG
alignedPath = fullfile(outputImageFolder, sprintf('aligned_%s.png', baseName));
imwrite(registered, alignedPath);

%% 2. Save visual overlay (registered vs reference) using imshowpair
overlayFig = figure('Visible','off');
imshowpair(refGray, registered);
title(sprintf('Aligned vs Reference: %s', currName), 'Interpreter', 'none');
saveas(overlayFig, fullfile(outputImageFolder, sprintf('%s_overlay.png', baseName)));
close(overlayFig);

%% 3. Save original match figure (before transformation)
matchFigPath = fullfile(outputImageFolder, sprintf('%s_matches.png', baseName));
plot_matches(refGray, currGray, cor(1:2,:), cor(3:4,:), matchFigPath);

%% 4. Save matched point correspondences as .mat file
matPath = fullfile(outputMatFolder, sprintf('%s_points.mat', baseName));
save(matPath, 'cor');

end
