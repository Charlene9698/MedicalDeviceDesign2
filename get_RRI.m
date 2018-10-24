%To get the RRI
function [TQ,RR, ANOMALIES]=get_RRI(ECG,ECG_fs,RRI_fs,ampthresh,timethresh,anomalyparam,AAR)

%get the sample duration of the ECG
T=[1:length(ECG)]/ECG_fs;

%get the sample duration in intervals of 1/RRI_fs to plot the RRI graph. Default RRI_fs is 4Hz.
%T= 1/f
TQ=[1:T(end)*RRI_fs]/RRI_fs;

[y_peak,T_peak]=ECG_peak_detection_v2(ECG,T,ECG_fs,ampthresh,timethresh);

% calculating the difference between the time intervals of RRI peaks along the
% first array dimension 

%26 values for RR_intervals 

%this only works when the anomaly is low
RR_unfiltered=((diff((T_peak))));
 
%median is better for skewed data
RR_median=median(RR_unfiltered);

ANOMALIES= zeros(length(RR_unfiltered),1);

if isempty(T_peak)
    disp('Warning. No peaks were identified. Anomaly is set to 1')
    %show full anomaly
    ANOMALIES=ones(10,1);
    RR=0; %set RR to zero
else
    %duration of the sample
    number_seconds=ceil(length(ECG)/ECG_fs);
    %find number of peaks
    num_peaks=length(y_peak);
    %calculate beats per minute
    bpm=ceil(60*num_peaks/number_seconds);    
    
    if bpm<20
        disp('Warning. A small number of peaks were identified. Recommend adjusting the parameters. Anomalies are set to 1')
        %assign a value of 10 ones
        ANOMALIES=ones(10,1);
        RR=0; %set RR to zero
    elseif bpm>300
        disp('Warning. A large number of peaks were identified. Recommend adjusting the parameters.')
        ANOMALIES=ones(10,1);
        RR=0; %set RR to zero
    else
        USER_SATISFACTION=0;

    %if any of the time intervals deviates too far away from the median, it is
    %classified as an anomaly

        for n=1:1:length(RR_unfiltered)
            if (RR_unfiltered(n)> (1+anomalyparam) * RR_median || RR_unfiltered(n) < (1-anomalyparam)* RR_median)
                ANOMALIES(n)=1;
                
            %loop through all the anomalies to test if it is 
            end 
           
        end 
    % 1D interpolation using shape-preserving cubic interpolation
    % TQ is the sample duration in intervals of 1/RRI_fs to plot the RRI graph. Default RRI_fs is 4Hz.
    %T= 1/f 
    %check if data has an error, if it does, assign ANOMALIES=1
    %check if T_peak is empty

    RR=interp1(T_peak(1:end-1),RR_unfiltered,TQ,'PCHIP');
    end 
end 

end 