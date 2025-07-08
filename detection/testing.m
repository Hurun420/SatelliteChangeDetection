imgs = cell(1,10);
for i = 1:size(imgs,2)
    if i < 10
        filename = sprintf('river/frame_0%d.png',i);
    else 
        filename = sprintf('river/frame_%d.png', i);
    end
    imgs{i} = load_image(filename);
end

options.abs_threshold = 0.2;

res = detect_changes(imgs, 'absolute', options);

% save visualization into a GIF
filename = 'tests/timelapse_absolute_differences.gif';
for idx = 1:length(res.visual_rgb)
    [A, map] = rgb2ind(res.visual_rgb{idx}, 256);
    if idx == 1
        imwrite(A, map, filename, 'gif', 'LoopCount', Inf, 'DelayTime', 0.2);
    else
        imwrite(A, map, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.2);
    end    
end

function img_rgb = load_image(filename)
    [img, map] = imread(filename);
    img_rgb = ind2rgb(img, map);
end