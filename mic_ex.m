function [out] = mic_ex(desc)
    sound_ex = SoundHelper(desc.freq_inner, desc.freq_outer);
    sound_ex.play();
    filenames = record_audio(num_runs, seconds);
    sound_ex.stop();
    
    %% Process
    fft_all_runs = process_audio(filenames, channels, desc.fft_points_no);
    % Analyse
    data_stats = analyse_data(fft_all_runs, monitored_freqs, channels);
    out = data_stats;    
    out.desc = desc;
end
