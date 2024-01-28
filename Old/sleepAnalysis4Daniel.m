SA=sleepAnalysis('/media/sil1/Data/Pogona Vitticeps/brainStatesWake.xlsx');
%% set rec
SA.setCurrentRecording('Animal=PV161,recNames=Night11');
SA.getDelta2BetaRatio;
SA.plotDelta2BetaRatio;
%SA.currentDataDir = '/media/sil2/Data/Lizard/Stellagama/SA3/SA3_10_20_21_Trial1_2021-02-10_17-17-52'
%% disp(SA)
SA.getDigitalTriggers
%load([SA.currentAnalysisFolder filesep 'getDigitalTriggers.mat']);
%% get data
SA.getFreqBandDetection('tStart',10*1000*60,'win',1000*60*60*20); 
SA.getDelta2BetaAC('tStart',6.5*60*1000*60,'win',2*1000*60*60,'overwrite',1);
SA.getSlowCycles;
SA.getLizardMovements;

%% plot data
SA.plotDelta2BetaAC;%('tStart',1000*60*60*2,'win',1000*60*60*4);
SA.plotDelta2BetaSlidingAC;%('tStart',1000*60*60*2,'win',1000*60*60*9);
SA.plotFreqBandDetection;
SA.plotSlowCycles;
SA.plotLizardMovementDB;


