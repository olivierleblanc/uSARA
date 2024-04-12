function[imPixelSize] = util_set_pixel_size(param_general, path_uv_data)
    % Set the image pixel size

    if isempty(param_general.imPixelSize)
        maxProjBaseline = double( load(path_uv_data, 'maxProjBaseline').maxProjBaseline );
        spatialBandwidth = 2 * maxProjBaseline;
        imPixelSize = (180 / pi) * 3600 / (param_general.superresolution * spatialBandwidth);
        fprintf('\nINFO: default pixelsize: %g arcsec, that is %.2f x nominal resolution',...
            imPixelSize, param_general.superresolution);
    else
        imPixelSize = param_general.imPixelSize;
        fprintf('\nINFO: user specified pixelsize: %g arcsec,', imPixelSize)
    end
end