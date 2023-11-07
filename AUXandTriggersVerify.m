%trigger and aux checking:

SA=sleepAnalysis('/media/sil2/Data/Lizard/Stellagama/brainStatesSS.xlsx');
SA.setCurrentRecording('Animal=SA15,recNames=sleepNight1');
[V_us,t] = SA.currentDataObj.getAnalogData([33,34,35],60000,1000000);
a= permute(V_us, [3 1 2]);
plot(a)
%% triggers
trig = SA.currentDataObj.getTrigger;
trig (16)
