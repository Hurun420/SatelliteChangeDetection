function plot_image_pair_Pol(I1, I2, title1, title2)
    % Display two grayscale or RGB images side by side with transparency for black areas

    if nargin < 3
        title1 = 'Image 1';
        title2 = 'Image 2';
    end

    figure;

    % --- Left image ---
    subplot(1, 2, 1);
    h1 = imshow(I1, []);
    alpha1 = computeAlpha(I1);
    set(h1, 'AlphaData', alpha1);
    title(title1, 'FontWeight', 'bold');

    % --- Right image ---
    subplot(1, 2, 2);
    h2 = imshow(I2, []);
    alpha2 = computeAlpha(I2);
    set(h2, 'AlphaData', alpha2);
    title(title2, 'FontWeight', 'bold');
end

function alpha = computeAlpha(img)
    % Compute alpha mask for grayscale or RGB image
    if ndims(img) == 3
        alpha = sum(img, 3) > 0.01;
    else
        alpha = img > 0.01;
    end
    alpha = double(alpha);
end
