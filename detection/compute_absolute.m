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
%       - result.imgs_gray : original images but gray scale (if needed for
%           visualization purposes)
%       - result.visual_gray : original gray_scale image (or cell array of 
%           images) with overlay visualization.
%       - result.visual_rgb: original image (or cell array of images) with
%           overlay visualization.

    num_imgs = numel(imgs);
    % initialize the outputs
    result.mask = cell(num_imgs-1,1);
    result.imgs_gray = cell(num_imgs, 1);
    result.visual_gray = cell(num_imgs,1);
    result.visual_rgb = cell(num_imgs,1);
    % result.data = ?

    % store grayscale and visualizations of first image
    if size(imgs{1}, 3) == 3
        result.imgs_gray{1} = im2double(repmat(rgb2gray(imgs{1}), 1,1,3));
        result.visual_gray{1} = result.imgs_gray{1}; % no visualization 
            % for the first image
        result.visual_rgb{1} = imgs{1};  
    else 
        result.imgs_gray{1} = im2double(repmat(imgs{1}, 1,1,3));
        result.visual_gray{1} = result.imgs_gray{1};
        result.visual_rgb{1} = result.visual_gray{1}; % rgb visualization 
            % same as grayscale if the original images are grayscale
    end
    
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

        % create validity mask: ignore fully black pixels in either images
        valid_mask = (img1_gray > 0) & (img2_gray > 0);
    
        % Compute the absolute difference
        diff = imabsdiff(img1_gray, img2_gray);
        %diff = abs(double(img1)-double(img2));

        % Apply validity mask (set invalid pixels to zero)
        diff(~valid_mask) = 0;
    
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
        orig_gray = im2double(repmat(img2_gray, 1,1,3));
        result.imgs_gray{i+1} = orig_gray; % save grayscale image for img2

        %if i == num_imgs-1 
        %    result.imgs_gray{i+1} = im2double(repmat(img2_gray, 1,1,3));
        %end

        overlay_gray = orig_gray;
        overlay_gray(:,:,1) = overlay_gray(:,:,1) + 0.6 * mask; % red
        overlay_gray = min(overlay_gray,1);
        % save visualization
        result.visual_gray{i+1} = overlay_gray;

        % RGB overlay on img2
        if size(img2,3) == 1
            result.visual_rgb{i+1} = overlay_gray;
        else
           orig_rgb = im2double(img2);
           rgb_overlay = orig_rgb;
           rgb_overlay(:,:,1) = rgb_overlay(:,:,1) + 0.6 * mask;
           rgb_overlay = min(rgb_overlay,1);
           result.visual_rgb{i+1} = rgb_overlay;
        end
        
    end 

    % Fill last visual_gray and visual_rgb
    %result.visual_gray{num_imgs} = result.imgs_gray{num_imgs}; 
    %if size(imgs{num_imgs}, 3) == 3
    %    result.visual_rgb{num_imgs} = imgs{num_imgs};
    %else
    %    result.visual_rgb{num_imgs} = result.imgs_gray{num_imgs};
    %end


end