function result = compute_absolute(imgs)

    num_imgs = numel(imgs);
    % initialize the outputs
    result.mask = cell(num_imgs-1,1);
    result.visual = cell(num_imgs-1,1);
    % result.data = ?
    
    % iterate through the images
    for i = 1:num_imgs-1
        img1 = imgs{i};
        img2 = imgs{i+1};
    
        % Convert to grayscale if needed
        if size(img1, 3) == 3
            img1 = rgb2gray(img1);
        end
        if size(img2,3) == 3
            img2 = rgb2gray(img2);
        end
    
        % Compute the absolute difference
        %diff = imabsdiff(img1, img2);
        diff = abs(double(img1)-double(img2));
    
        % Normalize and threshold
        % diff_norm = mat2gray(diff);
        diff_norm = (diff - min(diff(:))) / (max(diff(:)) - min(diff(:)));
        threshold = 0.2;
        mask = diff_norm > threshold;
    
        result.mask{i} = mask;
    
        % create red overlay
        orig_rgb = im2double(repmat(img1, 1,1,3));
        overlay = orig_rgb;
        overlay(:,:,1) = overlay(:,:,1) + 0.8 * mask; % red
        overlay = min(overlay,1);
    
        result.visual{i} = overlay;
        
    end 


end