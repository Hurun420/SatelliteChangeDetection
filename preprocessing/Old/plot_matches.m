function plot_matches(im1, im2, pts1, pts2, savePath)
imCat = cat(2, im1, im2);
figure('Visible','off'); imshow(imCat); hold on;
offset = size(im1, 2);
for i = 1:size(pts1, 2)
    plot(pts1(1,i), pts1(2,i), 'ro', 'MarkerSize', 3);
    plot(pts2(1,i) + offset, pts2(2,i), 'go', 'MarkerSize', 3);
    line([pts1(1,i), pts2(1,i) + offset], [pts1(2,i), pts2(2,i)], ...
        'Color', [0, 1, 0, 0.3]);
end
saveas(gcf, savePath); close;
end
