folder = pwd;
files = dir(fullfile(folder, 'frame_*.png'));

for i = 1:length(files)
    oldName = files(i).name;

    newName = regexprep(oldName, 'frame_(\d+)_.*', 'frame_$1.png');

    if ~strcmp(oldName, newName)
        movefile(fullfile(folder, oldName), fullfile(folder, newName));
        fprintf('Renamed: %s -> %s\n', oldName, newName);
    end
end