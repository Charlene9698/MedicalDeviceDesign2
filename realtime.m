clear all;
%Initialise
samplesPerFrame=500; % this is the sampling frequency
playTime=20; %Device will record user data for 20 seconds (need a minimum time to get the average heart rate) 
%set ampthresh as 100 first
ampthresh=100;
%set anomaly values as 0.7 first
anomalyparam=0.7;

% Find available Bluetooth devices 
instrhwinfo('Bluetooth');

% Construct Bluetooth object called b using channel 1 
instrhwinfo('Bluetooth', 'HC-ECG');
b=Bluetooth('HC-ECG', 1);

% Connect to remote device 
fopen(b);

% Send a message to the remote device using fwrite function
fwrite(b, uint8([2,0, 1, 155]));

tstart=tic; % start the stopwatch timer

%Read data through a simple while loop, until the time reaches the value
%previously defined in playTime

decision=0;
datamatrix=[]; % define name as an empty array first
while decision==0
    
    % prompts user if they want to take a recording 
    prompt= 'Do you want to take a recording?'; 
    str=input(prompt,'s');
    if isempty(str)
        str='Y';
    end 
    
    %If user no longer wants to take a recording, break out of the loop
    if str=='N'
        decision=1;
        break;
    end 
    if str=='Y'
        while toc(tstart)< playTime
            % Read data from remote device using fread function
            data=fread(b,35);

            % add the data into an array
            datamatrix=[datamatrix data];

        end

        % process the heart rate after getting the data
        fprintf('Processing Heart Rate');

        [xRRI, yECG,ANOMALIES] =ECG_to_RRIadapt(datamatrix, samplesPerFrame, 'ampthresh',ampthresh,'anomalyparam',anomalyparam);
        anomalyvector2=sum(ANOMALIES);

        %obtain the mean heart rate for the twenty seconds
        hmatrix=60./xRRI;
        meanh=mean(hmatrix);

        %display the number of anomalies and the mean heart rate
        fprintf('Mean Heart Rate:%d', meanh);
        fprintf('Number of Anomalies: %d', anomalyvector2);
    end

end 

%Disconnect the bluetooth Device
fclose(b);

%Clean up by deleting and clearing the object
clear('b');
