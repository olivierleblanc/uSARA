function run_imager2(json_filename, NameValueArgs)
% Read uv-coverage data in .mat file, then generate measurement w/wo ROPs and run imager
%  & Run imager
% Parameters
% ----------
% json_filename : string
%     Name of the .json configuration file.
% NameValueArgs : 
% Returns
% -------
% None
%

arguments
    json_filename (1,:) {mustBeFile}
    NameValueArgs.srcName (1,:) {mustBeText}
    NameValueArgs.uvFile (1,:) {mustBeFile}
    NameValueArgs.resultPath (1,:) {mustBeText}
    NameValueArgs.superresolution (1,1) {mustBePositive}
    NameValueArgs.groundtruth (1,:) {mustBeFile}
    NameValueArgs.runID (1,1) {mustBeNonnegative, mustBeInteger}
end

%% Parsing json file
clc
fid = fopen(json_filename);
raw = fread(fid, inf);
str = char(raw');
fclose(fid);
config = jsondecode(str);

% main input
main = cell2struct(struct2cell(config{1, 1}.main), fieldnames(config{1, 1}.main));
% overwrite fields in main if available
if isfield(NameValueArgs, 'srcName')
    main.srcName = NameValueArgs.srcName;
end
if isfield(NameValueArgs, 'uvFile')
    main.uvFile = NameValueArgs.uvFile;
end
if isfield(NameValueArgs, 'resultPath')
    main.resultPath = NameValueArgs.resultPath;
end
if isfield(NameValueArgs, 'superresolution')
    main.superresolution = NameValueArgs.superresolution;
end
if isfield(NameValueArgs, 'groundtruth')
    main.groundtruth = NameValueArgs.groundtruth;
end
if isfield(NameValueArgs, 'runID')
    main.runID = NameValueArgs.runID;
end
% if isempty(main.runID)
%     main.runID = 0;
% end
disp(main)

% flag
param_flag = cell2struct(struct2cell(config{2, 1}.flag), fieldnames(config{2, 1}.flag));
disp(param_flag)

% other parameters
param_other = cell2struct(struct2cell(config{2, 1}.other), fieldnames(config{2, 1}.other));
disp(param_other)

% solver, usara
param_solver = cell2struct(struct2cell(config{3, 1}.usara), fieldnames(config{3, 1}.usara));
param_solver_default = cell2struct(struct2cell(config{3, 1}.usara_default), fieldnames(config{3, 1}.usara_default));
param_solver = cell2struct([struct2cell(param_solver); struct2cell(param_solver_default)], ...
    [fieldnames(param_solver); fieldnames(param_solver_default)]);
disp(param_solver)

% ROP param
param_ROP = cell2struct(struct2cell(config{4, 1}.rop), fieldnames(config{4, 1}.rop));

% full param list
param_general = cell2struct([struct2cell(param_flag); struct2cell(param_other); struct2cell(param_solver); struct2cell(param_ROP)], ...
    [fieldnames(param_flag); fieldnames(param_other); fieldnames(param_solver); fieldnames(param_ROP)]);
param_general.resultPath = main.resultPath;
param_general.srcName = main.srcName;
param_general.groundtruth = main.groundtruth;
param_general.sigma0 = main.sigma0;

% % get child filename of groundtruth and remove extension .fits
% [~, param_general.subFolerName, ~] = fileparts(param_general.groundtruth);
% [~, tmp, ~] = fileparts(main.uvFile);
% param_general.subFolerName = [param_general.subFolerName, filesep, tmp];

% set fields to default value if missing
% set main path for the program
if isfield(main, 'dirProject') && ~isempty(main.dirProject)
    param_general.dirProject = main.dirProject;
else
    param_general.dirProject = [pwd, filesep];
end
% general flag
if ~isfield(param_general, 'flag_imaging')
    param_general.flag_imaging = true;
end
if ~isfield(param_general, 'flag_data_weighting')
    param_general.flag_data_weighting = true;
end
if ~isfield(param_general, 'verbose')
    param_general.verbose = true;
end
% super-resolution factor
if isfield(main, 'superresolution') && ~isempty(main.superresolution)
    param_general.superresolution = main.superresolution; % the ratio between the given max projection base line and the desired one 
else
    param_general.superresolution = 1.0;
end
% compute resources
if isfield(param_general,'ncpus') && ~isempty(param_general.ncpus)
    navail=maxNumCompThreads;
    nrequested = maxNumCompThreads(param_general.ncpus);
    fprintf("\nINFO: Available CPUs: %d. Requested CPUs: %d\n",navail , maxNumCompThreads)
else
    fprintf("\nINFO: Available CPUs: %d.\n", maxNumCompThreads)
end

disp(param_general)

fprintf("\n________________________________________________________________\n")

%% main function
imager2(main.uvFile, param_general, main.runID);

end