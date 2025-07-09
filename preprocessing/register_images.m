function [alignedImages, transformParams] = register_images(folderPath, imageList)
    numImages = length(imageList);
    alignedImages = cell(1, numImages);
    transformParams = cell(1, numImages);

    % Read and convert to grayscale as the global reference image
    refImage = imread(fullfile(folderPath, imageList{1}));
    if size(refImage,3) == 3
        refImageGray = rgb2gray(refImage);
    else
        refImageGray = refImage;
    end

    alignedImages{1} = refImageGray;
    transformParams{1} = affine2d(eye(3));
    
    % Extract Harris feature points from the reference image
    pts_ref = harris_detector(refImageGray, 'tau', 1e5, 'do_plot', false, 'segment_length', 15, 'max_features', 500, 'auto_adjust_tau', true);

    for i = 2:numImages
        fprintf("⚙️ Registering image %d / %d: %s\n", i, numImages, imageList{i});
        curImage = imread(fullfile(folderPath, imageList{i}));
        if size(curImage,3) == 3
            curImageGray = rgb2gray(curImage);
        else
            curImageGray = curImage;
        end


        % Detect feature points in the current image
        pts_cur = harris_detector(curImageGray, 'tau', 1e5, 'do_plot', false, 'segment_length', 15, 'max_features', 500, 'auto_adjust_tau', true);

        % First, attempt to match with the first image
        matches = point_correspondence(refImageGray, curImageGray, pts_ref, pts_cur, ...
            'window_length', 21, 'min_corr', 0.85, 'do_plot', false);
        if isempty(matches) || size(matches, 2) < 3
            fprintf("[BACK] Primary match failed. Trying fallback (previous aligned)...\n");
            % Search for the most recently successfully aligned image
            fallback_idx = find(~cellfun(@isempty, alignedImages(1:i-1)), 1, 'last');
            if isempty(fallback_idx) || fallback_idx == i
                warning("⚠️ No fallback reference available. Skipping image %s.", imageList{i});
                alignedImages{i} = [];
                transformParams{i} = [];
                continue;
            end
            fallbackImage = alignedImages{fallback_idx};
            pts_fallback = harris_detector(fallbackImage, 'tau', 1e5, 'do_plot', false, 'segment_length', 15, 'max_features', 500, 'auto_adjust_tau', true);
            matches = point_correspondence(fallbackImage, curImageGray, pts_fallback, pts_cur, ...
                'window_length', 21, 'min_corr', 0.85, 'do_plot', false);
            if isempty(matches) || size(matches, 2) < 3
                warning("⚠ Fallback match also failed for image %s. Skipping.", imageList{i});
                alignedImages{i} = [];
                transformParams{i} = [];
                continue;
            end
        end

        fprintf("🔍 Max NCC: %.4f | Matches above threshold: %d\n", max(matches(1,:) ~= 0), size(matches,2));
        fprintf("✔ %d matches used\n", size(matches,2));

        fixedPoints = matches(1:2, :)';
        movingPoints = matches(3:4, :)';

        try
            tform = fitgeotrans(movingPoints, fixedPoints, 'affine');
            aligned = imwarp(curImageGray, tform, 'OutputView', imref2d(size(refImageGray)));
            alignedImages{i} = aligned;
            transformParams{i} = tform;
        catch ME
            warning("× fitgeotrans failed on image %s: %s", imageList{i}, ME.message);
            alignedImages{i} = [];
            transformParams{i} = [];
        end
    end
end
