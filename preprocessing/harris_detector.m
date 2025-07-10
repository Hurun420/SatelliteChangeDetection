function [points] = harris_detector(img, varargin)
% HARRIS_DETECTOR  Detect Harris corners in a grayscale image.
% 返回角点的 [x, y] 坐标（最大 max_features 个）

% 参数解析
p = inputParser;
addParameter(p, 'tau', 1e5);
addParameter(p, 'segment_length', 15);
addParameter(p, 'k', 0.05);
addParameter(p, 'do_plot', false);
addParameter(p, 'max_features', 500);
addParameter(p, 'margin', 10);
addParameter(p, 'auto_adjust_tau', true);
parse(p, varargin{:});

% 参数赋值
tau = p.Results.tau;
segment_length = p.Results.segment_length;
k = p.Results.k;
do_plot = p.Results.do_plot;
max_features = p.Results.max_features;
margin = p.Results.margin;
auto_adjust = p.Results.auto_adjust_tau;

% 图像转 double
img = double(img);

% 高斯滤波器
sigma = segment_length / 5;
g = fspecial('gaussian', [segment_length, segment_length], sigma);

% 计算导数
[Ix, Iy] = gradient(img);
Ix2 = conv2(Ix.^2, g, 'same');
Iy2 = conv2(Iy.^2, g, 'same');
Ixy = conv2(Ix.*Iy, g, 'same');

% Harris 响应
H = (Ix2 .* Iy2 - Ixy.^2) - k * (Ix2 + Iy2).^2;
H = H / max(H(:));  % 归一化

% 动态调整阈值
H_mask = (H > tau);
min_features = 50;
tau_min = 1e-6;
scale = 0.5;

while auto_adjust && sum(H_mask(:)) < min_features && tau > tau_min
    tau = tau * scale;
    H_mask = (H > tau);
end

if sum(H_mask(:)) == 0
    warning('Harris detector found 0 features after thresholding (tau=%.2e)', tau);
    points = zeros(0, 2);
    return;
end

% 提取坐标
[y, x] = find(H_mask);
scores = H(H_mask);
points = [x, y, scores];

% 去除边界
valid = x > margin & x < size(img,2)-margin & ...
        y > margin & y < size(img,1)-margin;
points = points(valid, :);

% 排序并截取前 max_features 个
points = sortrows(points, -3);
points = points(1:min(end, max_features), 1:2);

% 可视化
if do_plot
    figure; imshow(uint8(img)); hold on;
    plot(points(:,1), points(:,2), 'r+');
    title(sprintf('Harris Points (tau=%.1e, %d points)', tau, size(points,1)));
end
end