clc
close all
clear classes
insomnia('on','verbose'); 

%% Global setup
channel = ["noise" "right"; "signal"  "left"];

descriptor.length_outer = 70;
descriptor.length_inner = 10;

% test_freqs = [0, 150, 250, 300, 500];
test_freqs = [90, 100, 110];
descriptor.sec_recording = 1;
descriptor.num_runs = 3;
descriptor.mic_no = 13;
descriptor.channels = [1, 2];
descriptor.fft_points_no = 16000; 
descriptor.cover = "on";

index_store = 1;
filenames = [];

sound_ex = SoundHelper();
signal_freq = 0;
for i = 0:19
    noise_freqs(i+1) = 100 + 5 * i;
end
% noise_freqs = 550;
% sequence_of_runs = fullfact([length(test_freqs) length(test_freqs)]);
sequence_of_runs = fix_signal_cycle_noise(signal_freq, noise_freqs);
% Remove both zeros from sequence of runs
sequence_of_runs(ismember(sequence_of_runs, [0,0], 'rows'),:) = [];
for row = 1:height(sequence_of_runs)
    % Perform run
    descriptor.freq_signal = sequence_of_runs(row, 1);
    descriptor.freq_noise = sequence_of_runs(row, 2);
    fprintf("Start of the run %d - %d (%d/%d)\n", descriptor.freq_signal, descriptor.freq_noise, row, height(sequence_of_runs));
    monitored_freqs = [descriptor.freq_signal, descriptor.freq_noise];

    % Reloading the python module
    audio_capture = py.importlib.import_module('audio_capture');
    py.importlib.reload(audio_capture);
    fprintf("python script version -> %s\n", string(py.audio_capture.version()));

    sound_ex.setup(descriptor.freq_signal, descriptor.freq_noise);
    sound_ex.play();
    pause('on');
    pause(5);
    try
        filenames_run = record_audio(descriptor.num_runs, descriptor.sec_recording);
    catch
        warning('Something is wrong with recording audio');
        sound_ex.stop();
        return
    end
    sound_ex.stop();
    pause('off');


    %% Process
    clear fft_one_run
    fft_one_run = process_audio(filenames_run, descriptor.channels, descriptor.fft_points_no);
    % Analyse
    clear data_stats
    data_stats = analyse_data(fft_one_run, monitored_freqs, descriptor.channels);
    for index = 1:length(data_stats)
        clear temp
        temp.run_id = row;
        temp = catstruct(descriptor, temp);
        temp.channel_name = channel(data_stats(index).channel, 1);
        processed_data(index_store) = catstruct(data_stats(index), temp);
        index_store = index_store + 1;
    end
    raw_data = [fft_one_run, fft_one_run];
    filenames = [filenames, filenames_run];
end

%% Archive the run
prompt = 'Do you want to save results (y/n)? ';
while true
    answer = input(prompt, 's');
    if answer == 'y'
        archive_dir_name="rec/test" + datestr(now,'_yyyymmdd_HHMM');
        mkdir(archive_dir_name);
        % make filename for excel file
        file_save="test_" + datestr(now,'_yy-mm-dd_HH-MM-SS') + ".xls";
        % write all recorded ffts to excel and move to rec folder
        writematrix(raw_data, file_save);
        movefile(file_save, archive_dir_name);
        % write processed data to excel and move to rec folder
        data_save = replace(file_save, "test_", "data_");
        writetable(struct2table(processed_data), data_save);
        movefile(data_save, archive_dir_name);
        % move all audio files to rec folder
        zip(archive_dir_name + '/recordings.zip', filenames);
        break
    elseif answer == 'n'
        break
    else
        prompt = 'Wrong answer, y or n: ';
    end   
end
% Clean up
for index = 1:length(filenames)
    delete (filenames(index))
end
insomnia('off','verbose'); 
fprintf("end of script\n");


function [runs] = fix_signal_cycle_noise(signal_freq, noise_freqs)
    runs = repmat(signal_freq, length(noise_freqs), 1);
    runs(:, 2) = noise_freqs';
end

function [runs] = base_level(noise_freqs)
    runs = fix_signal_cycle_noise(0, noise_freqs);
end