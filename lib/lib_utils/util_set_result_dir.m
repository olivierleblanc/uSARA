function [] = util_set_result_dir(param_general)
    % Set the result directory for the output files

    if ~isfield(param_general, 'resultPath') || isempty(param_general.resultPath)
        param_general.resultPath = fullfile(param_general.dirProject, 'results');
    end
    if ~exist(param_general.resultPath, 'dir') 
        mkdir(param_general.resultPath)
    end

    % src/test name tag for outputs filename
    if ~isfield(param_general, 'srcName') || isempty(param_general.srcName)
        [~, param_general.srcname, ~] = fileparts(path_uv_data);        
    end
    if ~isempty(runID)
        param_general.srcname = [param_general.srcname, '_runID_', num2str(runID)];
    end

end