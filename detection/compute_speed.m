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

    num_imgs = numel(imgs);
    % initialize the outputs
    result.speed = cell(num_imgs-1,1);
    result.visual_gray = cell(num_imgs-1,1);
    result.visual_rgb = cell(num_imgs-1,1);

    % iterate through the images. 
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
        speed_norm = mat2gray(speed);  % normalize to [0,1]
        %speed_norm = speed_norm > 0.1;
        %speed_norm = bwareaopen(speed_norm, 10); % remove noise
        result.speed{i} = speed_norm; % save for later use
    
        % visualize as a heat map (different speed = different color)
        cmap = jet(256);  % or 'hot', 'parula'
        speed_rgb = ind2rgb(uint8(speed_norm * 255), cmap);
    
        % Blend with original (grayscale or color)
        alpha = 0.6;  % transparency level
        
        base_gray = im2double(repmat(curr_gray, 1, 1, 3));  % grayscale to RGB
        overlay_gray = (1 - alpha) * base_gray + alpha * speed_rgb;
        result.visual_gray{i} = overlay_gray;

        if size(curr,3) == 3
            base_rgb = im2double(curr);  % original RGB
            overlay_rgb = (1 - alpha) * base_rgb + alpha * speed_rgb;
            result.visual_rgb{i} = overlay_rgb;
        end

    end 

end 