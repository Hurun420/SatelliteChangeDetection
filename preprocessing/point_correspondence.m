function cor = point_correspondence(I1, I2, Ftp1, Ftp2, varargin)
    parser = inputParser;
    addParameter(parser, 'window_length', 25, @(x) isnumeric(x) && mod(x,2)==1);
    addParameter(parser, 'min_corr', 0.85, @(x) isnumeric(x) && x > 0 && x <= 1);
    addParameter(parser, 'do_plot', false, @(x) islogical(x));
    parse(parser, varargin{:});

    wlen = parser.Results.window_length;
    min_corr = parser.Results.min_corr;
    do_plot = parser.Results.do_plot;
    hwin = floor(wlen / 2);

    I1 = double(I1);
    I2 = double(I2);

    % Relax edge constraints to avoid excessive point filtering
    valid1 = (Ftp1(1,:) >= hwin+1) & (Ftp1(1,:) <= size(I1,2)-hwin-1) & ...
             (Ftp1(2,:) >= hwin+1) & (Ftp1(2,:) <= size(I1,1)-hwin-1);
    valid2 = (Ftp2(1,:) >= hwin+1) & (Ftp2(1,:) <= size(I2,2)-hwin-1) & ...
             (Ftp2(2,:) >= hwin+1) & (Ftp2(2,:) <= size(I2,1)-hwin-1);
    validFtp1 = Ftp1(:,valid1);
    validFtp2 = Ftp2(:,valid2);

    num1 = size(validFtp1,2);
    num2 = size(validFtp2,2);

    if num1 == 0 || num2 == 0
        cor = [];
        return;
    end

    Mat_feat_1 = zeros(wlen^2, num1);
    Mat_feat_2 = zeros(wlen^2, num2);

    for i = 1:num1
        patch = I1(validFtp1(2,i)-hwin:validFtp1(2,i)+hwin, validFtp1(1,i)-hwin:validFtp1(1,i)+hwin);
        vec = patch(:) - mean(patch(:));
        norm_val = norm(vec);
        if norm_val > 0
            Mat_feat_1(:,i) = vec / norm_val;
        end
    end

    for i = 1:num2
        patch = I2(validFtp2(2,i)-hwin:validFtp2(2,i)+hwin, validFtp2(1,i)-hwin:validFtp2(1,i)+hwin);
        vec = patch(:) - mean(patch(:));
        norm_val = norm(vec);
        if norm_val > 0
            Mat_feat_2(:,i) = vec / norm_val;
        end
    end

    NCC_matrix = Mat_feat_2' * Mat_feat_1;
    NCC_matrix(NCC_matrix < min_corr) = 0;

    % Debug output: maximum matching value
    fprintf("🔍 Max NCC: %.4f | Matches above threshold: %d\n", ...
        max(NCC_matrix(:)), nnz(NCC_matrix >= min_corr));

    [rows, cols, vals] = find(NCC_matrix);
    [~, idx] = sort(vals, 'descend');
    rows = rows(idx);
    cols = cols(idx);

    cor = [];
    used1 = false(1, num1);
    used2 = false(1, num2);

    for i = 1:length(rows)
        i1 = cols(i); i2 = rows(i);
        if ~used1(i1) && ~used2(i2)
            cor = [cor, [validFtp1(:,i1); validFtp2(:,i2)]];
            used1(i1) = true;
            used2(i2) = true;
        end
        if size(cor,2) >= 38
            break;
        end
    end

    if size(cor,2) < 3
        cor = [];
        return;
    end

    % Remove zero-padding logic to avoid interfering with subsequent processing

    % Visualize matched point pairs
    if do_plot && ~isempty(cor)
        im_overlay = 0.5 * double(I1) + 0.5 * double(I2);
        figure; imshow(im_overlay, []); hold on;
        for i = 1:size(cor,2)
            plot(cor(1,i), cor(2,i), 'ro');
            plot(cor(3,i), cor(4,i), 'go');
            line([cor(1,i), cor(3,i)], [cor(2,i), cor(4,i)], 'Color', 'y');
        end
        title('Matched Corresponding Points'); hold off;
    end
end
