close all
clear classes

% Reloading the python module
audio_capture = py.importlib.import_module('audio_capture');
py.importlib.reload(audio_capture);
fprintf("python script version -> %s\n", string(py.audio_capture.version()));

%% Global setup

do_plotting = true;
monitored_freqs = 200;
num_runs = 12;
mic_no = 23;
sec_recording = 1;
channels = [1,2];
channels_total = channels * num_runs;
% 
% field1 = 'num_runs';    value1 = 12;
% field2 = 'mics';        value2 = {'inner_1', 'outer_1'};
% field3 = 'channel';     value3 = {'left', 'right'};
% 
% s = struct(field1,value1,field2,value2,field3,value3);

fft_dim = 1000;

%% Start
prompt = 'Use previously recorded sound (y/n)? If you select n the recording will start now: ';
while true
    answer = input(prompt, 's');
    if answer == 'y'
        [filenames, path]=uigetfile('*.wav','Select the INPUT DATA FILE(s)','MultiSelect','on');
        if filenames ~= 0
            filenames=string(filenames);
        else
            fprintf('No files selected, ending the script\n');
            return
        end
        break
    elseif answer == 'n'
        filenames = record_run(num_runs);
        break
    else
        prompt = 'Wrong answer, y or n: ';
    end   
end

%% Process
fft_all_runs = zeros(fft_dim, num_runs);
for index = 1:num_runs
    [freq, audio_fft] = process_audio(filenames(index), channel_select, fft_dim);
    if channel_select == 0
        fft_all_runs(index) = audio_fft;
    else
        fft_all_runs(:, index) = audio_fft;
    end    
end 

if is_freq_monitored
    data_stats = analyse_data(fft_all_runs, freq, monitored_freqs, channels);
end

%% Plot all
% Uncomment if you want to plot
if do_plotting
    for index = 1:length(channels)
        if channels == 2
            plot_data = fft_all_runs(:, channel:2:end);
        else
            plot_data = fft_all_runs;
        end
        figure
        tiledlayout(4,3)
        for index = 1:num_runs
            nexttile
            plot(freq, abs(plot_data(:, index)));
            title('FFT channel %d', index);
            xlabel('Frequency(Hz)');
            ylabel('Amplitude');
        end
    end
end

%% Archive the run

archive_dir_name="rec/test" + datestr(now,'_yyyymmdd_HHMM') + "_mic_" + mic_no;
mkdir(archive_dir_name);
% make filename for excel file
file_save="test_" + string(monitored_freqs) + datestr(now,'_yy-mm-dd_HH-MM-SS') + ".xls";
% write all recorded ffts to excel and move to rec folder
writematrix(abs(fft_all_runs), file_save);
movefile(file_save, archive_dir_name);
% write processed data to excel and move to rec folder
data_save = replace(file_save, "test_", "data_");
writetable(struct2table(data_stats), data_save);
movefile(data_save, archive_dir_name);
% move all audio files to rec folder
for index = 1:num_runs
    movefile(filenames(index), archive_dir_name)
end
fprintf("end of script\n");



%% Recording audio file
function [audio_filename] = record_audio(seconds)
    fprintf("Start recording......")
    try
        res_py = py.audio_capture.record(seconds);
        cRes = cell(res_py);
        status = cRes{1};
        if status == 2
            audio_filename = string(cRes{2});
            fprintf("DONE\n")
        else
            audio_filename = "error";
            fprintf("ERROR\n")
            return
        end
    catch e
        e.message
        if(isa(e,'matlab.exception.PyException'))
            e.ExceptionObject
        end
    end
    pause on
    while not(isfile(audio_filename))
      pause(0.1);
    end
    pause off
end

%% Prepare audio file
function [freq, fft_abs] = prepare_audio_fft(audio_file, channel, len_fft)
    fprintf("Processing data......")
    [audio_in, audio_freq_sampl]=audioread(audio_file);
    % Remove frequencies lower than 10Hz
    audio_in=highpass(audio_in, 10, audio_freq_sampl);
    if ~exist('len_fft','var')
        % third parameter does not exist, so default it to something
        len_fft = len(audio_in);
    end
    df=audio_freq_sampl/len_fft;
    freq=-audio_freq_sampl/2:df:audio_freq_sampl/2-df;
    
    fft_audio_in=fftshift(fft(audio_in, len_fft))/len_fft;
    if channel == 0
        fft_abs = abs(fft_audio_in);  
    else
        fft_abs = abs(fft_audio_in(:, channel));
    end
    fprintf("DONE\n");
end

%%
function [list_of_filenames] = record_run(num_attempts)
    index = num_attempts;
    while index > 0
        fprintf("Attempt %i of %i: ", num_runs+1-index, num_runs);
        audio_file=record_audio(sec_recording);
        if audio_file ~= "error"
            list_of_filenames(:,index)=audio_file;
            index = index-1;
        end
    end
end