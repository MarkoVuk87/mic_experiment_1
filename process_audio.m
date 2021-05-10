function [out_fft_all] = process_audio(audio_files, channels, fft_dimension)
    fprintf("Processing data\n")
    
    fprintf("Calculating FFT from audio files...")    
%     fft_all_runs = zeros(fft_dimension, length(audio_files));
    for index = 1:length(audio_files)
        single_fft = calc_fft_audio_single(audio_files(index), channels, fft_dimension);
        if ~exist('out_fft_all', 'var')
            out_fft_all = single_fft;
        else
            out_fft_all = [out_fft_all, single_fft(:, 2:end)];
        end    
    end 
    fprintf("...DONE\n");
    

end

function [out] = calc_fft_audio_single(audio_file, channels, fft_dimension)
    [audio_raw, audio_sample_freq] = audioread(audio_file);
    % Remove frequencies lower than 10Hz
%     audio_raw = highpass(audio_raw, 10, audio_sample_freq);
    if ~exist('fft_dimension','var')
        % third parameter does not exist, so default it to something
        fft_dimension = length(audio_file);
    end
    df = audio_sample_freq/fft_dimension;
    freqs = -audio_sample_freq/2:df:audio_sample_freq/2-df;
    out = freqs';
    audio_fft = abs(fftshift(fft(audio_raw, fft_dimension))/fft_dimension);
    for channel = 1:length(channels)
        out = [out, audio_fft(:, channel)];
    end
end


