%% Open the text file containing 1 minute of data
data_matrix = load("onemin.txt");

%%Pass the data from the text file into the code to be processed
process_data = ECG_to_RRI(data_matrix, 500)
