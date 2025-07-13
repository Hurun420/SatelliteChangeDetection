function result = compute_landuse(alignedImagesRGB)

% Input Arguments:
%   alignedImagesRGB : cell array of images (e.g., {img1, img2, ...}), sorted by time.
%       Images must be pre-aligned and of the same size.
%
% Output:
%   result.text: string output of the transformation type

% split in small image patches
[H, W, ~] = size(img1);
tileSize = floor(H/10);  % Denominator splits the image in tiles

% Loop for tiles
all_changes = {};
for y = 1:tileSize:H-tileSize+1
    for x = 1:tileSize:W-tileSize+1
        % extract tiles
        patch1 = img1(y:y+tileSize-1, x:x+tileSize-1, :);
        patch2 = img2(y:y+tileSize-1, x:x+tileSize-1, :);
        
        % classification of tiles
        [typ1, data1] = classification_landuse(patch1);
        [typ2, data2] = classification_landuse(patch2);
        
        % detect and name transformation
        if ~strcmp(typ1, typ2)
            ver = classification_change_landuse(typ1, typ2);
            if ver ~= "none"
                % fprintf("Change in Area (%d,%d): %s → %s → %s\n", ...
                    % x, y, typ1, typ2,ver);
                all_changes{end+1} = char(ver);
            end
        end
    end

end

% Output issue of the most frequently occurring transformation
if ~isempty(all_changes)
    [uni, ~, idx] = unique(all_changes);
    number = accumarray(idx(:), 1);
    [~, maxIdx] = max(number);
    result.text = uni{maxIdx};

    % fprintf("Most frequent change in the image: %s\n", text); 
else
    % fprintf("No changes in the image.\n"); 
    result.text = 'No changes.';
end

% fprintf("\nAnalysis done.\n");


 
