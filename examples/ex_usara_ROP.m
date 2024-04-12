clear all;
clc;

path = fileparts(mfilename('fullpath'));
cd(path)
cd ..

config = ['.', filesep, 'config', filesep, 'usara_sim_ROP.json'];
dataFile = ['.', filesep, 'data', filesep, 'ngc6543a_data_ROP_separated_unitary10.mat'];
groundtruth = ['.', filesep, 'data', filesep, 'ngc6543a_gt.fits'];
resultPath = ['.', filesep, 'results'];
% resultPath = '';
runID = 0;

run_imager(config, 'dataFile', dataFile, 'resultPath', resultPath, 'groundtruth', groundtruth, 'runID', runID)