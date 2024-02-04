SA=sleepAnalysis('/media/sil1/Data/Pogona Vitticeps/brainStatesWake.xlsx');
%% set rec
SA.setCurrentRecording('Animal=PV161,recNames=Night15');
SA.getDelta2BetaRatio;
SA.plotDelta2BetaRatio;
%SA.currentDataDir = '/media/sil2/Data/Lizard/Stellagama/SA3/SA3_10_20_21_Trial1_2021-02-10_17-17-52'
%% disp(SA)
SA.getDigitalTriggers
%load([SA.currentAnalysisFolder filesep 'getDigitalTriggers.mat']);
%% get data
SA.getFreqBandDetection;%('tStart',10*1000*60,'win',1000*60*60*20); 
SA.getDelta2BetaAC;%('tStart',(stim(end)),'win',3*60*60*1000,'overwrite',1);
SA.getSlowCycles('excludeIrregularCycles',0,'overwrite',1);
% SA.getLizardMovements;

%% plot data
SA.plotDelta2BetaAC;
SA.plotDelta2BetaSlidingAC;%('tStart',1000*60*60*2,'win',1000*60*60*9);
SA.plotFreqBandDetection;
SA.plotSlowCycles;
% SA.plotLizardMovementDB;


