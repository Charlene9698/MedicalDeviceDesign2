clear all;
close all;
clc;

%Divide the training set into about 70% of the data in the training set,
%30% of the data in the test set
% different ampthresh values are tested and the one that gives no anomaly
% is chosen

%% Load the files 

% plot of lead 1
% The data is from ECG Lead 1, recorded for 20 seconds, digitised at 500 Hz
% with 12-bit resolution 

%create an array to store all the examples 
examples=zeros(1,27427);

fsECG=500;
%load the ECG data
M=dlmread('onemin.txt');

%show figure
figure(1)
plot(M);
%%
%test dfferent ampthresh values 
ampthresh=100; 

%test different anomalyparam values 
anomalyparam= 0.7;

[xRRI, yECG,ANOMALIES] =ECG_to_RRIadapt(M, fsECG, 'ampthresh',ampthresh,'anomalyparam',anomalyparam);
anomalyvector2=sum(ANOMALIES);
hmatrix=60./xRRI;

meanh=mean(hmatrix);
