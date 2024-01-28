%% wake state - bug appearnce
% here I want to shwo traces of the bug apperance in PV149 during circle
% trials/ 
%
% TO DO:
%   -- change the variables of the paths so i can change it easily / it
%       will read from the excel.
%   -- Take the trigger channels from the excel - atimulation channel and
%       camera triggers chanel.
%   -- triggers are by defenition will be different for this animal. adjust
%   the code accordingly. problem expained near "num_missing_frames".
%   
% WHY ARE THE TIMESTAMPS IN S and not MS?!
%
% trigger chanels for PV149: cams - 7-8, stimulations - 15-16/

%% getting the data for this sepecific experimeent:
% notice - now everything should be changes manualy.
SA = sleepAnalysis('/media/sil1/Data/Pogona Vitticeps/brainStatesWake.xlsx');
SA.setCurrentRecording('Animal=PV161,recNames=Hunter40');

ArenaCSVs = getArenaCSVs(SA); % gets all the CSVs of the arena into tables inside a struct.



%% getting the triggers from the OERecording
camTrigCh = SA.recTable.camTriggerCh(SA.currentPRec);% ch can be change according to the setup.
OEcamTrig = SA.currentDataObj.getCamerasTrigger(camTrigCh);

% in any ways, check:
% num_missing_frames = length(EOcamTrig) - length(ArenaCSVs.videoFrames);

% problem with the triggers: there are 3 more triggers in the beggining and
% all the rest of the added triggers are in the end of the recording. you
% can make some adjustment later, not crutial for now. mark knows and might
% be able to write  somemthing to evaluate these misses.


%% getting the trials times in OE times:
% getting the trial start and end times:
% using the bugs table, as it is the most acuurate in time (instead of
% block log).
bugs = ArenaCSVs.bugs;
videosFrames = ArenaCSVs.videoFrames;
screenTouch = ArenaCSVs.screenTouch;

bugStops = find(diff(bugs.Timestamps)>15)+1; 
firstInd = 1;
startTrials = bugs.Timestamps([firstInd,bugStops.']);
endTrials = bugs.Timestamps([(bugStops.')-1,end]);
% change to frame number:
sTrialFrame = getVideoFrames(videosFrames,startTrials);
eTrialFrame = getVideoFrames(videosFrames,endTrials);
% change to frame time stamp in OE:
%sTrialsTrig = trimOETrigs(sTrialFrame); % this is the trigs for the start of trials.
%eTrialsTrig = trimOETrigs(eTrialFrame);

% strike times
% taking the strike time from the strike plots

hitsIdx = strcmpi(screenTouch.is_hit,'true');
strikesTimes = screenTouch.Timestamps(hitsIdx);
strikesFrames = getVideoFrames(videosFrames,strikesTimes); % theres a 15 frames difference.
strikesTrig = OEcamTrig(strikesFrames); 
% correction of frames for the behavioral data:
% for this recording - PV149, Hunter61, the frames are shifted 4 triggers
% (the videos is from trigger number 4 until the end of num of frames).
% the CSVs are 15 frames from the times of the triggers (11 after
% correction)
shifts = SA.recTable.blockShift(SA.currentPRec);
shiftsnum = str2num(shifts{1});

% timestamps for the events:
if isempty(shiftsnum) ==1
    oeStartTrial = OEcamTrig(sTrialFrame);
    oeEndTrial = OEcamTrig(eTrialFrame);
    oeStrikes = OEcamTrig(strikesFrames);
elseif numel(shiftsnum) ==1
    oeStartTrial = OEcamTrig(sTrialFrame-shiftsnum);
    oeEndTrial = OEcamTrig(eTrialFrame-shiftsnum);
    oeStrikes = OEcamTrig(strikesFrames-shiftsnum);
else 
    oeStartTrial = OEcamTrig(sTrialFrame-shiftsnum(1));
    oeEndTrial = OEcamTrig(eTrialFrame-shiftsnum(1));
    oeStrikes = OEcamTrig(strikesFrames-shiftsnum(2));
end
%% Saving of shifts after frame-by-frame hand annotations
% after checking it frame-by-frame, I found that there are different shift
% in the timing of the frames vs what we are getting from the files. I wish
% to save the shifts data in a mat file in the folder (due to the fact that
% I went over them by hand:
% shifts.startTrialShift = sTrialShift;
% shifts.endTrialShift = eTrialShift;
% shifts.strikeShift = strikesShift;
% 
% filename = 'shifts.mat';
% 
% save(filename,'-struct',"shifts")

%% get and plot long trace of the serrounding of the event:

% start trial

fullTraceWin = 8000; % in ms
% fs = SA.currentDataObj.samplingFrequency(1); %samples per sec
defCh = SA.recTable.defaulLFPCh(SA.currentPRec);

[fullTraceSTrial, fullTraceTimes]= SA.currentDataObj.getData(defCh,oeStartTrial-(fullTraceWin/2),fullTraceWin);

% flatting over 500 mv:
fullTraceSTrial(fullTraceSTrial>500)=500;

%%
figure;plot(fullTraceTimes,squeeze(fullTraceSTrial(1,5,:)))
%%
figure;

plotShifted(fullTraceTimes, squeeze(FullTraceSTrial).','verticalShift',0.05);
xline(fullTraceWin/2,'r'); ylabel('uV');xlabel ('Time[ms]');
title('Bug apperance, for one block')
saveas(gcf,strcat(SA.currentPlotFolder, '/bugApperanceFull.jpg'));


%% get the data for each of the segmentations.
% instacnese:
% window- 3 seconds (for each part)
% channels - for now, I'm taking one that DO have spikes.
%   to have channels with spikes: we can chose 24,25,8,11,9. but many have. 

win = 10000; % in ms
fs = SA.currentDataObj.samplingFrequency(1); %samples per sec
times = linspace(1,win,(win/1000)*fs); % time vector
defCh = 9;
% Bug apperance: before and after

postStart = SA.currentDataObj.getData(defCh,oeStartTrial,win);
preStart = SA.currentDataObj.getData(defCh,oeStartTrial-win, win);

%% Check for strikes in the post bug appearance, and zero-pad

% It's doing zero padding but not in the right times. 
% i'm missing some data, in a few hundred ms but i dont konw why. 

for i = 1:length(oeStartTrial)
   for j = 1:length(oeStrikes)
       % check for each strike is it's time is inside the win: meaning its
       % larger then the begining but smaller than the end
        if oeStartTrial(i)<oeStrikes(j) && (oeStartTrial(i)+win)>oeStrikes(j)
            fprintf('during the win of Trial num %d there was a strike, running zero padding.\n',i)
            %find the time of strike, cut before and padd with zeros
            startToStrike = (oeStrikes(j)-oeStartTrial(i))*fs/1000; %match the times diff
            % change to zero:
            postStart(1,i,round(startToStrike:end)) = 0;
        end
   end
      
end

%% plot traces
% plot the traces:

% plot the averave trace of each trail
% avarge:
meanPostStart = mean(postStart,1);
meanPreStart = mean(preStart,1);

%ploting
figure
subplot(2,1,1);
plotShifted(times, squeeze(meanPreStart).','verticalShift',0.05);
title('Before Bug Apperance')
subplot(2,1,2);
plotShifted(times, squeeze(meanPostStart(1,1:24,:)).','verticalShift',0.05);
title('After Bug Apperance')
xlabel ('Time(ms)')
sgtitle (sprintf("Traces of 25 trial, before/after bug apperance. Ch %d",defCh))
%% extract only relevant parts to see the effect:
% preStartSlim = preStart(:,[1:2,6:10, 12:15],1:(end-5000)); %exclude: 3, 4, 17, ~11
% postStartSlim = postStart(:,[5:14],1:(end-5000));
% 
% %figure;plotShifted(squeeze(meanPreStart)');title('pre');
% %figure;plotShifted(squeeze(meanPostStart)','verticalShift',0.02);title('post')
% 
% figure
% subplot(2,1,1);
% plotShifted(times(1:end-5000), squeeze(preStartSlim).','verticalShift',0.05);
% title('Before Bug Apperance')
% subplot(2,1,2);
% plotShifted(times(1:end-5000), squeeze(postStartSlim).','verticalShift',0.05);
% title('After Bug Apperance')
% xlabel('Time(ms)')
%% get and plot the max amplitude for each trial ch mean - before and after. 

maxPreStart = max(meanPreStart,[],3);
maxPostStart = max(meanPostStart,[],3); 
%meanMaxPre = mean(maxPreStart);
%meanMaxPost = mean(maxPostStart);
%stdMaxPre = std(maxPreStart);
%stdMaxPost = std(maxPostStart);

% swarmchart:
figure

swarmchart(ones(1,length(maxPreStart)),maxPreStart, "filled");
hold on
swarmchart(2*ones(1,length(maxPostStart)),maxPostStart, "filled");
legend({'before','After'})
title('Max Values for each trial')
ylabel('voltage')
hold off

% maybe add the mean and std..

%% FFT

welchWin = 1*fs; 

%calculate the ppx:
[ppxPre,f1] = pwelch(squeeze(preStart(1,1:24,:)).',welchWin,welchWin/2,[],fs);
[ppxPost,f2] = pwelch(squeeze(postStart(1,1:24,:)).',welchWin,welchWin/2,[],fs);
meanPPXpre = median(ppxPre,2);
meanPPXpost = median(ppxPost,2);

%% normalizing each trial then average:
ntPPXpre = ppxPre./sum(ppxPre,1);
ntPPXpost = ppxPost./sum(ppxPost,1);
meanNTpre = mean(ntPPXpre,2);
meanNTpost = mean(ntPPXpost,2);

%plot it:
figure;
plot(f1(1:100),meanNTpre(1:100,:),'Color','black',LineWidth=2);
hold on
plot(f2(1:100),meanNTpost(1:100,:),'Color','r',LineWidth=2)
xlabel ('Freq[Hz]'); ylabel('nPSD');
legend('Before bug apperance','After bug apperance')

titlestr = sprintf(['Normalized trials,data length: %d sec,' ...
    ' welch window: %d sec'],win/1000,welchWin/fs);
title(titlestr);
saveas(gcf,strcat(SA.currentPlotFolder, '/ntFreqBandsBugAppeare.jpg'));

%
ntmaenPPX = (meanNTpre + meanNTpost)/2;
normPPXPre = meanNTpre - ntmaenPPX;
normPPXPost = meanNTpost - ntmaenPPX;
figure;
plot(f1(1:100),normPPXPre(1:100,:),'Color','black',LineWidth=2);
hold on
plot(f2(1:100),normPPXPost(1:100,:),'Color','r',LineWidth=2)
xlabel ('Freq[Hz]'); ylabel('nPSD');
legend('Before bug apperance','After bug apperance')

titlestr = sprintf(['Normalized trials to mean,data length: %d sec,' ...
    ' welch window: %d sec'],win/1000,welchWin/fs);
title(titlestr);
saveas(gcf,strcat(SA.currentPlotFolder, '/tnFreqBandsBugAppeare.jpg'));
%% mark's analysis - not sure about it/
fMax=40;
p=find(f1<fMax);
ppPre=find(sum(ppxPre(p,:))<0.4e6); %reject signals with very high amplitudes (probably noise)
ppPost=find(sum(ppxPost(p,:))<0.4e6); %reject signals with very high amplitudes (probably noise)

sPxxPre=ppxPre(p,ppPre);
sPxxPost=ppxPost(p,ppPost);
sPxx=[sPxxPre sPxxPost];

freqHz=f1(p);
normsPxx=bsxfun(@rdivide,sPxx,mean(sPxx,2));
corrMat=corrcoef(normsPxx);

%maxDendroClusters=2;
%[DC,order,clusters]=DendrogramMamediantrix(corrMat,'linkMetric','euclidean','linkMethod','ward','maxClusters',maxDendroClusters);

figure;
plot(freqHz,median(normsPxx(:,1:25),2),'r');hold on;
plot(freqHz,median(normsPxx(:,26:end),2),'b')

%%
%plot:
fig = figure;

subplot (2,1,1)
plot(f1(1:60),meanPPXpre(1:60,:),'Color','r',LineWidth=2);
hold on
plot(f1(1:40),ppxPre(1:40,:))
title ('Before Bug Apperance')
legend('Average')
hold off

subplot (2,1,2)
plot(f2(1:60),meanPPXpost(1:60,:),'Color','black',LineWidth=2)
hold on
plot(f2(1:20),ppxPost(1:20,:))
title ('After Bug Apperance')
legend('Average')
hold off


han = axes(fig,'Visible','off');
han.XLabel.Visible = 'on';
xlabel(han,'Frequency[Hz]')
titlestr = sprintf(['Welch transform, time win of data = %d sec,' ...
    ' welch window = %d sec'],win/1000,welchWin/fs);
%han.Title.Visible = 'on';
%title(han, titlestr,);
sgtitle(titlestr);

% plot only averegaes on on figure:
figure;
plot(f1(1:60),meanPPXpre(1:60,:),'Color','black',LineWidth=2);
hold on
plot(f2(1:60),meanPPXpost(1:60,:),'Color','r',LineWidth=2)
legend('Before bug apperance','After bug apperance')
xlabel ('Freq[Hz]'); ylabel('PSD');
title('un-normelized');
saveas(gcf,strcat(SA.currentPlotFolder, '/FreqBandsBugAppeare.jpg'));
%% normelized: 
maenPPX = (meanPPXpre + meanPPXpost)/2;
normPPXPre = meanPPXpre - maenPPX;
normPPXPost = meanPPXpost - maenPPX;
figure;
plot(f1(1:100),normPPXPre(1:100,:),'Color','black',LineWidth=2);
hold on
plot(f2(1:100),normPPXPost(1:100,:),'Color','r',LineWidth=2)
xlabel ('Freq[Hz]'); ylabel('nPSD');
legend('Before bug apperance','After bug apperance')

titlestr = sprintf(['Normalized,data length: %d sec,' ...
    ' welch window: %d sec'],win/1000,welchWin/fs);
title(titlestr);
saveas(gcf,strcat(SA.currentPlotFolder, '/nFreqBandsBugAppeare.jpg'));
%% D2B ratio - swarm
%beta = [13, 30]; %hz
%delta = [0.1,3.5]; %hz
deltaBandCutoff = 5; 
betaBandLowcutoff = 10;
betaBandHighcutoff = 30;
betaFs = find(f1>=betaBandLowcutoff & f1<=betaBandHighcutoff);
deltaFs = find(f1<=deltaBandCutoff);

dbPre = [sum(ntPPXpre(deltaFs,:),1)] ./ [sum(ntPPXpre(betaFs,:),1)];
dbPost = [sum(ntPPXpost(deltaFs,:),1)] ./ [sum(ntPPXpost(betaFs,:),1)];

figure;
swarmchart(ones(1,length(dbPre)),dbPre, "filled");
hold on
swarmchart(2*ones(1,length(dbPost)),dbPost, "filled");
legend({'before','After'})
title('db ratio for each trial')
ylabel('ratio')
hold off
saveas(gcf,strcat(SA.currentPlotFolder, '/dbswarm.jpg'))
%% find the effect: FFT for only the 11 trials. 

welchWin = 3*fs; 

%calculate the ppx:
[ppxPre,f1] = pwelch(squeeze(preStartSlim).',welchWin,welchWin/2,[],fs);
[ppxPost,f2] = pwelch(squeeze(postStartSlim).',welchWin,welchWin/2,[],fs);
meanPPXpre = median(ppxPre,2);
meanPPXpost = median(ppxPost,2);

fig = figure;

subplot (2,1,1)
plot(f1(1:60),meanPPXpre(1:60,:),'Color','r',LineWidth=2);
hold on
plot(f1(1:40),ppxPre(1:40,:))
title ('Before Bug Apperance')
legend('Average')
hold off

subplot (2,1,2)
plot(f2(1:60),meanPPXpost(1:60,:),'Color','black',LineWidth=2)
hold on
plot(f2(1:20),ppxPost(1:20,:))
title ('After Bug Apperance')
legend('Average')
hold off


han = axes(fig,'Visible','off');
han.XLabel.Visible = 'on';
xlabel(han,'Frequency[Hz]')
titlestr = sprintf(['Welch transform, time win of data = %d sec,' ...
    ' welch window = %d sec'],win/1000,welchWin/fs);
%han.Title.Visible = 'on';
%title(han, titlestr,);
sgtitle(titlestr);

%%
% SA = sleepAnalysis('/media/sil1/Data/Pogona Vitticeps/brainStatesWake.xlsx');
% SA.setCurrentRecording('Animal=PV149,recNames=Hunter61');
% SA.getSlowCycles;


%% plot bug disappearing:

% get the data:
% instacnese:
% window- 3 seconds (for each part)
% channels - for now, I'm taking one that DO have spikes.
%   to have channels with spikes: we can chose 24,25,8,11,9. but many have. 

win = 3000; % in ms
fs = rec.samplingFrequency(1); %samples per sec
times = linspace(1,win,(win/1000)*fs); % time vector
defCh = 9;
% Bug apperance: before and after

postEnd = rec.getData(defCh,eTrialsTrig,win);
preEnd = rec.getData(defCh,eTrialsTrig-win, win);


%% plot traces:
% plot the averave trace of each trail
% avarge: IF ONLY ONE CH - NOTHING WILL HAPPEN
meanPostEnd = mean(postEnd,1);
meanPreEnd = mean(preEnd,1);

%ploting
figure
subplot(2,1,1);
plotShifted(times, squeeze(meanPreEnd).');
title('Before Bug Disapperance')
subplot(2,1,2);
plotShifted(times, squeeze(meanPostEnd).');
title('After Bug Disapperance')
xlabel ('Time(ms)')
sgtitle (sprintf("Traces of 25 trial, before/after bug Disapperance. Ch %d",defCh))

%% Get the Max amplitude
maxPreEnd = max(meanPreEnd,[],3);
maxPostEnd = max(meanPostEnd,[],3); 
meanMaxPre = mean(maxPreEnd);
meanMaxPost = mean(maxPostEnd);
stdMaxPre = std(maxPreEnd);
stdMaxPost = std(maxPostEnd);

% swarmchart:
figure

swarmchart(ones(1,length(maxPreEnd)),maxPreEnd, "filled");
hold on
swarmchart(2*ones(1,length(maxPostEnd)),maxPostEnd, "filled");
legend({'before','After'})
title('Max Values for each trial')
ylabel('voltage')
hold off


%% functions def:


function vidFrames = getVideoFrames(videoTable, arenaTimestamps)
    % this function returns an array of the frame number the are the closes
    % after the times in arenaTimeatmps, according to the videoTable. this
    % should be allready loaded by readTable, without first row.
    vidFrames = zeros(length(arenaTimestamps),1);
    for i = 1:length(vidFrames)
        t = find(arenaTimestamps(i)>videoTable(:,2));
        vidFrames(i) = t(end);
    end
end


function arenaCSVs = getArenaCSVs(SA)
    % this function gets the argunenmts from the SA excel, and returns a
    % structure that has 3 arrays of the frames closes frames numbers for
    % each event. 
    % maaning, this only takes the CSVs in hunter and converts the times
    % there to frame numbers. 

    % getting the videos data (csv of the triggers):
    videoPath = SA.recTable.VideoFiles(SA.currentPRec);
    [videosFolderPath,vidName,~] = fileparts(videoPath{1});
    videoCSVpath = strcat(videosFolderPath,filesep,'frames_timestamps/',vidName,'.csv');
    videoFrames = readmatrix(videoCSVpath,"NumHeaderLines",1); % timestamps - seconds from 1.1.1970

    %get block data:
    if all(cellfun(@isempty,SA.recTable.blockPath(SA.currentPRec)))
        [blockPath,~] = fileparts(videosFolderPath);
    else
        bloPath = SA.recTable.blockPath(SA.currentPRec);
        blockPath = bloPath{1};
    end
    blockLog = readtable(strcat(blockPath,'/block.log'), "Delimiter",' - ');


    % get the bug location into a table and add timestamps (S):
    %notice - if yu need the timestamps in ms the code needs to change.
    bugs_path = strcat(blockPath,'/bug_trajectory.csv');
    bugs = readtable(bugs_path);
    bugs.DateTime = datetime(bugs.time, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSSXXX', 'TimeZone', '+03:00');
    bugs.Timestamps = posixtime(bugs.DateTime);


    % get the strikes loginto a table and add timestamps:
    screenTouch = readtable(strcat(blockPath,'/screen_touches.csv'));
    screenTouch.DateTime = datetime(screenTouch.time, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSSXXX', 'TimeZone', '+03:00');
    screenTouch.Timestamps = posixtime(screenTouch.DateTime);

   arenaCSVs.videoFrames = videoFrames;
   arenaCSVs.bugs = bugs;
   arenaCSVs.blockLog = blockLog;
   arenaCSVs.screenTouch = screenTouch;


end


% PLOTING Functions 
