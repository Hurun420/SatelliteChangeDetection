function result = compute_landuse(alignedImagesRGB, tileParam)

if numel(alignedImagesRGB) < 2
    result.text = 'Not enough images selected.';
    return;
end

img1 = alignedImagesRGB{1};
img2 = alignedImagesRGB{2};


% split in small image patches
[H, W, ~] = size(img1);
tileSize = floor(H / tileParam);  %%% change nenner in GUI for precision 10 up to 50 maybe 75 %%%

% Loop for tiles
all_changes = {};
for y = 1:tileSize:H-tileSize+1
    for x = 1:tileSize:W-tileSize+1
        % extract tiles
        patch1 = img1(y:y+tileSize-1, x:x+tileSize-1, :);
        patch2 = img2(y:y+tileSize-1, x:x+tileSize-1, :);
        
        % analyse tiles
        [typ1, data1] = classification_landuse(patch1);
        [typ2, data2] = classification_landuse(patch2);
        
        % detect changes
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

% Output of the most changes
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


 
