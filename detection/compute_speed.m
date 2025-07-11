function result = compute_speed(imgs, options)
% COMPUTE_SPEED given an array of images (at least 3) estimate which
% pixels are chaning at the largest speed 
% 
% Input Arguments:
%   imgs: cell array of images {img1, img2, ..., imgN}
%
%   options: struct containing additional options (if needed):
%       - 'abs_threshold' : threshold value for the absolute difference(?)
%
% Output:
%   result: Struct containing
%       - result.mask : array of computed difference masks (N-1 cells)
%       - result.visual_gray: original gray_scale image (or cell array of 
%           images) with overlay visualization.
%       - result.visual_rgb: original image (or cell array of images) with
%           overlay visualization.
%       - result.colormap : colormap used for the heat maps.
%       - result.speedrange : speed value range.
%       - result.label : label for the legend. 
%       - result.legend_img : rendered legend as an image.
% Note: the speeds used in the heatmaps are normalized using the minimal
% and maximal speeds registered in the images sequence.

    num_imgs = numel(imgs);
    % initialize the outputs
    result.speed = cell(num_imgs-1,1);
    result.visual_gray = cell(num_imgs-1,1);
    result.visual_rgb = cell(num_imgs-1,1);

    % constants used in the loop:
    cmap = jet(256);  % or 'hot', 'parula'
    result.colormap = cmap;
    alpha = 0.6;  % transparency level

    % to keep the heatmap scale consistent, keep track of minimal and
    % maximal speed 
    min_val = Inf;
    max_val = -Inf;

    % Iterate through the images
    % pass 1: find min and max speed values across all frames
    for i = 2:(num_imgs-1) 
        prev = imgs{i-1};
        next = imgs{i+1};

        % convert to grayscale if needed
        if size(prev,3) == 3 
            prev = rgb2gray(prev);
        end
        if size(next,3) == 3
            next = rgb2gray(next);
        end 

        speed = abs(double(next) - double(prev)) / 2;
        min_val = min(min_val, min(speed(:)));
        max_val = max(max_val, max(speed(:)));

    end

    % Pass 2: normalization and visualization 
    for i = 2:(num_imgs-1) % use three images to estimate the rate of change 
        prev = imgs{i-1}; 
        curr = imgs{i};
        next = imgs{i+1};
    
        % convert to grayscale if needed
        if size(prev,3) == 3 
            prev = rgb2gray(prev);
        end
        if size(curr,3) == 3
            curr_gray = rgb2gray(curr);
        else 
            curr_gray = curr;
        end 
        if size(next,3) == 3
            next = rgb2gray(next);
        end 
    
        % estimate second derivative
        %speed = imabsdiff(double(next)-double(prev)) / 2;
        speed = abs(double(next) - double(prev)) / 2;

        %speed_norm = mat2gray(speed);  
        speed_norm = (speed - min_val) / (max_val - min_val); % normalize to [0,1]

        %speed_norm = speed_norm > 0.1;
        %speed_norm = bwareaopen(speed_norm, 10); % remove noise
        result.speed{i} = speed_norm; % save for later use
    
        % visualize as a heat map (different speed = different color)
        speed_rgb = ind2rgb(uint8(speed_norm * 255), cmap);
    
        % Blend with original (grayscale or color)
        base_gray = im2double(repmat(curr_gray, 1, 1, 3));  % grayscale to RGB
        overlay_gray = (1 - alpha) * base_gray + alpha * speed_rgb;
        result.visual_gray{i} = overlay_gray;

        if size(curr,3) == 3
            base_rgb = im2double(curr);  % original RGB
            overlay_rgb = (1 - alpha) * base_rgb + alpha * speed_rgb;
            result.visual_rgb{i} = overlay_rgb;
        end

    end 
    
    result.speedrange = [min_val, max_val];
    result.label = 'Relative speed (0–1)';
    % render the legend (for the heatmap)
    legend_img = repmat(linspace(0,1,256), 20, 1); % a 20-pixel tall bar
    legend_rgb = ind2rgb(uint8(legend_img*255), jet(256));
    result.legend_img = legend_rgb;

end 