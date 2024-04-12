function imager2(path_uv_data, param_general, runID)
    
    fprintf('\nINFO: uv data file %s', path_uv_data);

    %% setting paths
    util_set_path(param_general);

    % set result directory
    util_set_result_dir(param_general);

    %% Ground truth image
    gdth_img = fitsread(param_general.groundtruth);
    imSize = size(gdth_img);

    %% Load uv-coverage data
    % [u, v, w, na] = generate_uv_coverage(frequency, nTimeSamples, obsTime, telescope, use_ROP);
    %%% TODO %%%

    % Set pixel size
    imPixelSize = util_set_pixel_size(param_general, path_uv_data);

    %% Set ROP parameters
    ROP_param = util_gen_ROP(na,... 
                            param_general.Npb,...
                            nTimeSamples,... 
                            param_general.rvtype,... 
                            param_general.ROP_type);

    %% measurement operator and its adjoint
    [raw_measop, adjoint_raw_measop] = ops_raw_measop(u,v,w, imSize, resolution_param, ROP_param);

    % %% perform the adjoint test
    % measop_vec = @(x) ( measop(reshape(x, imSize)) ); 
    % adjoint_raw_measop_vec = @(y) reshape(adjoint_raw_measop(y), [prod(imSize), 1]);
    % measop_shape = struct();
    % measop_shape.in = [prod(imSize), 1]
    % measop_shape.out = size(y);
    % adjoint_test(raw_measop_vec, adjoint_raw_measop_vec, measop_shape);

    % Compute operator's spectral norm 
    fprintf('\nComputing spectral norm of the measurement operator..')
    [param_general.measOpNorm,~] = op_norm(measop, adjoint_measop, imSize, 1e-6, 500, 0);
    fprintf('\nINFO: measurement op norm %f', param_general.measOpNorm);
    
    % Compute PSF 
    imDimy = imSize(1); 
    imDimx = imSize(2);
    dirac = sparse(floor(imDimy./2) + 1, floor(imDimx./2) + 1, 1, imDimy, imDimx);
    PSF = adjoint_measop(measop(full(dirac)));
    PSFPeak = max(PSF,[],'all');  clear dirac;
    fprintf('\nINFO: normalisation factor in RI, PSF peak value: %g', PSFPeak);

    %% data noise settings
    noiselevel = 'drheuristic'; % possible values: `drheuristic` ; `inputsnr`
    noise_param = struct();
    noise_param.noiselevel = noiselevel;
    switch noiselevel
        case 'drheuristic'
            % dynamic range of the ground truth image
            noise_param.targetDynamicRange = 255; 
        case 'inputsnr'
            % user-specified input signal to noise ratio
            noise_param.isnr = 40; % in dB
    end

    %% Generate noisy measurement data

    % noise vector
    weighting_on = param_general.flag_data_weighting;
    [tau, noise] = util_gen_noise(raw_measop, adjoint_raw_measop, imSize, meas, weighting_on, noise_param);
    
    y = raw_measop(gdth_img) + noise;

    %% Eventually switch visibility weighting on
    nW = tau * ones(na^2*nTimeSamples,1);
    if weighting_on
        [W, Wt] = op_vis_weighting(nW);
        y = W(y);
        [measop, adjoint_measop] = ops_measop(raw_measop, adjoint_raw_measop, W, Wt);
    end

    %% Compute back-projected data: dirty image
    dirty = adjoint_measop(y);

    figure(); imagesc(abs(dirty)); colorbar; title('Dirty image');

    %% Set parameters for imaging and algorithms
    param_algo = util_set_param_algo(param_general);
    param_imaging = util_set_param_imaging(param_general, param_algo.heuRegParamScale);
    
    %% save normalised dirty image & PSF
    fitswrite(single(PSF), fullfile(param_imaging.resultPath, 'PSF.fits')); clear PSF;
    fitswrite(single(dirty./PSFPeak), fullfile(param_imaging.resultPath, 'dirty.fits')); 
    
    %% INFO
    fprintf("\n________________________________________________________________\n")
    disp('param_algo:')
    disp(param_algo)
    disp('param_imaging:')
    disp(param_imaging)
    fprintf("________________________________________________________________\n")

    if param_imaging.flag_imaging
        %% uSARA Imaging
        [MODEL,RESIDUAL] = usara(dirty, measop, adjoint_measop, param_imaging, param_algo);

        %% Save final results
        fitswrite(MODEL, fullfile(param_imaging.resultPath, 'usara_model_image.fits')) % model estimate
        fitswrite(RESIDUAL, fullfile(param_imaging.resultPath, 'usara_residual_dirty_image.fits')) % back-projected residual data
        fitswrite(RESIDUAL ./ PSFPeak, fullfile(param_imaging.resultPath, 'usara_normalised_residual_dirty_image.fits')) % normalised back-projected residual data
        fprintf("\nFits files saved.")

        %% Final metrics
        fprintf('\nINFO: The standard deviation of the final residual dirty image %g', std(RESIDUAL, 0, 'all'))
        fprintf('\nINFO: The standard deviation of the normalised final residual dirty image %g', std(RESIDUAL, 0, 'all') / PSFPeak)
        fprintf('\nINFO: The ratio between the norm of the residual and the dirty image: ||residual|| / || dirty || =  %g', norm(RESIDUAL(:))./norm(dirty(:)))

        rsnr = 20*log10( norm(gdth_img(:)) / norm(MODEL(:) - gdth_img(:)) );
        fprintf('\nINFO: The signal-to-noise ratio of the final reconstructed image %.2f dB', rsnr)
    end
    fprintf('\nTHE END\n')

    end
