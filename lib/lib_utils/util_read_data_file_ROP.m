function [y, alpha, beta, flag_data_weighting] = util_read_data_file(dataFilename, flag_data_weighting)

    try dataloaded = load(dataFilename, 'y', 'nW', 'alpha', 'beta', 'nWimag');
    catch
        dataloaded = load(dataFilename, 'y', 'alpha', 'beta', 'nW');
    end
    
    if flag_data_weighting && isfield(dataloaded, 'nWimag') && ~isempty(dataloaded.nWimag)
        y = double(dataloaded.y(:)) .* double(dataloaded.nW(:)) .* double(dataloaded.nWimag(:));
    else
        fprintf('\nINFO: imaging weights will not be applied.');
        flag_data_weighting = false;
        y = double(dataloaded.y(:)) .* double(dataloaded.nW(:));
    end

    alpha = double(dataloaded.alpha);
    beta = double(dataloaded.beta);

end