function [typ,data] = classification_landuse(patch)

    % image in double for calculations
    patch = im2double(patch);

    r = patch(:,:,1);
    g = patch(:,:,2);
    b = patch(:,:,3);
    grau = rgb2gray(patch);

    % classification factors
    gruen_mean = mean(g(:),'all');
    blau_mean = mean(b(:),'all');
    rot_mean = mean(r(:),'all');
    grau_mean = mean(grau(:),'all');
    helligkeit = mean(grau, 'all');
    kanten = edge(grau, 'Canny');
    kanten_anzahl = sum(kanten(:));
    kanten_density = sum(kanten(:)) / numel(kanten);
    var = std2(grau);
    ent = entropy(grau);
    HSV = rgb2hsv(patch);
    sat = HSV(:,:,2);
    sat = mean(sat(:),'all');
    glcm = graycomatrix(grau, 'Offset', [0 1]);
    stats = graycoprops(glcm, {'Contrast','Homogeneity','Energy'});


    % rules/conditions
    if gruen_mean > 0.27 && gruen_mean > rot_mean && gruen_mean > blau_mean && helligkeit < 0.35 
        typ = 'Forest';
    %elseif blau_mean > 0.4 && helligkeit < 0.6
        %typ = 'Fluss oder See';
    elseif blau_mean > 0.3  && blau_mean > gruen_mean && blau_mean > rot_mean && ent < 4
        typ = 'Sea or Waters';
    elseif helligkeit > 0.5 && blau_mean > gruen_mean && blau_mean > rot_mean
        typ = 'Glacier or Snow';
    elseif grau_mean > 0.3 && sat < 0.3 && kanten_density > 0.1 && blau_mean > 0.6
        typ = 'City';
    elseif rot_mean > 0.35 && rot_mean > gruen_mean && rot_mean > blau_mean  && ent > 5.5 && sat < 0.29
        typ = 'Ground';
    elseif rot_mean > gruen_mean && rot_mean > blau_mean && helligkeit > 0.35    
        typ = 'Desert';
    else
        typ = 'Unknown';
    end

    data = struct('Kantenanzahl', kanten_anzahl, 'grau_mean', grau_mean, 'blau', blau_mean, 'gruen', gruen_mean, 'rot', rot_mean, ...
        'helligkeit', helligkeit, 'varianz', var, 'saturation', sat, 'glcm', glcm, 'entropy', ent, 'density', kanten_density);
end