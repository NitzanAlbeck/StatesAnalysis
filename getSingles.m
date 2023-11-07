%% Optogenetics analysis
% requires: timeSeriesViewer, NET

%% single stimulations analysis
% this methods takes a recording, and plots the reaction for eac
% stimulation in the series of the single stimulation. 
% the Singles are 7 stimualtions in increasing lengths: (12.5, 25, 50,
% 100, 200, 400, 800)

rec = OERecording('//media/sil1/Pogona Vitticeps/PV149/Singles/PV149_Trial82_Singles532_2023-08-10-14-42/Record Node 101');

getSinglesStim(rec,15,'g');


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
    AnalysisFolder = strcat(rec.recordingDir, 'Analysis');
    status = mkdir(AnalysisFolder);

    % ploting all stimulations mean, different channels:
    figure
    title('All channels, All stimuli');
    plot(times,mean_stim);
    xline(pre_ms)
    %xlim([0 1500])
    %ylim([-0.0100 0.0050])
    %ylim ([-200 80])
    xlabel("Time (ms)")
    ylabel("Voltage (mV)")

    saveas (gcf, strcat(AnalysisFolder,filesep, 'all_chanells.jpg'));
    

    % plotting each stim length alone
    def_stim_lens = [12.5, 25, 50, 100, 200, 400, 800];
    stim_count = length(def_stim_lens);
    stim_total_num = length(stim_up);

    figure
    
    axes = zeros(stim_count);
    set (gcf, "Position", [100 100 500 500]);
    for i = 1:stim_count
        cur_stims = i:stim_count:stim_total_num;
        curr_segs = segs(:,cur_stims,:); % creating a new matrix with only the segs needed.
        curr_mean = squeeze(mean(curr_segs,2));     
    
        axes(i) = subplot(2,4,i);
        plot(times,curr_mean); 
        title ('Stim length', num2str(def_stim_lens(i)));
        xlabel('Time(ms)');
        ylabel('(mV)');
        yl = [-200, 200];
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
        
    end
    
    saveas (gcf, strcat(AnalysisFolder,filesep, 'all_stimulations.jpg'));


end



