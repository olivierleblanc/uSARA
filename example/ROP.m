clear all;
clc;

path = fileparts(mfilename('fullpath'));
cd(path)
cd ..

config = ['.', filesep, 'config', filesep, 'ROP.json'];
dataFile = ['.', filesep, 'data', filesep, 'ngc6543a_data_ROP_unit500.mat'];
groundtruth = ['.', filesep, 'data', filesep, 'ngc6543a_gt.fits'];
resultPath = ['.', filesep, 'results'];
% resultPath = '';
runID = 0;

run_imager_ROP(config, 'dataFile', dataFile, 'resultPath', resultPath, 'groundtruth', groundtruth, 'runID', runID)