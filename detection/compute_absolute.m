function result = compute_absolute(imgs, options)
% COMPUTE_ABSOLUTE given an array of images compute the difference masks 
% between them. 
%
% Input Arguments:
%   imgs: cell array of images {img1, img2, ..., imgN}
%
%   options: struct containing additional options:
%       - 'abs_threshold' : threshold value for the absolute difference 
%
% Output:
%   result: Struct containing
%       - result.mask : array of computed difference masks (N-1 cells)
%       - result.visual_gray: original gray_scale image (or cell array of 
%           images) with overlay visualization.
%       - result.visual_rgb: original image (or cell array of images) with
%           overlay visualization.

    num_imgs = numel(imgs);
    % initialize the outputs
    result.mask = cell(num_imgs-1,1);
    result.visual_gray = cell(num_imgs-1,1);
    result.visual_rgb = cell(num_imgs-1,1);
    % result.data = ?
    
    % iterate through the images
    for i = 1:num_imgs-1
        img1 = imgs{i};
        img2 = imgs{i+1};
    
        % Convert to grayscale if needed
        if size(img1, 3) == 3
            img1_gray = rgb2gray(img1);
        else
            img1_gray = img1;
        end
        if size(img2,3) == 3
            img2_gray = rgb2gray(img2);
        else
            img2_gray = img2;
        end 
    
        % Compute the absolute difference
        diff = imabsdiff(img1_gray, img2_gray);
        %diff = abs(double(img1)-double(img2));
    
        % Normalize and threshold
        diff_norm = mat2gray(diff);
        %diff_norm = (diff - min(diff(:))) / (max(diff(:)) - min(diff(:)));
        threshold = options.abs_threshold;
        mask = diff_norm > threshold;

        % removing noise
        mask = bwareaopen(mask, 50); % removes regions smaller than 50 pixels
        se = strel('disk',2);
        mask = imclose(mask, se); % remove small holes in change regions
        mask = imdilate(mask, se); % smooth edges
        mask = imerode(mask, se);
    
        result.mask{i} = mask;
    
        % create red overlay on the grascale image
        orig_gray = im2double(repmat(img1_gray, 1,1,3));
        overlay_gray = orig_gray;
        overlay_gray(:,:,1) = overlay_gray(:,:,1) + 0.6 * mask; % red
        overlay_gray = min(overlay_gray,1);
    
        result.visual_gray{i} = overlay_gray;

        % RGB overlay
        if size(img1,3) == 1
            result.visual_rgb{i} = gray_overlay;
        else
           orig_rgb = im2double(img1);
           rgb_overlay = orig_rgb;
           rgb_overlay(:,:,1) = rgb_overlay(:,:,1) + 0.6 * mask;
           rgb_overlay = min(rgb_overlay,1);
           result.visual_rgb{i} = rgb_overlay;
        end
        
    end 


end