clc
close all
clear classes

insomnia('on','verbose'); 
%% Global setup
channel = ["signal"  "left"; "noise" "right"];

descriptor.length_noise = 50;
descriptor.length_signal = 10;

% test_freqs = [100, 150];
% for index = 3:12
%     test_freqs = [test_freqs test_freqs(index-1)+50];
% end
test_freqs=200;
do_plotting = 1;
descriptor.sec_recording = 2;
descriptor.num_runs = 10;
descriptor.mic_no = 23;
descriptor.channels = [1, 2];
descriptor.fft_points_no = 2000;    

index_store = 1;
filenames = [];

for id = 1:length(test_freqs)
    % Perform run
    descriptor.freq_signal = 0;
    descriptor.freq_noise = test_freqs(id);
    fprintf("Start of the baseline run %d (%d/%d)\n", descriptor.freq_noise, id, length(test_freqs));
    monitored_freqs = [descriptor.freq_noise];
    
    % Reloading the python module
    audio_capture = py.importlib.import_module('audio_capture');
    py.importlib.reload(audio_capture);
    fprintf("python script version -> %s\n", string(py.audio_capture.version()));

    sound_ex = SoundHelper(descriptor.freq_signal, descriptor.freq_noise);
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
        temp.run_id = id;
        temp = catstruct(descriptor, temp);
        temp.channel_name = channel(data_stats(index).channel, 1);
        all_data(index_store) = catstruct(data_stats(index), temp);
        index_store = index_store + 1;
    end
    fft_all_runs = [fft_one_run, fft_one_run];
    filenames = [filenames, filenames_run];
end

%% Plot all
% Uncomment if you want to plot
if do_plotting
    % Extract frequencies from the matrix for x axis of plot
    freq = fft_all_runs(:, 1)';
    for channel = 1:length(descriptor.channels)
        plot_data = fft_all_runs(:, 1+descriptor.channels(channel):2:end);
        figure
        tiledlayout(4,3)
        for index = 1:length(filenames)
            nexttile
            
            plot(freq, plot_data(:, index));
            title(filenames(index));
            xlabel('Frequency(Hz)');
            ylabel('Amplitude');
        end
    end
end


%% Archive the run
prompt = 'Do you want to save results (y/n)? ';
while true
    answer = input(prompt, 's');
    if answer == 'y'
        archive_dir_name="rec/test" + datestr(now,'_yyyymmdd_HHMM') + "_mic_" + descriptor.mic_no;
        mkdir(archive_dir_name);
        % make filename for excel file
        file_save="test_" + datestr(now,'_yy-mm-dd_HH-MM-SS') + ".xls";
        % write all recorded ffts to excel and move to rec folder
        writematrix(fft_all_runs, file_save);
        movefile(file_save, archive_dir_name);
        % write processed data to excel and move to rec folder
        data_save = replace(file_save, "test_", "data_");
        writetable(struct2table(all_data), data_save);
        movefile(data_save, archive_dir_name);
        % move all audio files to rec folder
        for index = 1:length(filenames)
            movefile(filenames(index), archive_dir_name)
        end
        break
    elseif answer == 'n'
        for index = 1:length(filenames)
            delete (filenames(index))
        end
        break
    else
        prompt = 'Wrong answer, y or n: ';
    end   
end
insomnia('off','verbose'); 
fprintf("end of script\n");