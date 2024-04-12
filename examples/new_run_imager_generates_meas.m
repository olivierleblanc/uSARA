clear all;
clc;

path = fileparts(mfilename('fullpath'));
cd(path)
cd ..

config = ['.', filesep, 'config', filesep, 'usara_sim_ROP.json'];
uvFile = ['.', filesep, 'data', filesep, 'uv.mat'];
groundtruth = ['.', filesep, 'data', filesep, 'ngc6543a_gt.fits'];
resultPath = ['.', filesep, 'results'];
% resultPath = '';
runID = 0;

run_imager2(config, 'uvFile', uvFile, 'resultPath', resultPath, 'groundtruth', groundtruth, 'runID', runID)