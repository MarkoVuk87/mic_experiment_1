
classdef SoundHelper < handle
    properties
        frequency_signal {mustBeNumeric}
        frequency_noise {mustBeNumeric}
    end
    properties (Access = private)
        player_signal
        player_noise
        audio_dev_id_noise
        audio_dev_id_signal
    end
    methods
        function this = SoundHelper()
            audiodevreset
            info = audiodevinfo;
            for idx = 1:length(info.output)
                if contains(info.output(idx).Name, 'JBL')
                    this.audio_dev_id_noise = info.output(idx).ID;
                end
                if contains(info.output(idx).Name, 'USB PnP')
                    this.audio_dev_id_signal = info.output(idx).ID;
                end
            end 
        end
        function this = setup(this, freq_signal, freq_noise)
            Fs = 48000;        % Samples per second
            nSeconds = 1000;      % Duration of the sound
            this.frequency_signal = freq_signal;
            this.frequency_noise = freq_noise;
            if freq_signal ~= 0
                X_signal = sin(linspace(0, nSeconds*this.frequency_signal*2*pi, round(nSeconds*Fs)));
                this.player_signal = audioplayer(X_signal,Fs,16,this.audio_dev_id_signal);
            else
                this.player_signal = 0;
            end 
            
            if freq_noise ~= 0
                Y_noise = sin(linspace(0, nSeconds*this.frequency_noise*2*pi, round(nSeconds*Fs)));
                this.player_noise = audioplayer(Y_noise,Fs,16,this.audio_dev_id_noise);
            else
                this.player_noise = 0;
            end  
        end
       
        function this = play(this)
            if this.frequency_signal ~= 0
                play(this.player_signal);
            end
            if this.frequency_noise ~= 0
                play(this.player_noise);
            end
            disp('Starting the sound');
        end
        function this = stop(this)
            if this.frequency_signal ~= 0
                stop(this.player_signal);
            end
            if this.frequency_noise ~= 0
                stop(this.player_noise);
            end
            disp('Stop the sound');
        end
    end
end