function imager(pathData, imPixelSize, imDimx, imDimy, param_general, runID)
    
    imSize = [imDimy, imDimx];

    fprintf('\nINFO: measurement file %s', pathData);
    fprintf('\nINFO: Image size %d x %d', imDimx, imDimy)

    %% setting paths
    dirProject = param_general.dirProject;
    fprintf('\nINFO: Main project dir. is %s', dirProject);
    
    % src & lib codes
    addpath([dirProject, filesep, 'lib', filesep, 'lib_imaging', filesep]);
    addpath([dirProject, filesep, 'lib', filesep, 'lib_utils', filesep]);
    addpath([dirProject, filesep, 'lib', filesep, 'RI-measurement-operator', filesep, 'nufft']);
    addpath([dirProject, filesep, 'lib', filesep, 'RI-measurement-operator', filesep, 'irt', filesep, 'utilities']);
    addpath([dirProject, filesep, 'lib', filesep, 'RI-measurement-operator', filesep, 'lib', filesep, 'utils']);
    addpath([dirProject, filesep, 'lib', filesep, 'RI-measurement-operator', filesep, 'lib', filesep, 'operators']);
    addpath([dirProject, filesep, 'lib', filesep, 'RI-measurement-operator', filesep, 'lib', filesep, 'operators', filesep, 'ROP']);
    addpath([dirProject, filesep, 'lib', filesep, 'RI-measurement-operator', filesep, 'lib', filesep, 'ddes_utils']);
    addpath([dirProject, filesep, 'lib', filesep, 'SARA-dictionary', filesep, 'src']);

    % set result directory
    if ~isfield(param_general, 'resultPath') || isempty(param_general.resultPath)
        param_general.resultPath = fullfile(param_general.dirProject, 'results');
    end
    if ~exist(param_general.resultPath, 'dir') 
        mkdir(param_general.resultPath)
    end

    % src/test name tag for outputs filename
    if ~isfield(param_general, 'srcName') || isempty(param_general.srcName)
        [~, param_general.srcname, ~] = fileparts(pathData);        
    end
    if ~isempty(runID)
        param_general.srcname = [param_general.srcname, '_runID_', num2str(runID)];
    end

    %% Measurements & operators
    % Load data
    [DATA, param_ROP, param_general.flag_data_weighting] = util_read_data_file(pathData, param_general.flag_data_weighting);

    % Set pixel size
    if isempty(imPixelSize)
        maxProjBaseline = double( load(pathData, 'maxProjBaseline').maxProjBaseline );
        spatialBandwidth = 2 * maxProjBaseline;
        imPixelSize = (180 / pi) * 3600 / (param_general.superresolution * spatialBandwidth);
        fprintf('\nINFO: default pixelsize: %g arcsec, that is %.2f x nominal resolution',...
            imPixelSize, param_general.superresolution);
    else
        fprintf('\nINFO: user specified pixelsize: %g arcsec,', imPixelSize)
    end
    
    % Set parameters releated to operators
    [param_nufft, param_wproj] = util_set_param_operator(param_general, imSize, imPixelSize);

    % Generate nufft operators
    [A, At, G, W, nWimag] = util_gen_meas_op_comp_single(pathData, imSize, ...
        param_general.flag_data_weighting, param_nufft, param_wproj);

    %% define the measurememt operator & its adjoint
    if isempty(param_ROP) % only visibilities

        [measop, adjoint_measop] = util_syn_meas_op_single(A, At, G, W, []);

    else % combined ROP and visibilities

        [measop2, adjoint_measop2] = util_syn_meas_op_single(A, At, G, W, []);

        %% compute ROP operator
        [D, Dt] = op_ROP(param_ROP);
        
        measop = @(x) ( D(measop2(reshape(x, [imDimy, imDimx]))) ) ; 
        adjoint_measop = @(y) adjoint_measop2(Dt(y));
    end

    % %% perform the adjoint test
    % measop_vec = @(x) ( measop(reshape(x, [imDimy, imDimx])) ); 
    % adjoint_measop_vec = @(y) reshape(adjoint_measop(y), [imDimy*imDimx, 1]);
    % measop_shape = struct();
    % measop_shape.in = [imDimy*imDimx, 1]
    % measop_shape.out = size(DATA);
    % adjoint_test(measop_vec, adjoint_measop_vec, measop_shape);

    % Compute operator's spectral norm 
    fprintf('\nComputing spectral norm of the measurement operator..')
    [param_general.measOpNorm,~] = op_norm(measop, adjoint_measop, [imDimy,imDimx], 1e-6, 500, 0);
    fprintf('\nINFO: measurement op norm %f', param_general.measOpNorm);
    
    % Compute PSF 
    dirac = sparse(floor(imDimy./2) + 1, floor(imDimx./2) + 1, 1, imDimy, imDimx);
    PSF = adjoint_measop(measop(full(dirac)));
    PSFPeak = max(PSF,[],'all');  clear dirac;
    fprintf('\nINFO: normalisation factor in RI, PSF peak value: %g', PSFPeak);

    %% Compute back-projected data: dirty image
    dirty = adjoint_measop(DATA);

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
        if isfield(param_imaging,'groundtruth') && ~isempty(param_imaging.groundtruth) && isfile(param_imaging.groundtruth)
            gdth_img = fitsread(param_imaging.groundtruth);
            rsnr = 20*log10( norm(gdth_img(:)) / norm(MODEL(:) - gdth_img(:)) );
            fprintf('\nINFO: The signal-to-noise ratio of the final reconstructed image %.2f dB', rsnr)
        end
    end
    fprintf('\nTHE END\n')

    end
