clear 
clc

delete(gcp('nocreate'))

path = fileparts(mfilename('fullpath'));
cd(path)
cd ..

config = ['.', filesep, 'config', filesep, 'usara_sim2.json'];
dataFile = ['.', filesep, 'data', filesep, 'ngc6543a_data.mat'];
groundtruth = ['.', filesep, 'data', filesep, 'ngc6543a_gt.fits'];
resultPath = ['.', filesep, 'results'];
runID = 0;

run_imager(config, 'dataFile', dataFile, 'resultPath', resultPath, 'groundtruth', groundtruth, 'runID', runID)
