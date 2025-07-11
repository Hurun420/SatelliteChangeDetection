function result = detect_changes(imgs, mode, options)
% DETECT_CHANGES Detect, analyze, and visualize (based on the specified 
% analysis mode) the changes between two or more preprocessed (aligned and 
% brightness/contrast normalized) images.
%
% Input Arguments:
%   imgs : cell array of images (e.g., {img1, img2, ...}), sorted by time.
%       Images must be pre-aligned and of the same size.
%       ⚠️ NOTE: Indexed images ([img, map] = imread(...)) must be
%       converted using ind2rgb(img, map) **before** being passed to the
%       function.
%   
%   mode : (String) specifies the type of change analysis to perform:
%       - 'absolute' : detects pixel-wise changes between pairs of images.
%           returns masks highlithing changed areas and visual
%           overlays (e.g. red mask on orignal image)
%       - 'speed' : for a sequence of images, estimates per-pixel speed of
%           change (how fast a region changes over time), and returns a 
%           a heatmap or series of visualizations (that can be later 
%           used to make a timelapse).
%       - 'size': identify changed regions and color code them based on
%           size.
%       - 'landuse' : classifies types of regional change like urban
%           expansion, vegetation loss.
%   options: Struct containing additional options / user-specified params:
%       - 'abs_threshold' : threshold value for absolute difference
%
% Output:
%   result : Struct containing analysis outputs depending on mode:
%       - result.mask : mask of change regions.
%       - result.visual_gray: original gray_scale image (or cell array of 
%           images) with overlay visualization.
%       - result.visual_rgb: original image (or cell array of images) with
%           overlay visualization.
%       - result.heatmap : (for 'speed' mode), image showing change 
%           intensity/speed.
%       - result.data : additional info, change percentages, etc.

    if nargin < 2 || isempty(mode)
        mode = 'absolute';
    end
    if nargin < 3 || isempty(options)
        options = struct();  % Empty struct if none provided
    end

    if ~isfield(options, 'abs_threshold')
        options.abs_threshold = 0.2;
    end

    num_imgs = numel(imgs); 
    if num_imgs < 2
        error("At least two images required.");
    end 

    switch lower(mode)
        case 'absolute'
            result = compute_absolute(imgs, options);

        case 'speed'
            result = compute_speed(imgs);

        case 'size'
            result = compute_size(imgs);

        case 'landuse'
            result = compute_landuse(imgs);

        otherwise 
            error('Mode "%s" unknown', mode);
    end 

end