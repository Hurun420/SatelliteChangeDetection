function [points] = harris_detector(img, varargin)
    % HARRIS_DETECTOR  Detect Harris corners in a grayscale image.
    % Parameters (set via name-value pairs):
    %   tau               - Threshold for corner response (default: 1e5)
    %   segment_length    - Size of the window (default: 15)
    %   k                 - Harris detector parameter (default: 0.05)
    %   do_plot           - Show image with detected corners (default: false)
    %   max_features      - Maximum number of points (default: 500)
    %   margin            - Border margin to avoid (default: 10)
    %   auto_adjust_tau   - Enable auto lowering tau (default: true)

    % Parse input
    p = inputParser;
    addParameter(p, 'tau', 1e5);
    addParameter(p, 'segment_length', 15);
    addParameter(p, 'k', 0.05);
    addParameter(p, 'do_plot', false);
    addParameter(p, 'max_features', 500);
    addParameter(p, 'margin', 10);
    addParameter(p, 'auto_adjust_tau', true);
    parse(p, varargin{:});

    tau = p.Results.tau;
    segment_length = p.Results.segment_length;
    k = p.Results.k;
    do_plot = p.Results.do_plot;
    max_features = p.Results.max_features;
    margin = p.Results.margin;
    auto_adjust = p.Results.auto_adjust_tau;

    % Convert to double if needed
    img = double(img);

    % Gaussian filter
    sigma = segment_length / 5;
    g = fspecial('gaussian', [segment_length, segment_length], sigma);
    [Ix, Iy] = gradient(img);
    Ix2 = conv2(Ix.^2, g, 'same');
    Iy2 = conv2(Iy.^2, g, 'same');
    Ixy = conv2(Ix.*Iy, g, 'same');

    % Harris response
    H = (Ix2 .* Iy2 - Ixy.^2) - k * (Ix2 + Iy2).^2;

    % Normalize
    H = H / max(H(:));

    % Try to adapt tau until features found
    min_features = 50;
    tau_min = 1e-6;
    scale = 0.5;
    found = false;
    H_mask = (H > tau);

    while auto_adjust && sum(H_mask(:)) < min_features && tau > tau_min
        tau = tau * scale;
        H_mask = (H > tau);
    end

    if sum(H_mask(:)) == 0
        warning('Harris detector found 0 features after thresholding (tau=%.2e)', tau);
        points = zeros(0, 2);
        return;
    end

    % Get coordinates
    [y, x] = find(H_mask);
    scores = H(H_mask);
    points = [x, y, scores];

    % Exclude margin area
    valid = x > margin & x < size(img,2)-margin & ...
            y > margin & y < size(img,1)-margin;
    points = points(valid, :);

    % Sort and pick top responses
    points = sortrows(points, -3);  % Descending by response
    points = points(1:min(end, max_features), :);

    % Final output
    points = points(:, 1:2);  % remove scores

    % Plot
    if do_plot
        figure; imshow(uint8(img)); hold on;
        plot(points(:,1), points(:,2), 'r+');
        title(sprintf('Harris Points (tau=%.1e, %d points)', tau, size(points,1)));
    end
end
