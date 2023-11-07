%% setting up the spike sorting:
%% create the binary file for kilosorting: (only if not yet excisting)
% add another line in the excel, to the binary: sleepNight12b for example,
% and add it in a folder namde spikeSorting in the original recording
% folder. 
SA=sleepAnalysis('/media/sil2/Data/Lizard/Stellagama/brainStatesSS.xlsx'); 
SA.setCurrentRecording('Animal=SA15,recNames=sleepNight5');
SA.currentDataObj.generateChannelMapFile('40_16x2_FlexLin'); % 120_32x1_H4_CamNeuro for PV24. all layouts in TSV/electrode layouts 
SA.currentDataObj.convert2Binary([SA.currentDataObj.recordingDir filesep 'spikeSorting' filesep 'ch1_32.bin'],1:32,1:32);

%% upload the data to the kilosort
addpath(genpath('/home/nitzan/Documents/MATLAB/Kilosort-main')) % path to kilosort folder
addpath(genpath('/home/nitzan/Documents/MATLAB/npy-matlab-master')) % for converting to Phy


SA=sleepAnalysis('/media/sil2/Data/Lizard/Stellagama/brainStatesSS.xlsx'); 
SA.setCurrentRecording('Animal=SA15,recNames=sleepNight5b');
SA.currentDataObj.getKiloSort('/home/nitzan/tempKilosort','tStart',4*60*60*1000,'tEnd',12*60*60*1000); % this is a new format where
SA.currentDataObj.convertPhySorting2tIc([],2*60*60*1000); % is there manual annotation




%[out,envs] = system(['conda env list'])
%conda('activate','phy2')
%set phy2 environment
%run phy on current analysis object
system(['phy template-gui "' fullfile(SA.currentDataObj.recordingDir,['kiloSortResults_',SA.currentDataObj.recordingName]) filesep 'params.py"'])
%Convert to t-ic - this should run after performeing the phy manual curation analysis
SA.currentDataObj.convertPhySorting2tIc; % 
                      