%% Optogenetics analysis
% requires: timeSeriesViewer, NET

%% single stimulations analysis
% this methods takes a recording, and plots the reaction for eac
% stimulation in the series of the single stimulation. 
% the Singles are 7 stimualtions in increasing lengths: (12.5, 25, 50,
% 100, 200, 400, 800)

%rec = OERecording('/media/sil3/Data/Pogona_Vitticeps/PV159/PV159_Trial23_singles1_2023-11-19_14-28-59/Record Node 101');
SA = sleepAnalysis('/media/sil1/Data/Pogona Vitticeps/brainStatesWake.xlsx');
SA.setCurrentRecording('Animal=PV161,recNames=Night9');

%% plot
getSinglesStim(SA.currentDataObj,15,'b');


%% plot  max D2b values for each part of the night:
% this method (should be a method) take the times of the stimulations and
% plots the top 20% valuse of the D2B ratio. 
% TODO: put in methed,
%   try to do for every ten minutes, not the 20 top values.
%   look in nights withoug stimulations.

SA = sleepAnalysis('/media/sil1/Data/Pogona Vitticeps/brainStatesWake.xlsx');
SA.setCurrentRecording('Animal=PV161,recNames=Night11');



%%
stimCh = 15; % the lzaser triger channel.
extraT = 120000;
% topPrecent = 20;


DB = SA.getDelta2BetaRatio; % get the D2B ratio
AC = SA.getDelta2BetaAC(); % end and start of sleep
SC = SA.getSlowCycles();
% get the triggers timing:
trig = SA.getDigitalTriggers;
stimT = trig.tTrig{stimCh}; % time from recording start time.

% devide the D2B ratio to the different parts of the recording:
dbStim = DB.bufferedDelta2BetaRatio((DB.t_ms > stimT(1)) & (DB.t_ms<(stimT(end)+extraT)));
TStim = DB.t_ms((DB.t_ms > stimT(1)) & (DB.t_ms<(stimT(end)+extraT)));
dbPre = DB.bufferedDelta2BetaRatio((DB.t_ms < stimT(1)) & (DB.t_ms>AC.tStartSleep));
TPre = DB.t_ms((DB.t_ms < stimT(1)) & (DB.t_ms>AC.tStartSleep));
dbPost = DB.bufferedDelta2BetaRatio((DB.t_ms > (stimT(end)+extraT)) & (DB.t_ms < AC.tEndSleep));
TPost = DB.t_ms((DB.t_ms > (stimT(end)+extraT)) & (DB.t_ms < AC.tEndSleep));

%%


figure;
plot(AC.pSleepDBRatio,'.');hold on; plot(SC.pSleepDBRatio,'-.');
xline(AC.tStartSleep/1000,'r'); xline(AC.tEndSleep/1000,'g');
xline(stimT(1)/1000,'b');xline(stimT(end)/1000,'black')
legend('AC','SC','tStartsleep(AC)','tEndSleep(AC_','StartStim','EndStim');
saveas(gcf,strcat(SA.currentPlotFolder,filesep,'nightTimeLine.jpeg'));

%% get the sws/rem classification
% for each cycle - take the times of SWS and REM and put in an array
Tsws = [];
Trem =[];
for i = 1:length(SC.TcycleOnset)
    TcurrSWS =SC.t_ms((SC.t_ms>SC.TcycleOnset(i)) & (SC.t_ms<SC.TcycleMid(i)));
    Tsws = [Tsws,TcurrSWS];
    TcurrREM = SC.t_ms((SC.t_ms>SC.TcycleMid(i)) & (SC.t_ms<SC.TcycleOffset(i)));
    Trem = [Trem,TcurrREM];
end

%then, create a new array for each group with the annotations of SWS[1], REM[2] or unknown[0]
dbPreState = zeros(size(dbPre));
dbPreState(ismember(TPre,Tsws)) = 1;
dbPreState(ismember(TPre,Trem)) = 2;
dbStimState = zeros(size(dbStim));
dbStimState(ismember(TStim,Tsws)) = 1;
dbStimState(ismember(TStim,Trem)) = 2;
dbPostState = zeros(size(dbPost));
dbPostState(ismember(TPost,Tsws)) = 1;
dbPostState(ismember(TPost,Trem)) = 2;

%%
topPrecent = 20;
% get the maximal values for each part - 20% top percent of each part 
cutoffPre = prctile(dbPre,100-topPrecent);
topDBpre = dbPre(dbPre>cutoffPre);
topPreState = dbPreState(dbPre>cutoffPre);
cutoffstim = prctile(dbStim,100-topPrecent);
topDBstim = dbStim(dbStim>cutoffstim);
topStimState = dbStimState(dbStim>cutoffstim);
cutoffpost = prctile(dbPost,100-topPrecent);
topDBpost = dbPost(dbPost>cutoffpost);
topPostState = dbPostState(dbPost>cutoffpost);



% plot the max d2b valuse for wach part of the night:

% swarmchart:
figure;
colormap = [0, 121, 140; 237, 174, 73;209, 73, 91]/255; % colormap for the hue, dark bluu for undefined, green for SWS, Pink for rem

legend_entries = {'Undetermined', 'SWS', 'REM sleep'};
for i = 1:length(legend_entries)
    dummyPlot(i) = scatter(NaN, NaN, 50, colormap(i, :), 'filled','DisplayName',legend_entries{i});
    hold on
end


hold on
swarmchart(ones(1,length(topDBpre)),topDBpre,10, colormap(topPreState + 1, :),'filled','o','XJitter','density');
swarmchart(2*ones(1,length(topDBstim)),topDBstim,10, colormap(topStimState + 1, :),'filled','o','XJitter','density');
swarmchart(3*ones(1,length(topDBpost)),topDBpost,10, colormap(topPostState + 1, :),'filled','o','XJitter','density');

xticks([1 2 3]);
xticklabels({'Before stimulation','during Stimulatio', 'After Stim'})
title(sprintf('Max %d percent D2B values for each Part of the night',topPrecent))

hold off
legend(dummyPlot, 'Location', 'Best');
saveas(gcf,strcat(SA.currentPlotFolder,filesep,'maxDB.jpeg'));

% pie chart for each segment:
figure;
preStateCount = histcounts(topPreState);
stimStateCount = histcounts(topStimState);
postStateCount = histcounts(topPostState);

t = tiledlayout(1,3,'TileSpacing','compact');

ax1 = nexttile;
pie(preStateCount)
title('Pre Stim', num2str(numel(topPreState)))

ax2 = nexttile;
pie(stimStateCount )
title('Stim',num2str(numel(topStimState)))

ax3 = nexttile;
pie(postStateCount)
title('Post Stim', num2str(numel(topPostState)))

lgd = legend(legend_entries);
lgd.Layout.Tile = 'east';
saveas(gcf,strcat(SA.currentPlotFolder,filesep,'maxDBpie.jpeg'));
%% functions:
function getSinglesStim(rec, trig_ch, stim_color ,pre_ms, win)
    % rec - an OErecording.
    % trig_ch - the triggers channel number for the OG stimulations. can be
    % checked using getTriggers. defualt = 15.
    % stim_color - what color for the shading. 'b' for blue (473), 'g' for
    % green (532), 'r' for red. (635) default - blue
    % pre_ms - time in ms, before stimulatiom. defualt = 250
    % win - the full time window in ms. defult 1500 ms
    
    % Check the number of input arguments and set defaults
    if nargin < 5
        win = 1500; % total window, ms
    end
    if nargin < 4
        pre_ms = 250; % time before stim, ms
    end
    if nargin < 3
        stim_color = 'b'; % defualt colo for shading
        fprintf ('Shading color was not supplied, defualt shading is blue.\n')
    end
    if nargin < 2
        trig_ch = 15;
        fprintf ('Triger channel was not supplied, defualt trigger ch is 15.\n')
    end

    % in current setup: camera triggers are 7-8, stim are 15-16 (in this particular setting)
    % get the stimulations and save them. 
    trigs = rec.getTrigger();
    stim_up = cell2mat(trigs(trig_ch)); % up times from the begining of rec in ms.
    % get the data for each trigger point
    [segs,times]= rec.getData(1:32,stim_up-pre_ms,win); 
    mean_stim = squeeze(mean(segs,2));
    
    % analysis folder
    AnalysisFolder = strcat(rec.recordingDir, '/plots');
    status = mkdir(AnalysisFolder);

%     % ploting all stimulations mean, different channels:
%     figure
%     title('All channels, All stimuli');
%     plot(times,mean_stim);
%     xline(pre_ms)
%     %xlim([0 1500])
%     %ylim([-0.0100 0.0050])
%     %ylim ([-200 80])
%     xlabel("Time (ms)")
%     ylabel("Voltage (mV)")
% 
%     saveas (gcf, strcat(AnalysisFolder,filesep, 'all_chanells.jpg'));
%     
% 
    % plotting each stim length alone
    def_stim_lens = [12.5, 25, 50, 100, 200, 400, 800];
    stim_count = length(def_stim_lens);
    stim_total_num = length(stim_up);

    figure
    
    axes = zeros(stim_count);
    cols = 1;
    rows = 7;
    set (gcf, "Position", [100 100 900 300]);
    for i = 1:stim_count
        cur_stims = i:stim_count:stim_total_num;
        curr_segs = segs(:,cur_stims,:); % creating a new matrix with only the segs needed.
        curr_mean = squeeze(mean(curr_segs,2));     
    
        
        axes(i) = subplot(rows,cols,i);
        plot(times,curr_mean); 
        title ('Stim length', num2str(def_stim_lens(i)));
        xlabel('Time(ms)');
        ylabel('(mV)');
        yl = [-150, 150];
        ylim(yl);
        %Stimulus shading
        %Define the x-coordinates for the shaded region
        xStart = pre_ms;
        xEnd = pre_ms + def_stim_lens(i);

        %  Create the polygon vertices for the shaded region
        verticesX = [xStart, xStart, xEnd, xEnd];
        verticesY = [yl(1), yl(2), yl(2), yl(1) ];
        % Fill the shaded region
        hold on;
        fill(verticesX, verticesY, stim_color, 'FaceAlpha', 0.2, 'EdgeColor','none');
        hold off;
        
%         xPosition = mod(i - 1, cols) / cols;
%         yPosition = 1 - ceil(i / cols) / rows;
%         width = 1 / (cols+1);
%         height = 1 / (rows+1);
% 
%         set(gca,'Position',[xPosition,yPosition,width,height])


    end
    
    saveas (gcf, strcat(AnalysisFolder,filesep, 'all_stimulations_line.jpg'));


end



