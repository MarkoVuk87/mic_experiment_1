function [freqs, fft_abs] = process_audio(audio_files, channels, fft_dimension)
    fprintf("Processing data\n")
    
    fprintf("Calculating FFT from audio files...")    
    fft_all_runs = zeros(fft_dimension, length(audio_files));
    for index = 1:length(audio_files)
        [freqs, audio_fft] = process_audio_helper(audio_files(index), channel_select, fft_dim);
        if channel_select == 0
            fft_all_runs(index) = audio_fft;
        else
            fft_all_runs(:, index) = audio_fft;
        end    
    end 
    fprintf("DONE\n");
    
    data_stats = analyse_data(fft_all_runs, find(freq==test_freq), channels);
end

function [freqs, fft_abs] = process_audio_helper(audio_file, channels, fft_dimension)
    [audio_raw, audio_sample_freq] = audioread(audio_file);
    % Remove frequencies lower than 10Hz
    audio_raw = highpass(audio_raw, 10, audio_sample_freq);
    if ~exist('len_fft','var')
        % third parameter does not exist, so default it to something
        fft_dimension = length(audio_file);
    end
    df = audio_sample_freq/fft_dimension;
    freqs = -audio_sample_freq/2:df:audio_sample_freq/2-df;
    
    audio_fft = fftshift(fft(audio_raw, fft_dimension))/fft_dimension;
    if length(channels) == 2
        fft_abs = abs(audio_fft);  
    else
        fft_abs = abs(audio_fft(:, channels));
    end
end

%% Analysis

function [out] = analyse_data(input_data, indices, chn_no)
    fprintf("Analysing data.....");
    for channel = 1:chn_no
        if chn_no == 2
            data = input_data(:, channel:2:end);
        else
            data = input_data;
        end
        
        for index = 1:width(data)
            idx_test = ;
            values(:, index) = abs(data(idx_test, index));
        end
        out(channel) = datastats(values');
%         out(channel).freq = test_fq;
%         out(channel).channel = channel;
    end
    fprintf("DONE\n");
end 
