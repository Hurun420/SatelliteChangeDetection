function [features] = harris_detector(input_image, varargin)
    % HARRIS_DETECTOR - Detect Harris corners with robustness against empty outputs
    % Features returned as [x; y] with max_features limit

    % Argument parsing
    p = inputParser;
    addParameter(p, 'segment_length', 15, @(x) isnumeric(x) && mod(x,2)==1);
    addParameter(p, 'k', 0.05, @(x) isnumeric(x) && x >= 0 && x <= 1);
    addParameter(p, 'tau', 1e5, @(x) isnumeric(x) && x > 0);
    addParameter(p, 'do_plot', false, @(x) islogical(x));
    addParameter(p, 'max_features', 500, @(x) isnumeric(x) && x > 0);
    addParameter(p, 'auto_adjust_tau', true, @(x) islogical(x));
    parse(p, varargin{:});

    segment_length = p.Results.segment_length;
    k = p.Results.k;
    tau = p.Results.tau;
    do_plot = p.Results.do_plot;
    max_features = p.Results.max_features;
    auto_adjust = p.Results.auto_adjust_tau;

    % Convert image to double
    input_image = double(input_image);
    
    % Compute gradients
    sobel_x = [-1 0 1; -2 0 2; -1 0 1];
    sobel_y = sobel_x';
    Ix = conv2(input_image, sobel_x, 'same');
    Iy = conv2(input_image, sobel_y, 'same');

    % Compute structure tensor components
    sigma = (segment_length - 1) / 6;
    w = fspecial('gaussian', [segment_length, segment_length], sigma);
    G11 = conv2(Ix.^2, w, 'same');
    G22 = conv2(Iy.^2, w, 'same');
    G12 = conv2(Ix.*Iy, w, 'same');

    % Compute Harris response
    H = G11 .* G22 - G12.^2 - k * (G11 + G22).^2;

    % Suppress border
    margin = ceil(segment_length / 2);
    H(1:margin,:) = 0; H(end-margin+1:end,:) = 0;
    H(:,1:margin) = 0; H(:,end-margin+1:end) = 0;

    % Detect corners (with auto adjustment of tau if needed)
    max_try = 10;
    try_count = 0;
    while try_count < max_try
        corners = H > tau;
        [y, x] = find(corners);
        responses = H(sub2ind(size(H), y, x));

        if length(x) >= 10 || ~auto_adjust
            break;
        end
        tau = tau * 0.5;
        try_count = try_count + 1;
    end

    [~, sorted_idx] = sort(responses, 'descend');
    keep_n = min(max_features, length(sorted_idx));
    if keep_n == 0
        warning('⚠️ Harris detector found 0 features after thresholding.');
        features = zeros(2, 0);
        return;
    end
    selected_idx = sorted_idx(1:keep_n);

    features = [x(selected_idx)'; y(selected_idx)'];

    if do_plot
        figure; imshow(input_image, []); hold on;
        plot(x(selected_idx), y(selected_idx), 'r+');
        title('Harris Corners'); hold off;
    end
end
