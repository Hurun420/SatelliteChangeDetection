% recognizing transformations when classification is different
function ver = classification_change_landuse(von, nach)
    if strcmp(von, 'Forest') && strcmp(nach, 'City')
        ver = "Urbanization/Deforestation";
    elseif strcmp(von, 'Forest') && strcmp(nach, 'Ground')
        ver = "Deforestation or Tree loss";
    elseif strcmp(von, 'Glacier or Snow') && strcmp(nach, 'Sea or Waters')
        ver = "Melt of glacier or snow";
    elseif strcmp(von, 'Glacier or Snow') && strcmp(nach, 'Forest')
        ver = "Melt of glacier or snow";    
    elseif strcmp(von, 'Glacier or Snow') && strcmp(nach, 'Desert')
        ver = "Melt of glacier or snow";  
    elseif strcmp(von, 'Ground') && strcmp(nach, 'City')
        ver = "New Building";
    elseif strcmp(von, 'Desert') && strcmp(nach, 'City')
        ver = "New Building/Urbanization";    
    elseif strcmp(von, 'Sea or Waters') && strcmp(nach, 'Ground')
        ver = "Loss of Water";
    elseif strcmp(von, 'Sea or Waters') && strcmp(nach, 'Forest')
        ver = "Loss of Water";
    elseif strcmp(von, 'Glacier or Snow') && strcmp(nach, 'Ground')
        ver = "Melt of Glacier or Snow";
    elseif strcmp(von, 'City') && strcmp(nach, 'Forest')
        ver = "Renaturing?";
    elseif strcmp(von, 'Forest') && strcmp(nach, 'Sea or Waters')
        ver = "Accumulation of water";
    elseif strcmp(von, 'Ground') && strcmp(nach, 'Sea or Waters')
        ver = "Accumulation of water";    
    else
        ver = "none";
    end
end    
