function [] = util_final_metrics(gdth_img, dirty, MODEL, RESIDUAL, PSFPeak, param_noise)
    
    fprintf('\nINFO: The standard deviation of the final residual dirty image %g', std(RESIDUAL, 0, 'all'))
    fprintf('\nINFO: The standard deviation of the normalised final residual dirty image %g', std(RESIDUAL, 0, 'all') / PSFPeak)
    fprintf('\nINFO: The ratio between the norm of the residual and the dirty image: ||residual|| / || dirty || =  %g', norm(RESIDUAL(:))./norm(dirty(:)))

    rsnr = 20*log10( norm(gdth_img(:)) / norm(MODEL(:) - gdth_img(:)) );
    fprintf('\nINFO: The signal-to-noise ratio of the final reconstructed image %.2f dB', rsnr)
    if param_noise.expo_gdth 
        gdth_expo_log = util_log_im(gdth_img, param_noise.targetDynamicRange);
        rec_log = util_log_im(MODEL, param_noise.targetDynamicRange);
        rsnr_log = 20*log10( norm(gdth_expo_log(:)) / norm(rec_log(:) - gdth_expo_log(:)) );
        fprintf('\nINFO: The log signal-to-noise ratio of the final reconstructed image %.2f dB', rsnr_log)
    end
end