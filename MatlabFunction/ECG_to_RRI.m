
function [meanh, anomalyvector2] =ECG_to_RRI(varargin)


xECG = varargin{1};
fsECG = varargin{2};
%xECG=str2num(datamatrix);

if size(xECG,1) > 1
  xECG = xECG.';
end

if ~isscalar(fsECG)
  error('''fsECG'' must be a scalar.')
end

if (fsECG)<32
  error('The ECG sampling frequency is insufficiently low for analysis (<32 Hz).')
end

if (fsECG)<120
  disp('Warning. The ECG sampling frequency is below the recommended value (<120 Hz).')
end

if ceil(length(xECG)/fsECG)<10
  error('At least 10 s of ECG are required to calculate RRI.')
end

if nargin>2
    inopts = struct(varargin{3:end});
end
parameter_fields = {'hpECG','lpECG','fsRRI','ampthresh','anomalyparam','timethresh','ampthresh_autodetect','AAR'};

% default parameter values
default_params.hpECG = 5; % high cut-off frequency
default_params.lpECG = 20; % low cut-off frequency
default_params.fsRRI = 4;
default_params.ampthresh = 100; 
default_params.timethresh = 0.4; 
default_params.anomalyparam = 0.7;
default_params.ampthresh_autodetect = 'Y';
default_params.AAR = 'N'; % areas at risk 
opts = default_params;

if nargin==2
    inopts = default_params;
end

parameters = fieldnames(inopts);

for parameter = parameters'
  if ~any(strcmpi(char(parameter), parameter_fields))
    error(['parameter not recognized: ',char(parameter)])
  end
  if ~isempty(eval(['inopts.',char(parameter)])) 
    eval(['opts.',(char(parameter)),' = inopts.',char(parameter),';'])
  end
end

hpECG = opts.hpECG;
lpECG = opts.lpECG;
fsRRI = opts.fsRRI;
ampthresh = opts.ampthresh;
timethresh = opts.timethresh;
anomalyparam = opts.anomalyparam;
AAR = opts.AAR;
if (any(strcmp(varargin,'ampthresh')))&&(any(strcmp(varargin,'ampthresh_autodetect')))
    %disp('Warning. Parameters ''ampthresh'' and ''ampthresh_autodetect'' have BOTH been selected. Auto-detection of the amplitude threshold has been turned OFF.')
    ampthresh_autodetect = 'N';
elseif (any(strcmp(varargin,'ampthresh')))
    ampthresh_autodetect = 'N';
    %disp('A parameter value for ''ampthresh'' has been selected. Auto-detection of the amplitude threshold has been turned OFF.')
else
    ampthresh_autodetect = opts.ampthresh_autodetect;
end

% perform inversion test=> it's a function
% generate highpass filter coefficients of 4th order highpass digital
% Butterworth filter with normalised cutoff frequency of 1 Hz
[b,a]=butter(4,[1]/(fsECG/2),'high');

% carry out zero-phase digital filtering to reduce noise in the signal and
% preserve the QRS complex at the same time it occurs at the original 

% carry out zero-phase digital filtering the with 4th order high-pass
% Butterworth filter. x is ECG samples 
y=filtfilt(b,a,xECG);

% skewness(y) <0 means that data is spread out more to the left of the mean
% than to the right, this means that ECG could have negative values
%test for inversion
if skewness(y)<0 %ECG may be inverted, change the sign of the ECG
    xECG=xECG*-1;
    disp('Sign of ECG has been changed');
end

% generate filter coefficients
try
    % pass through a bandpass filter with a lower cutoff frequency of hpECG
    % and a higher cutoff frequency of lpECG. See section on default
    % parameter values 
    [b,a]=butter(4,[hpECG,lpECG]/(fsECG/2),'bandpass');
catch
    % For more recent releases of MATLAB, this is a catch statement in case
    % the previous statement cannot work 
    [b,a]=butter(4,[hpECG,lpECG]/(fsECG/2),'pass');
end
% filter ECG with zero-phase digital filtering using a 4th order bandpass
% butterworth filter
xECG=filtfilt(b,a,xECG);

% if ampthresh_autodetect is selected, the amplitude threshold is selected
% in an automatic fashion
% See section on default parameter values. 
%if strcmp(ampthresh_autodetect,'Y')
 %   ampthresh=3.4*std(xECG);
%end
% calculate RRI

%get the sample duration of the ECG
T=[1:length(xECG)]/fsECG;

%get the sample duration in intervals of 1/RRI_fs to plot the RRI graph. Default RRI_fs is 4Hz.
%T= 1/f
TQ=[1:T(end)*fsRRI]/fsRRI;

% min peak distance in sample number
timethresh = ceil(timethresh*fsECG);
 
% find peaks in ECG. Restrict acceptable peak-to-peak separations to values
% greater than minpeakdistance. Peaks must be greater than minpeakheight. 
%y_peak refers to the height of the peaks, T_peak refers to the indices at which the peaks occur 
[y_peak,T_peak] = findpeaks(xECG,'MINPEAKDISTANCE',timethresh,'MINPEAKHEIGHT',ampthresh);


% divide by fs to get the location in time
T_peak=T_peak/fsECG; 

%this only works when the anomaly is low
RR_unfiltered=((diff((T_peak))));
 
%median is better for skewed data
RR_median=median(RR_unfiltered);

ANOMALIES= zeros(length(RR_unfiltered),1);

if isempty(T_peak)
    disp('Warning. No peaks were identified. Anomaly is set to 1')
    %show full anomaly
    ANOMALIES=ones(10,1);
    xRRI=0; %set RR to zero
else
    %duration of the sample
    number_seconds=ceil(length(xECG)/fsECG);
    %find number of peaks
    num_peaks=length(y_peak);
    %calculate beats per minute
    bpm=ceil(60*num_peaks/number_seconds);    
    
    if bpm<20
        disp('Warning. A small number of peaks were identified. Recommend adjusting the parameters. Anomalies are set to 1')
        %assign a value of 10 ones
        ANOMALIES=ones(10,1);
        xRRI=0; %set RR to zero
    elseif bpm>300
        disp('Warning. A large number of peaks were identified. Recommend adjusting the parameters.')
        ANOMALIES=ones(10,1);
        xRRI=0; %set RR to zero
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

    xRRI=interp1(T_peak(1:end-1),RR_unfiltered,TQ,'PCHIP');
    end 
end 

anomalyvector2=sum(ANOMALIES);
hmatrix=60./xRRI;
meanh=mean(hmatrix);
 
end 


 
