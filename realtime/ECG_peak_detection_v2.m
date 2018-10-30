
%To get the ECG peaks
function [y_peak,T_peak]=ECG_peak_detection_v2(x_ECG,T_ECG,fs,MINPEAKHEIGHT,MINPEAKDISTANCE)

% min peak distance in sample number
MINPEAKDISTANCE = ceil(MINPEAKDISTANCE*fs);
 
% find peaks in ECG. Restrict acceptable peak-to-peak separations to values
% greater than minpeakdistance. Peaks must be greater than minpeakheight. 
%y_peak refers to the height of the peaks, T_peak refers to the indices at which the peaks occur 
[y_peak,T_peak] = findpeaks(x_ECG,'MINPEAKDISTANCE',MINPEAKDISTANCE,'MINPEAKHEIGHT',MINPEAKHEIGHT);


% divide by fs to get the location in time
T_peak=T_peak/fs;

 

%indicate the identified peaks on the graph 
figure; 
subplot(2,1,1)
plot(T_ECG,x_ECG,'k')
ylabel('ECG')
ylim([-50 500])
hold on;
plot(T_peak,x_ECG(ceil(T_peak*fs)),'markersize',16,'color','r','Marker','.','linestyle','n')

 %show the ampthresh value
plot(T_ECG,ones(size(x_ECG))*MINPEAKHEIGHT,'b--','linewidth',2)
legend('Filtered ECG','Estimated R peaks','ampthresh')
h1=gca();
subplot(2,1,2)
% plot the RRI peaks 
plot(T_peak(2:end),60./diff(T_peak),'color','k')
ylabel('Heart Beat (bpm)')
xlabel('Time (s)')
h2=gca();
% Synchronise individual axis limits 
linkaxes([h1,h2], 'x');

end 
