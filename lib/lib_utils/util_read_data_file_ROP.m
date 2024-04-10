function [y, alpha, beta, flag_data_weighting] = util_read_data_file_ROP(dataFilename, flag_data_weighting)

    dataloaded = load(dataFilename, 'y', 'alpha', 'beta', 'nW');
    
    fprintf('\nINFO: imaging weights will not be applied.');
    flag_data_weighting = false;
    y = double(dataloaded.y(:)) .* double(dataloaded.nW(1));

    alpha = double(dataloaded.alpha);
    beta = double(dataloaded.beta);

end