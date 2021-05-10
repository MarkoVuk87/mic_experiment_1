clc
close all
clear classes
insomnia('on','verbose'); 
%% Global setup
channel = ["outer" "right"; "inner"  "left"];

descriptor.length_outer = 50;
descriptor.length_inner = 10;

test_freqs = [0, 150, 250, 300, 500];
descriptor.sec_recording = 3;
descriptor.num_runs = 10;
descriptor.mic_no = 13;
descriptor.channels = [1, 2];
descriptor.fft_points_no = 2000; 
descriptor.cover = "off";

index_store = 1;
filenames = [];

sound_ex = SoundHelper();

dFF = fullfact([length(test_freqs) length(test_freqs)]);
for id = 1:length(dFF)
    pair = dFF(id, :);
    % Skip zero frequency on both speakers
    if test_freqs(pair(1)) ~= 0 || test_freqs(pair(2)) ~= 0
        % Perform run
        descriptor.freq_inner = test_freqs(pair(1));
        descriptor.freq_outer = test_freqs(pair(2));
        fprintf("Start of the run %d - %d (%d/%d)\n", descriptor.freq_inner, descriptor.freq_outer, id, length(dFF));
        monitored_freqs = [descriptor.freq_inner, descriptor.freq_outer];
        
        % Reloading the python module
        audio_capture = py.importlib.import_module('audio_capture');
        py.importlib.reload(audio_capture);
        fprintf("python script version -> %s\n", string(py.audio_capture.version()));
        
        sound_ex.setup(descriptor.freq_inner, descriptor.freq_outer);
        sound_ex.play();
        filenames_run = record_audio(descriptor.num_runs, descriptor.sec_recording);
        sound_ex.stop();

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
        break
    else
        prompt = 'Wrong answer, y or n: ';
    end   
end
insomnia('off','verbose'); 
fprintf("end of script\n");