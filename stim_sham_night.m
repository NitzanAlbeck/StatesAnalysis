
SA=sleepAnalysis('/media/sil1/Pogona Vitticeps/brainStatesWake.xlsx');
SA.setCurrentRecording('Animal=PV149,recNames=typical2');
DB = SA.getDelta2BetaRatio;
AC = SA.getDelta2BetaAC;
T=  SA.getDigitalTriggers;
firstTrig=T.tTrig{15}(1:8:end);
endStim=T.tTrig{15}(8:8:end)+400;
stimDuation=(endStim(1)-firstTrig(1));
pre=50000;
post=100000;
clear StimDB; %change to zeros
for i=1:numel(firstTrig)
    pTmp=find(DB.t_ms>(firstTrig(i)-pre) & DB.t_ms<=(firstTrig(i)+post));
    %StimDB(i,:)=1./DB.bufferedDelta2BetaRatio(pTmp);
    StimDB(i,:)=DB.bufferedDelta2BetaRatio(pTmp);
end

times=(DB.t_ms(pTmp)-DB.t_ms(pTmp(1)))/1000;
meadStimInterval=mean(diff(firstTrig));
firstTrigSham=(AC.tStartSleep:meadStimInterval:(firstTrig(1)-post))+10000;
endStimSham=firstTrigSham+max(endStim-firstTrig);

clear StimDBSham;
for i=1:numel(firstTrigSham)
    pTmp=find(DB.t_ms>(firstTrigSham(i)-pre) & DB.t_ms<=(firstTrigSham(i)+post));
    %StimDBSham(i,:)=1./DB.bufferedDelta2BetaRatio(pTmp);
    StimDBSham(i,:)=DB.bufferedDelta2BetaRatio(pTmp);
end
%%
%colorLim=[0 0.7];
colorLim=[0 600];
f=figure;
subplot(4,2,[1:2:6]);imagesc(StimDBSham,colorLim);ylabel('Trial #');title('Sham');hold on;set(gca,'XTick',[]);
%cb=colorbar('Position',[0.47 0.76 0.013 0.17]);ylabel(cb,'\delta/\beta');
line([pre/1000 pre/1000],ylim,'color','r');
subplot(4,2,7);plot(times-pre/1000,nanmean(StimDBSham));xlabel(['Time [s]']);ylabel('Avg.');ylim(colorLim/3);
line([0 0],ylim,'color','r');
line([stimDuation/1000 stimDuation/1000],ylim,'color','r');
subplot(4,2,[2:2:6]);imagesc(StimDB,colorLim);ylabel('Trial #');title('Stim');set(gca,'XTick',[]);
cb=colorbar('Position',[ 0.91 0.76 0.013 0.17]);ylabel(cb,'\delta/\beta');
line([pre/1000 pre/1000],ylim,'color','r');
subplot(4,2,8);plot(times-pre/1000,nanmean(StimDB));xlabel(['Time [s]']);ylabel('Avg.');ylim(colorLim/3);
line([0 0],ylim,'color','r');
line([stimDuation/1000 stimDuation/1000],ylim,'color','r');

%%

fileName=[SA.currentPlotFolder filesep 'stim_sham_activation.jpg'];
saveas (gcf, fileName);

%%

SA=sleepAnalysis('/media/sil1/Pogona Vitticeps/brainStatesWake.xlsx');
SA.setCurrentRecording('Animal=PV149,recNames=Night9');

SC=SA.getSlowCycles;
DB=SA.getDelta2BetaRatio;

T=SA.getDigitalTriggers;
firstTrig=T.tTrig{15}(1:8:end);
endStim=T.tTrig{15}(8:8:end)+400;
stimDuation=(endStim(1)-firstTrig(1));

firstTrigSham=firstTrig-(firstTrig(end)-firstTrig(1)-100000);
endStimSham=endStim-(firstTrig(end)-firstTrig(1)-100000);

pre=50000;
post=100000;
clear StimDB; %change to zeros
for i=1:numel(firstTrig)
    pTmp=find(DB.t_ms>(firstTrig(i)-pre) & DB.t_ms<=(firstTrig(i)+post));
    %StimDB(i,:)=1./DB.bufferedDelta2BetaRatio(pTmp);
    StimDB(i,:)=DB.bufferedDelta2BetaRatio(pTmp);
end

times=(DB.t_ms(pTmp)-DB.t_ms(pTmp(1)))/1000;
meadStimInterval=mean(diff(firstTrig));
firstTrigSham=(AC.tStartSleep:meadStimInterval:(firstTrig(1)-post))+10000;
endStimSham=firstTrigSham+max(endStim-firstTrig);

clear StimDBSham;
for i=1:numel(firstTrigSham)
    pTmp=find(DB.t_ms>(firstTrigSham(i)-pre) & DB.t_ms<=(firstTrigSham(i)+post));
    %StimDBSham(i,:)=1./DB.bufferedDelta2BetaRatio(pTmp);
    StimDBSham(i,:)=DB.bufferedDelta2BetaRatio(pTmp);
end

%%
%colorLim=[0 0.7];
colorLim=[0 600];

f=figure;
subplot(4,2,[1:2:6]);imagesc(StimDBSham,colorLim);ylabel('Trial #');title('Sham');hold on;set(gca,'XTick',[]);
%cb=colorbar('Position',[0.47 0.76 0.013 0.17]);ylabel(cb,'\delta/\beta');
line([pre/1000 pre/1000],ylim,'color','r');
subplot(4,2,7);plot(times-pre/1000,nanmean(StimDBSham));xlabel(['Time [s]']);ylabel('Avg.');ylim(colorLim/3);
line([0 0],ylim,'color','r');
line([stimDuation/1000 stimDuation/1000],ylim,'color','r');
c
subplot(4,2,[2:2:6]);imagesc(StimDB,colorLim);ylabel('Trial #');title('Stim');set(gca,'XTick',[]);
cb=colorbar('Position',[ 0.91 0.76 0.013 0.17]);ylabel(cb,'\delta/\beta');
line([pre/1000 pre/1000],ylim,'color','r');
subplot(4,2,8);plot(times-pre/1000,nanmean(StimDB));xlabel(['Time [s]']);ylabel('Avg.');ylim(colorLim/3);
line([0 0],ylim,'color','r');
line([stimDuation/1000 stimDuation/1000],ylim,'color','r');

%set(gcf,'PaperPositionMode','auto');print('ChRStimDelta2Beta','-djpeg','-painters');print('ChRStimDelta2Beta','-dpdf','-painters');
%%
figure;
plot(DB.t_ms/1000/60/60,DB.bufferedDelta2BetaRatio,'k');
hold on;
h1=line([firstTrig;firstTrig]/1000/60/60, (ylim()'*ones(1,numel(firstTrig))),'color','b');
h2=line([endStim;endStim]/1000/60/60, (ylim()'*ones(1,numel(firstTrig))),'color','r');
legend([h1(1) h2(1)],{'start stim','end stim'});

%%

F=filterData(SA.currentDataObj.samplingFrequency(1));
F.downSamplingFactor=SA.currentDataObj.samplingFrequency(1)/250;
F=F.designDownSample;

V=squeeze(F.getFilteredData(SA.currentDataObj.getData(20,firstTrig-pre,pre+post)));
times_V=(1:size(V,2))/250;
figure;plotShifted(V');

for i=1:20
oneStim=T.tTrig{15}(1:8)-T.tTrig{15}(1);
figure('Position',[123 558 1566 420]);plot(times-pre/1000,StimDB(i,:),'r');hold on;plot(times_V-pre/1000,V(i,:),'k');
line([oneStim;oneStim]/1000, (ylim()'*ones(1,numel(oneStim))),'color','b');
xlim([-10 100]);
ylabel('V [\muV]');
xlabel('Time [s]');
pause;
end 
%set(gcf,'PaperPositionMode','auto');print('ChRStimSingleTrial','-djpeg','-painters');print('ChRStimSingleTrial','-dpdf','-painters');

%% Examine StimChanges changes

SA.getDelta2BetaAC('tStart',5.5*60*60*1000,'win',3*60*60*1000,'overwrite',1);
stim=SA.getDelta2BetaAC;
SA.getDelta2BetaAC('tStart',2*60*60*1000,'win',3*60*60*1000,'overwrite',1);
preStim=SA.getDelta2BetaAC;

f=figure;
hL(1) = plot(preStim.xcf_lags/1000,real(preStim.xcf),'k');
xlabel('Period [s]');
ylabel('Auto corr.');
hold('on');
plot(preStim.period/1000,real(preStim.xcf(preStim.pPeriod)),'o','MarkerSize',5,'color','k');
text(preStim.period/1000,0.05+real(preStim.xcf(preStim.pPeriod)),num2str(preStim.period/1000));

hL(2) = plot(stim.xcf_lags/1000,real(stim.xcf),'b');
plot(stim.period/1000,real(stim.xcf(stim.pPeriod)),'o','MarkerSize',5,'color','b');
text(stim.period/1000,0.05+real(stim.xcf(stim.pPeriod)),num2str(stim.period/1000),'color','b');

xlim([-200 200]);
%set(gcf,'PaperPositionMode','auto');print('ChR_freqChange','-djpeg','-painters');print('ChR_freqChange','-dpdf','-painters');DB=SA.getDelta2BetaRatio;


preStimDB=DB.bufferedBetaRatio(find(DB.t_ms>2*60*60*1000 &DB.t_ms<5*60*60*1000));
stimDB=DB.bufferedBetaRatio(find(DB.t_ms>5.5*60*60*1000 &DB.t_ms<8.5*60*60*1000));

f=figure('Position',[680   759   186   219]);
[h,hE,hB]=myErrorBar(1:2,[mean(preStimDB) mean(stimDB)],[std(preStimDB) std(stimDB)] ,0.4,'Bfacecolor',[0.3 0.3 0.3],'BLinewidth',5,'Ecolor','k');

addpath('/home/mark/Documents/MATLAB/Wave-Analysis/small functions and plots/violin');
violin(1,preStimDB, ...
    'KernelWidth', 5, ...
    'withmdn', 1,... 
    'cutoff',      1e-4, ...
    'scaling',     1);
violin(1.03,stimDB, ...
    'KernelWidth', 5, ...
    'withmdn', 1,...
    'cutoff',      1e-4, ...
    'facecolor',   'b', ...
    'scaling',     1);
set(gca,'XTick',[1 1.03],'XTickLabel',{'Pre','Stim'});
ylabel('\delta/\beta')
%set(gcf,'PaperPositionMode','auto');print('ChR_DB','-djpeg','-painters');print('ChR_DB','-dpdf','-painters');
