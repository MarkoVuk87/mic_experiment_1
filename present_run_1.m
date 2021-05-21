clc
clear all
close all

folder = uigetdir;
if folder == 0
    disp("No folder selected - END")
    return
end
data_file = dir(strcat(folder, '/**/data*.xls'));
zip_filename = dir(strcat(folder, '/**/*.zip'));
audio_files = unzip(strcat(folder, '/', zip_filename.name), 'archive_test');
% audio_files = audio_files(1);
% plot_audio_raw(audio_files);
% plot_audio_fft(audio_files);
plot_audio_fft(audio_files);
disp("END");


function [] = plot_audio_raw(audio_files)
    for i = 1:length(audio_files)
        figure
        tiledlayout(4, 1)
        audio_file = string(audio_files(i));
        [audio_raw, audio_sample_freq] = audioread(audio_file);
        nexttile
        plot(audio_raw);    
        [thetadeg, theta, phi] = find_phase(audio_raw);
        xlabel(sprintf('\\theta = %.3f rad = %.3f\\circ', theta, thetadeg));
        nexttile
        plot(audio_raw(:,1));
        nexttile
        plot(audio_raw(:,2));
        nexttile
        plot(audio_raw(:,2)-audio_raw(:,1));
    end
end

function [] = plot_audio_fft(audio_files)
    for i = 1:length(audio_files)
        figure
        tiledlayout(4, 1)
        audio_file = string(audio_files(i));
        [audio_raw, audio_sample_freq] = audioread(audio_file);

        df = 1;
        freqs = -audio_sample_freq/2:df:audio_sample_freq/2-df;
        audio_fft = abs(fftshift(fft(audio_raw, audio_sample_freq))/audio_sample_freq);
        diff_fft = abs(fftshift(fft(audio_raw(:,2)-audio_raw(:,1), audio_sample_freq))/audio_sample_freq);
   
        nexttile
        plot(audio_raw);    
        [thetadeg, theta, phi] = find_phase(audio_raw);
        xlabel(sprintf('\\theta = %.3f rad = %.3f\\circ', theta, thetadeg));
        nexttile
        plot(freqs, audio_fft);
        xlabel('f_n')
        title("both mics fft")
        nexttile
        plot(freqs, audio_fft(:,2)-audio_fft(:,1));
        title("difference of fft1 - fft2")
        xlabel('f_n')   
        nexttile
        plot(freqs, diff_fft);
        title("difference found in time-domain, then fft")
        xlabel('f_n')       
    end
end

function [] = plot_raw_fft_phase(audio_files)
    for i = 1:length(audio_files)
        figure
        tiledlayout(4, 1)
        audio_file = string(audio_files(i));
        [audio_raw, audio_sample_freq] = audioread(audio_file);

        df = 1;
        freqs = -audio_sample_freq/2:df:audio_sample_freq/2-df;
        audio_fft = abs(fftshift(fft(audio_raw, audio_sample_freq))/audio_sample_freq);
        diff_fft = abs(fftshift(fft(audio_raw(:,2)-audio_raw(:,1), audio_sample_freq))/audio_sample_freq);
        nexttile
        plot(freqs, audio_fft(:,1));
        xlabel('f_n')
        title("fft1 - microphone adjacent to noise speaker")
        nexttile
        plot(freqs, audio_fft(:,2));
        xlabel('f_n')    
        title("fft2 - microphone adjacent to signal speaker")
        nexttile
        plot(freqs, audio_fft(:,2)-audio_fft(:,1));
        title("difference of fft1 - fft2")
        xlabel('f_n')   
        nexttile
        plot(freqs, diff_fft);
        title("difference found in time-domain, then fft")
        xlabel('f_n')       
    end
end

function [thetadeg, theta, phi] = find_phase(audio_raw)
    C1 = audio_raw(:,1);
    C2 = audio_raw(:,2);
    C1s = [mean(C1); 2*std(C1)];
    C2s = [mean(C2); 2*std(C2)];
    sinsum = C1 + C2;
    sinsums = [mean(sinsum); 2*std(sinsum)];
    c_fcn = @(theta) sqrt(C1s(2).^2 + C2s(2).^2 + 2*C1s(2).*C2s(2).*cos(theta)) - sinsums(2);
    theta = fzero(c_fcn, 1);
    thetadeg = theta*180/pi;
    phi_fcn = @(theta) atan2(C2s(2).*sin(theta), C1s(2) + C2s(2).*cos(theta));
    phi = fminsearch(@(b)norm(phi_fcn(b)), 1);
end