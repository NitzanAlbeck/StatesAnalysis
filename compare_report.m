%% compare the data

SA = sleepAnalysis('/media/sil1/Nitzan/Experiments/brainStatesWake.xlsx');
SA.setCurrentRecording(['Animal=PV87,recNames=Day2']);

%% traces: 
% plot 3 traces in the recording, 20 sec each
% 22hrs recording. 20 sec: 0-20, 36000-36000+20, 100800- 100800+20

% start times, in seconds from the begining of the record:
seg1_start_ms = 0;
seg2_start_ms = 10*60*60*1000; % 10 hrs after rec start
seg3_start_ms = 20*60*60*1000; % 20 hrs after rec start
t_start_ms = [seg1_start_ms,seg2_start_ms, seg3_start_ms]; 

% export the traces to mat

ch = SA.recTable.defaulLFPCh(SA.currentPRec);
seg_length = 20*1000; % 20 sec
outputpath = "/media/E/Nitzan/Pipline_testing/Test_Data/";

for seg = 1:length(t_start_ms)
    t_start = t_start_ms(seg);
    seg_data = SA.currentDataObj.getData(ch,t_start,seg_length);
    seg_plot = reshape(seg_data (1,1,:),[],1);
    
    save(strcat(outputpath,"seg_",string(seg)),"seg_plot")
end

%% metadata mat variables:
recName = ["PV87","Day2"];

%length of rec in hrs and seconds. 
rec_dur_hrs = SA.currentDataObj.recordingDuration_ms / (1000*60*60);
rec_dur_s = SA.currentDataObj.recordingDuration_ms / 1000;

% Export metadata for py
save(strcat(outputpath,"metadata"),"recName","t_start_ms","rec_dur_s","-v7")

%% get the treiggers to MAT file
% getting the triggers, and save in .mat files. 
% for reaptilearn triggers: we need only the triggers from between the 
% 2-sec breaks.

tTrig = SA.currentDataObj.getTrigger; %gives an array of cells, with the
% on and off times, not in timestamps, but in miliseconds from timestamp 0
% I want only the on triggers times
trig = tTrig{1};
trigThreshold = 1000;
edges = find(diff(trig)>trigThreshold);
if len(edges) == 2
    triggers = trig(edges(1)+1:edges(2)+1); % only the triggers between t
    save(strcat(outputpath,'triggers'),"triggers")
else
    print('too many or too little gaps in triggers. please use getTriggers')
end




