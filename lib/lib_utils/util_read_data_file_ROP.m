function [y, alpha, beta, flag_data_weighting] = util_read_data_file(dataFilename, flag_data_weighting)

    dataloaded = load(dataFilename, 'y', 'alpha', 'beta');
    
    fprintf('\nINFO: imaging weights will not be applied.');
    flag_data_weighting = false;
    y = double(dataloaded.y(:));

    alpha = double(dataloaded.alpha);
    beta = double(dataloaded.beta);

end