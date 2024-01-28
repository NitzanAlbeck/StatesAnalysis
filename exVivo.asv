%% ex-vivo analysis

%% single trace
% taken from the recording rec = MCH5Recording('/
% media/sil1/Data/Pogona Vitticeps/Ex-Vivo MEA experiments/
% PV165/Recordings/2023-09-27T19-15-24PV165_left_slice3_475_stim_HSfliped.h5')

rec = MCH5Recording(['/media/sil1/Data/Pogona Vitticeps/Ex-Vivo MEA experiments' ...
    '/PV165/Recordings/2023-09-27T19-15-24PV165_left_slice3_475_stim_HSfliped.h5']);
Ttrig = rec.getTrigger();
trigs = Ttrig{1};
stimT = trigs(2);
def_stim_lens = 500;
preStim = 200;
% get the data from the second triger:
[singleTrace,T] = rec.getData(208,stimT-preStim,1000);
%plot:
figure;
plot(T,squeeze(singleTrace),'Color','black')
xlabel('Time(ms)');
ylabel('(mV)');
yl = [-60, 30];
ylim(yl);

%Stimulus shading
%Define the x-coordinates for the shaded region
xStart = preStim;
xEnd = preStim + def_stim_lens;

%  Create the polygon vertices for the shaded region
verticesX = [xStart, xStart, xEnd, xEnd];
verticesY = [yl(1), yl(2), yl(2), yl(1) ];
% Fill the shaded region
hold on;
fill(verticesX, verticesY, 'b', 'FaceAlpha', 0.2, 'EdgeColor','none');
hold off;
rec.recordingDir
saveas(gcf, strcat(rec.recordingDir, '/slice3_475_208ch_trial2.jpg'));
%% plot the trials:
figure
plotShifted(ch208_555_T, squeeze(ch208_555_M).','verticalShift',60);
title ('Ch208,All trials -555');
stimLength = 500;
stim_color = 'g';

xlabel('Time(ms)');
ylabel('(mV)');
yl = [0, 1800];
ylim(yl);

xStart = 200;
xEnd = 200+ stimLength;

%  Create the polygon vertices for the shaded region
verticesX = [xStart, xStart, xEnd, xEnd];
verticesY = [yl(1), yl(2), yl(2), yl(1) ];
% Fill the shaded region
hold on;
fill(verticesX, verticesY, stim_color, 'FaceAlpha', 0.1, 'EdgeColor','none');
hold off;

saveas(gcf,strcat(plotsDir,'/ch208_alltrials_500ms_555.jpg'));