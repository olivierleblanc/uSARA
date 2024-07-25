function [y, param_ROP, flag_data_weighting] = util_read_data_file(dataFilename, flag_data_weighting)

    % Check if ROP were applied
    try 
        dataloaded = load(dataFilename, 'param_ROP');
        param_ROP = dataloaded.param_ROP;
    catch
        param_ROP = [];
    end

    % Load measurement data and visibility weighting
    dataloaded = load(dataFilename, 'y', 'nW');

    % If no ROP, apply the weighting to all visibilities
    if isempty(param_ROP) 
        y = double(dataloaded.y(:)).* double(dataloaded.nW(:));
    else % If ROP, just apply the normalization scalar
        y = double(dataloaded.y(:)).* double(dataloaded.nW(1));
    end

    % Check if imaging weights were applied
    try 
        dataloaded = load(dataFilename, 'nWimag');
    catch
        dataloaded.nWimag = [];
    end 

    if flag_data_weighting && isfield(dataloaded, 'nWimag') && ~isempty(dataloaded.nWimag)
        y = y .* double(dataloaded.nWimag(:));
    else
        fprintf('\nINFO: imaging weights will not be applied.');
        flag_data_weighting = false;
    end

end