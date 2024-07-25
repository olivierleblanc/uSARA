function imager2(path_uv_data, param_general, runID)
    
    fprintf('\nINFO: uv data file %s', path_uv_data);

    %% setting paths
    addpath([param_general.dirProject, filesep, 'lib', filesep, 'lib_utils', filesep]);
    util_set_path(param_general);

    % set result directory
    util_set_result_dir(path_uv_data, param_general, runID);

    %% Ground truth image
    gdth_img = fitsread(param_general.groundtruth);
    imSize = size(gdth_img);
    figure(); imagesc(abs(gdth_img)); colorbar; title('Ground truth image');

    %% Load uv-coverage data: u, v, w, na, nTimeSamples
    param_uv = util_set_param_uv(path_uv_data);

    % % Set pixel size
    % imPixelSize = util_set_pixel_size(param_general, path_uv_data);

    %% Set ROP parameters
    param_ROP = util_gen_ROP(param_uv.na,... 
                            param_general.Nv,...
                            param_uv.nTimeSamples,... 
                            param_general.rv_type,... 
                            param_general.ROP_type,...
                            param_general.Nm);

    resolution_param.superresolution = param_general.superresolution;

    %% visibility operator and its adjoint
    [vis_op, adjoint_vis_op] = ops_visibility(param_uv, imSize, resolution_param, param_ROP);

    %% Generate the noiseless visibilities
    vis = vis_op(gdth_img);

    % %% perform the adjoint test
    % vis_op_vec = @(x) ( vis_op(reshape(x, imSize)) ); 
    % adjoint_vis_op_vec = @(vis) reshape(adjoint_vis_op(vis), [prod(imSize), 1]);
    % vis_op_shape = struct();
    % vis_op_shape.in = [prod(imSize), 1];
    % vis_op_shape.out = size(vis);
    % adjoint_test(vis_op_vec, adjoint_vis_op_vec, vis_op_shape);

    % Parameters for visibility weighting
    weighting_on = param_general.flag_data_weighting;
    if weighting_on
        % load(path_uv_data, 'nWimag')
        %% Call the function to generate the weights
    else
        nWimag = ones(length(vis), 1);
    end

    % noise vector
    noiselevel = 'drheuristic'; % possible values: `drheuristic` ; `inputsnr`
    [tau, noise, param_noise] = util_gen_noise(vis_op, adjoint_vis_op, imSize, vis, noiselevel, nWimag, param_general, path_uv_data, gdth_img);

    % add noise to the visibilities (see in util_gen_noise.m why)
    vis = vis + noise;

    if weighting_on
        % nW = (1 / tau) * ones(na^2*nTimeSamples,1);
        nW = (1 / tau) * nWimag;
        [W, ~] = op_vis_weighting(nW);
        vis = W(vis);
    end

    % (eventually) apply ROPs 
    if param_ROP.use_ROP
        [D, ~] = op_ROP(param_ROP);
        y = D(vis);
    else
        y = vis;
    end

    % Measurement operator and its adjoint
    [measop, adjoint_measop] = ops_measop(vis_op, adjoint_vis_op, weighting_on, tau, param_ROP);

    % %% perform the adjoint test
    % measop_vec = @(x) ( measop(reshape(x, imSize)) ); 
    % adjoint_measop_vec = @(y) reshape(adjoint_measop(y), [prod(imSize), 1]);
    % measop_shape = struct();
    % measop_shape.in = [prod(imSize), 1]
    % measop_shape.out = size(y);
    % adjoint_test(measop_vec, adjoint_measop_vec, measop_shape);

    %% Compute back-projected data: dirty image
    dirty = adjoint_measop(y);
    figure(); imagesc(abs(dirty)); colorbar; title('Dirty image');

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

    %% Set parameters for imaging and algorithms
    param_algo = util_set_param_algo(param_general);
    param_imaging = util_set_param_imaging(param_general, param_algo.heuRegParamScale);
    
    %% save normalised dirty image, PSF and GT
    fitswrite(single(PSF), fullfile(param_imaging.resultPath, 'PSF.fits')); clear PSF;
    fitswrite(single(dirty./PSFPeak), fullfile(param_imaging.resultPath, 'dirty.fits')); 
    fitswrite(gdth_img, fullfile(param_imaging.resultPath, 'GT.fits')) % ground truth
    
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
        util_save_results(MODEL, RESIDUAL, PSFPeak, param_imaging);

        %% Final metrics
        util_final_metrics(gdth_img, dirty, MODEL, RESIDUAL, PSFPeak, param_noise);
    end
    fprintf('\nTHE END\n')

end