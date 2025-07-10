function plot_image_pair_Pol(I1, I2, title1, title2)
    % PLOT_IMAGE_PAIR Display two grayscale or RGB images side by side.
    %
    % Usage:
    %   plot_image_pair(I1, I2)
    %   plot_image_pair(I1, I2, 'Ref', 'Target')
    
    if nargin < 3
        title1 = 'Image 1';
        title2 = 'Image 2';
    end

    figure;
    subplot(1, 2, 1);
    imshow(I1, []);
    title(title1, 'FontWeight', 'bold');

    subplot(1, 2, 2);
    imshow(I2, []);
    title(title2, 'FontWeight', 'bold');
end
