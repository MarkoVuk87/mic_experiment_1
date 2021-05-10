clc
close all
clear classes
insomnia('on','verbose'); 
% 
% % Reloading the python module
% audio_capture = py.importlib.import_module('audio_capture');
% py.importlib.reload(audio_capture);
% fprintf("python script version -> %s\n", string(py.audio_capture.version()));

%% Global setup

do_plotting = true;
monitored_freqs = 300;
num_runs = 12;
mic_no = 23;
sec_recording = 10;
channels = [1, 2];
fft_points_no = 1000;

% field1 = 'num_runs';    value1 = 12;
% field2 = 'mics';        value2 = {'outer_1', 'inner_1'};
% field3 = 'channel';     value3 = {'left', 'right'};
% 
% s = struct(field1,value1,field2,value2,field3,value3);


%% Start
prompt = 'Use previously recorded sound (y/n)? If you select n the recording will start now: ';
while true
    answer = input(prompt, 's');
    if answer == 'y'
        [filenames, path]=uigetfile('*.wav','Select the INPUT DATA FILE(s)','MultiSelect','on');
        if isfloat(filenames)
            error('No files selected')
        end
        filenames = strcat(path, string(filenames));
        break
    elseif answer == 'n'
        [player_inner, player_outer] = start_sound(300);
        filenames = record_audio(num_runs, sec_recording);
        stop(player_inner);
        stop(player_outer);
        break
    else
        prompt = 'Wrong answer, y or n: ';
    end   
end

%% Process
fft_all_runs = process_audio(filenames, channels, fft_points_no);
% Analyse
data_stats = analyse_data(fft_all_runs, monitored_freqs, channels);

%% Plot all
% Uncomment if you want to plot
if do_plotting
    % Extract frequencies from the matrix for x axis of plot
    freq = fft_all_runs(:, 1)';
    for channel = 1:length(channels)
        plot_data = fft_all_runs(:, 1+channels(channel):2:end);
        figure
        tiledlayout(4,3)
        for index = 1:length(filenames)
            nexttile
            
            plot(freq, plot_data(:, index));
            title('FFT channel', index);
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
        archive_dir_name="rec/test" + datestr(now,'_yyyymmdd_HHMM') + "_mic_" + mic_no;
        mkdir(archive_dir_name);
        % make filename for excel file
        file_save="test_" + datestr(now,'_yy-mm-dd_HH-MM-SS') + ".xls";
        % write all recorded ffts to excel and move to rec folder
        writematrix(fft_all_runs, file_save);
        movefile(file_save, archive_dir_name);
        % write processed data to excel and move to rec folder
        data_save = replace(file_save, "test_", "data_");
        writetable(struct2table(data_stats), data_save);
        movefile(data_save, archive_dir_name);
        % move all audio files to rec folder
        for index = 1:num_runs
            movefile(filenames(index), archive_dir_name)
        end
        break
    elseif answer == 'n'
        filenames = record_run(num_runs);
        break
    else
        prompt = 'Wrong answer, y or n: ';
    end   
end
insomnia('off','verbose'); 
fprintf("end of script\n");