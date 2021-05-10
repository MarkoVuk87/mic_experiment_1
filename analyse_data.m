%% Analysis

function [out] = analyse_data(input_data, freqs_to_analyse, channels)
    fprintf("Analysing data.....");
    % Extract the first column that contains frequencies 
    frequencies = input_data(:,1);
    % Remove from input_data
    input_data(:,1) = [];
    % Find indices that correspond to the frequencies we want to monitor
    test_indices = [];
    for index = 1:length(freqs_to_analyse)
        test_indices = [test_indices, find(frequencies == freqs_to_analyse(index))];
    end
    % Select the data for analysis
    struct_idx = 1;
    for channel = 1:length(channels)
        if length(channels) == 1
            data = input_data;
        else
            data = input_data(:, channel:2:end);
        end
        for index = 1:length(test_indices)
            data_slice = data(test_indices(index), :);
            clear values
            values.freq = freqs_to_analyse(index);
            values.channel = channels(channel);
            values.data = data_slice;
            values = catstruct(values, datastats(data_slice'));
            out(struct_idx) = values;
            struct_idx = struct_idx + 1;
        end
    end
    if ~exist('out','var')
        disp('nema out???')
    end
    
    fprintf("DONE\n");
end 