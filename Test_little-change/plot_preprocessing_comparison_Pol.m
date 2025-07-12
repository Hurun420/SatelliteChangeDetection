function plot_preprocessing_comparison_Pol(refImg, rawSecondImg, alignedSecondImg)
    % Plot reference, unaligned, and aligned second image side by side
    % with transparency to hide black areas

    figure('Name', 'Preprocessing Comparison', 'NumberTitle', 'off');

    subplot(1, 3, 1);
    h1 = imshow(refImg, []);
    set(h1, 'AlphaData', computeAlpha(refImg));
    title('Reference Image', 'FontWeight', 'bold');

    subplot(1, 3, 2);
    h2 = imshow(rawSecondImg, []);
    set(h2, 'AlphaData', computeAlpha(rawSecondImg));
    title('Second Image (Raw)', 'FontWeight', 'bold');

    subplot(1, 3, 3);
    h3 = imshow(alignedSecondImg, []);
    set(h3, 'AlphaData', computeAlpha(alignedSecondImg));
    title('Second Image (Aligned)', 'FontWeight', 'bold');
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
