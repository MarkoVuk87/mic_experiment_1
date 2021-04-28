figure
tiledlayout(4,1) 

% Top plot
% nexttile
% plot(frequency_audio, abs(fft_audio_in))
% title('Both sounds FFT')
% xlabel('Frequency(Hz)');
% ylabel('Amplitude');

% Middle plot - outer mic
nexttile
plot(frequency_audio, abs(left_fft));
title('Outer mic FFT')
xlabel('Frequency(Hz)');
ylabel('Amplitude');

% Bottom plot - inner mic
nexttile
plot(frequency_audio, abs(mean_left));
title('Inner mic FFT')
xlabel('Frequency(Hz)');
ylabel('Amplitude');

nexttile
plot(frequency_audio, abs(mean_right));
title('Outer mic FFT mean')
xlabel('Frequency(Hz)');
ylabel('Amplitude');

nexttile
plot(frequency_audio, abs(right_fft));
title('Inner mic FFT mean')
xlabel('Frequency(Hz)');
ylabel('Amplitude');

csv_file = strrep(audio_file,"wav","csv");
writematrix(abs(fft_audio_in), csv_file)

movefile(audio_file,'rec');
movefile(csv_file,'rec');

% % Bottom plot - inner mic
% nexttile
% plot(frequency_audio_1,abs(fft_1000));
% title('combination')
% xlabel('Frequency(Hz)');
% ylabel('Amplitude');
% 
% nexttile
% plot(frequency_audio,abs(right_fft+left_fft));
% title('combination')
% xlabel('Frequency(Hz)');
% ylabel('Amplitude');
