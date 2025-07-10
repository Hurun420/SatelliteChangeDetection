function plot_preprocessing_comparison_Pol(refImg, rawSecondImg, alignedSecondImg)
    % Plot reference, unaligned, and aligned second image side by side
    %
    % Input images should be grayscale (2D) or RGB (3D)

    figure('Name', 'Preprocessing Comparison', 'NumberTitle', 'off');

    subplot(1, 3, 1);
    imshow(refImg, []);
    title('Reference Image', 'FontWeight', 'bold');

    subplot(1, 3, 2);
    imshow(rawSecondImg, []);
    title('Second Image (Raw)', 'FontWeight', 'bold');

    subplot(1, 3, 3);
    imshow(alignedSecondImg, []);
    title('Second Image (Aligned)', 'FontWeight', 'bold');
end
