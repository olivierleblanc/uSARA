function [] = util_set_path(param_general)
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
end