function [xRRI, yECG, ANOMALIES] =ECG_to_RRIadapt(varargin)

%Adapted from  David Looney, modified to suit project
% -------------------------------------------------------------------------
% Syntax: 
%          [xRRI,fsRRI]=ECG_to_RRI(xECG,fsECG);
% -------------------------------------------------------------------------
% Description:
%
% Converts ECG time series input into RR Interval time series.
% 
% Type of artifacts and noise on the ECG:
% 1. Muscle: 5 to 50 Hz
% 2. Respiratory: 0.12 -0.5Hz 
% 3. External electrical: 50 or 60 Hz (A/C mains or line frequency)
% 4. Other electrical: Typically >10Hz 
% 
% Kinds of filtering required:
% 1. Notch filter: To eliminate line frequency 
%
% This code does the following:
% The data is dvided into 3 sets, the training set, the cross-validation
% set and the test set
%
% For the Training set:
% Step 1: Bandpass filtering of ECG (we use 5 to 20 Hz). 20Hz because the
% variations of power spectrum of the ECG is observed to be 0-20Hz in the
% frequency domain
% (https://www.sciencedirect.com/science/article/pii/S0898122107005019)
% also from
% (http://www.ems12lead.com/2014/03/10/understanding-ecg-filtering/)
%
% Step 2: Learn ampthresh from machine learning (training set). Basically
% different ampthresh values are used and the ampthresh values with the
% lowest cost function will be used. The lowest cost function will
% correlate with the lowest number of anomalies 
% Step 3: Estimated of R peaks. The difference between R peaks is sampled 
% at regular intervals (controlled by parameter fsRRI) to generate the RRI.
% Cubic spline interpolation is the preferred method of interpolation.
% 
% For the Cross-Validation Set:
% This is used to check values such as the learning rate, regularisation
% parameter et cetera 
%
% For the Test set:
% The data is treated in the similar manner. The user is presented with a
% plot of the final RRI with detected anomalies, and a plot of the RRI with anomalies removed
% -------------------------------------------------------------------------
% Required inputs:
% 
%       xECG  ~  An ECG time series. The expected voltage range is microvolt.
%                At least 5 s of ECG is required to estimate the RRI.
%       fsECG ~  The sampling frequency of the ECG. Recordings with
%                sampling frequencies below 32 Hz will be rejected.
%                (Insufficient for analysis)
% 
% -------------------------------------------------------------------------
% Outputs:
% 
%       xRRI  ~  The RR interval (RRI) time series, sampled at regular
%                intervals.
%       fsRRI ~  The sampling frequency of the RRI. Recordings with
%       sampling frequency below 32 Hz will be rejected (because of the
%       Nyuqist Thereom?)
% -------------------------------------------------------------------------
% Parameters:
% 
%       Hp             ~    High pass ECG filter cutoff (in Hz).
%       Lp             ~    Low pass ECG filter cutoff (in Hz).
%       ampthresh      ~    Minimum R peak amplitude. 
%       ampthresh_autodetect ~ 'Y' (default) or 'N'. The user can let the function 
%                           pick an appropriate value for 'ampthresh'.   
%       timethresh     ~    Minimum time distance between R peaks (in s). 
%       fsRRI          ~    The sampling frequency of the RRI.
%       anomalyparam   ~    Controls the sensitivity of the anomaly detection
%                           algorithm. The larger the value, the less
%                           sensitive the algorithm.
%       AAR            ~    Automatic anomaly removal, 'N' (default) or
%       'Y'.
%                           When set to 'Y', all deteted anomalies are removed.           
% 
% Parameter values can be changed from their default values in the following
% way:
%          [xRRI,fsRRI]=ECG_to_RRI(xECG,fsECG,'timethresh',0.5);
% 
% In the above, the user has selected the parameter 'timethresh' as 0.5 s.
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% load inputs and parameters


[xECG,fsECG,hpECG,lpECG,fsRRI,ampthresh,timethresh,anomalyparam,ampthresh_autodetect,AAR] = init(varargin{:});
%time of parameters that can be loaded into the function

% perform inversion test=> it's a function
xECG = inversion_test(xECG,fsECG);
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
yECG=filtfilt(b,a,xECG);

% if ampthresh_autodetect is selected, the amplitude threshold is selected
% in an automatic fashion
% See section on default parameter values. 
if strcmp(ampthresh_autodetect,'Y')
    ampthresh=3.4*std(yECG);
end

% calculate RRI
[~,xRRI, ANOMALIES]=get_RRI(yECG,fsECG,fsRRI,ampthresh,timethresh,anomalyparam,AAR);

end 



