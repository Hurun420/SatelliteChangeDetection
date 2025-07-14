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
%       - result.speed : array of computed difference masks (N-2 cells)
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
    if num_imgs < 3
        error('Need at least 3 images to compute speed.');
    end

    % initialize the outputs
    result.speed = cell(num_imgs,1);
    result.visual_gray = cell(num_imgs,1);
    result.visual_rgb = cell(num_imgs,1);

    % constants used in the loop:
    cmap = jet(256);  % or 'hot', 'parula'
    result.colormap = cmap;
    alpha = 0.6;  % transparency level

    % to keep the heatmap scale consistent, keep track of minimal and
    % maximal speed 
    min_val = Inf;
    max_val = -Inf;

    % Iterate through the images
    %% Pass 1: find min and max speed values across all frames

    % First image: use forward difference
    next = imgs{2};
    curr = imgs{1};

    % convert to grayscale if needed
    next = to_gray(next);
    curr = to_gray(curr);

    mask = (curr > 0) & (next > 0); % only compare where both are non-black
    speed = zeros(size(curr));
    speed(mask) =  abs(double(next(mask)) - double(curr(mask)));  % forward diff
    %speed = abs(double(next) - double(curr));  % forward diff
    valid_speeds = speed(mask);
    min_val = min(min_val, min(valid_speeds));
    max_val = max(max_val, max(valid_speeds));

    % Middle images: central difference
    for i = 2:(num_imgs-1) 
        prev = imgs{i-1};
        next = imgs{i+1};

        % convert to grayscale if needed
        prev = to_gray(prev);
        next = to_gray(next);
        
        mask = (prev > 0) & (next > 0); 
        speed = zeros(size(next));
        speed(mask) = abs(double(next(mask))-double(prev(mask)));
        
        %speed = abs(double(next) - double(prev)) / 2;
        valid_speeds = speed(mask);
        min_val = min(min_val, min(valid_speeds));
        max_val = max(max_val, max(valid_speeds));

    end

    % Last image: backward difference 
    curr = imgs{num_imgs};
    prev = imgs{num_imgs-1};

    curr = to_gray(curr);
    prev = to_gray(prev);
    
    mask = (curr > 0) & (prev > 0); 
    speed = zeros(size(curr));
    speed(mask) = abs(double(curr(mask))-double(prev(mask)));

    %speed = abs(double(curr) - double(prev));  % backward diff
    valid_speeds = speed(mask);
    min_val = min(min_val, min(valid_speeds));
    max_val = max(max_val, max(valid_speeds));

    %% Pass 2: normalization and visualization 

    % First image: use forward difference
    next = imgs{2};
    curr = imgs{1};

    % convert to grayscale if needed
    next = to_gray(next);
    if size(curr,3) == 3
        curr_gray = rgb2gray(curr);
    else
        curr_gray = curr;
    end

    mask = (curr_gray > 0) & (next > 0); % only compare where both are non-black
    speed = zeros(size(curr_gray));
    speed(mask) =  abs(double(next(mask)) - double(curr_gray(mask)));  % forward diff
    %speed = abs(double(next) - double(curr_gray));  % forward diff
    
    speed_norm = zeros(size(speed));
    speed_norm(mask) = (speed(mask) - min_val) / (max_val - min_val); % normalize to [0,1]
    result.speed{1} = speed_norm; % save for later use

    % visualize as a heat map (different speed = different color)
    speed_rgb = ind2rgb(uint8(speed_norm * 255), cmap);

    % Blend with original (grayscale or color)
    base_gray = im2double(repmat(curr_gray, 1, 1, 3));  % grayscale to RGB
    overlay_gray = (1 - alpha) * base_gray + alpha * speed_rgb;
    result.visual_gray{1} = overlay_gray;

    if size(curr,3) == 3
        base_rgb = im2double(curr);  % original RGB
        overlay_rgb = (1 - alpha) * base_rgb + alpha * speed_rgb;
        result.visual_rgb{1} = overlay_rgb;
    else
        result.visual_rgb{1} = overlay_gray;
    end

    % Middle images: centeral difference
    for i = 2:(num_imgs-1) % use three images to estimate the rate of change 
        prev = imgs{i-1}; 
        curr = imgs{i};
        next = imgs{i+1};
    
        % convert to grayscale if needed
        prev = to_gray(prev);
        if size(curr,3) == 3
            curr_gray = rgb2gray(curr);
        else 
            curr_gray = curr;
        end 
        next = to_gray(next);
    
        % estimate second derivative
        mask = (prev > 0) & (next > 0); 
        speed = zeros(size(next));
        speed(mask) = abs(double(next(mask))-double(prev(mask)));

        %speed = imabsdiff(double(next)-double(prev)) / 2;
        %speed = abs(double(next) - double(prev)) / 2;
        %speed_norm = mat2gray(speed);  
        speed_norm = zeros(size(speed));
        speed_norm(mask) = (speed(mask) - min_val) / (max_val - min_val); % normalize to [0,1]
        %speed_norm = (speed(mask) - min_val) / (max_val - min_val); % normalize to [0,1]

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
        else
            result.visual_rgb{i} = overlay_gray;
        end

    end 

    % Last image: backward difference 
    curr = imgs{num_imgs};
    prev = imgs{num_imgs-1};

    prev = to_gray(prev);
    if size(curr,3) == 3
        curr_gray = rgb2gray(curr);
    else
        curr_gray = curr;
    end

    mask = (curr_gray > 0) & (prev > 0); 
    speed = zeros(size(curr_gray));
    speed(mask) = abs(double(curr_gray(mask))-double(prev(mask)));
    
    %speed = abs(double(curr_gray) - double(prev));  % backward diff
    %speed_norm = (speed(mask) - min_val) / (max_val - min_val); % normalize to [0,1]
    speed_norm = zeros(size(speed));
    speed_norm(mask) = (speed(mask) - min_val) / (max_val - min_val);
    result.speed{num_imgs} = speed_norm; % save for later use

    % visualize as a heat map (different speed = different color)
    speed_rgb = ind2rgb(uint8(speed_norm * 255), cmap);

    % Blend with original (grayscale or color)
    base_gray = im2double(repmat(curr_gray, 1, 1, 3));  % grayscale to RGB
    overlay_gray = (1 - alpha) * base_gray + alpha * speed_rgb;
    result.visual_gray{num_imgs} = overlay_gray;

    if size(curr,3) == 3
        base_rgb = im2double(curr);  % original RGB
        overlay_rgb = (1 - alpha) * base_rgb + alpha * speed_rgb;
        result.visual_rgb{num_imgs} = overlay_rgb;
    else
        result.visual_rgb{num_imgs} = overlay_gray;
    end

    result.speedrange = [min_val, max_val];
    result.label = 'Relative speed (0–1)';
    % render the legend (for the heatmap)
    legend_img = repmat(linspace(0,1,256), 20, 1); % a 20-pixel tall bar
    legend_rgb = ind2rgb(uint8(legend_img*255), jet(256));
    result.legend_img = legend_rgb;

end 

% helper function:
function img_gray = to_gray(img)
    if size(img,3) == 3
        img_gray = rgb2gray(img);
    else
        img_gray = img;
    end
end 