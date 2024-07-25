function [] = util_save_results(MODEL, RESIDUAL, PSFPeak, param_imaging)
    
    fitswrite(MODEL, fullfile(param_imaging.resultPath, 'usara_model_image.fits')) % model estimate
    fitswrite(RESIDUAL, fullfile(param_imaging.resultPath, 'usara_residual_dirty_image.fits')) % back-projected residual data
    fitswrite(RESIDUAL ./ PSFPeak, fullfile(param_imaging.resultPath, 'usara_normalised_residual_dirty_image.fits')) % normalised back-projected residual data
    fprintf("\nFits files saved.")
end