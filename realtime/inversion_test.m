
%checking if ECG is inverted 

function x= inversion_test(x,fs)

% generate highpass filter coefficients of 4th order highpass digital
% Butterworth filter with normalised cutoff frequency of 1 Hz
[b,a]=butter(4,[1]/(fs/2),'high');

% carry out zero-phase digital filtering to reduce noise in the signal and
% preserve the QRS complex at the same time it occurs at the original 

% carry out zero-phase digital filtering the with 4th order high-pass
% Butterworth filter. x is ECG samples 
y=filtfilt(b,a,x);

% skewness(y) <0 means that data is spread out more to the left of the mean
% than to the right, this means that ECG could have negative values
%test for inversion
if skewness(y)<0 %ECG may be inverted, change the sign of the ECG
    x=x*-1;
    disp('Sign of ECG has been changed');
end

end 
