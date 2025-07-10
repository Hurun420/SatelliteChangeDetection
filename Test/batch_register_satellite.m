function batch_register_satellite(imageFolder)
    % 获取所有 .jpg 文件并排序
    imageFiles = dir(fullfile(imageFolder, '*.jpg'));
    if isempty(imageFiles)
        error('No .jpg images found in the folder!');
    end

    [~, idx] = sort({imageFiles.name});
    imageList = imageFiles(idx);

    % 创建输出文件夹
    outGrayFolder = fullfile(imageFolder, 'output', 'aligned_gray');
    outRGBFolder  = fullfile(imageFolder, 'output', 'aligned_rgb');
    outDiffFolder = fullfile(imageFolder, 'output', 'comparison');
    outMatFolder  = fullfile(imageFolder, 'output', 'aligned_mat');

    if ~exist(outGrayFolder, 'dir'), mkdir(outGrayFolder); end
    if ~exist(outRGBFolder, 'dir'), mkdir(outRGBFolder); end
    if ~exist(outDiffFolder, 'dir'), mkdir(outDiffFolder); end
    if ~exist(outMatFolder, 'dir'), mkdir(outMatFolder); end

    % 最早图像作为参考图
    refPath = fullfile(imageList(1).folder, imageList(1).name);
    refRGB = imread(refPath);
    refGray = im2gray(refRGB);

    for i = 1:length(imageList)
        curPath = fullfile(imageList(i).folder, imageList(i).name);
        curRGB = imread(curPath);
        curGray = im2gray(curRGB);

        if i == 1
            % 保存参考图
            imwrite(refGray, fullfile(outGrayFolder, 'aligned_ref.png'));
            imwrite(refRGB,  fullfile(outRGBFolder,  'aligned_ref_rgb.png'));
            continue;
        end

        % 尝试 SURF + fallback Harris
        try
            [tform, pts1, pts2] = register_with_SURF(refGray, curGray);
        catch
            warning('SURF failed, fallback to Harris: %s', imageList(i).name);
            [tform, pts1, pts2] = register_with_Harris(refGray, curGray);
        end

        % 配准
        alignedRGB  = imwarp(curRGB, tform, 'OutputView', imref2d(size(refGray)));
        alignedGray = imwarp(curGray, tform, 'OutputView', imref2d(size(refGray)));

        % 文件名
        [~, name, ~] = fileparts(imageList(i).name);

        % 保存图像
        imwrite(alignedGray, fullfile(outGrayFolder, ['aligned_' name '.png']));
        imwrite(alignedRGB,  fullfile(outRGBFolder,  ['aligned_' name '.png']));

        % 保存差异对比图
        comp = [refRGB, alignedRGB];
        imwrite(comp, fullfile(outDiffFolder, ['compare_' name '.png']));

        % 保存 mat 数据
        save(fullfile(outMatFolder, ['aligned_' name '.mat']), ...
            'alignedGray', 'alignedRGB', 'tform', 'pts1', 'pts2');
        
        fprintf('✅ Registered: %s\n', imageList(i).name);
    end
end
