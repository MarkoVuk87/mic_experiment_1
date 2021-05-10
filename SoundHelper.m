
classdef SoundHelper < handle
    properties
        frequency_inner {mustBeNumeric}
        frequency_outer {mustBeNumeric}
    end
    properties (Access = private)
        player_inner
        player_outer
        audio_dev_id_outer
        audio_dev_id_inner
    end
    methods
        function this = SoundHelper()
            audiodevreset
            info = audiodevinfo;
            for idx = 1:length(info.output)
                if contains(info.output(idx).Name, 'JBL')
                    this.audio_dev_id_outer = info.output(idx).ID;
                end
                if contains(info.output(idx).Name, 'USB PnP')
                    this.audio_dev_id_inner = info.output(idx).ID;
                end
            end 
        end
        function this = setup(this, freq_inner, freq_outer)
            Fs = 48000;        % Samples per second
            nSeconds = 1000;      % Duration of the sound
            this.frequency_inner = freq_inner;
            this.frequency_outer = freq_outer;
            if freq_inner ~= 0
                X_inner = sin(linspace(0, nSeconds*this.frequency_inner*2*pi, round(nSeconds*Fs)));
                this.player_inner = audioplayer(X_inner,Fs,16,this.audio_dev_id_inner);
            else
                this.player_inner = 0;
            end 
            
            if freq_outer ~= 0
                Y_outer = sin(linspace(0, nSeconds*this.frequency_outer*2*pi, round(nSeconds*Fs)));
                this.player_outer = audioplayer(Y_outer,Fs,16,this.audio_dev_id_outer);
            else
                this.player_outer = 0;
            end  
        end
       
        function this = play(this)
            if this.frequency_inner ~= 0
                play(this.player_inner);
            end
            if this.frequency_outer ~= 0
                play(this.player_outer);
            end
            disp('Starting the sound');
        end
        function this = stop(this)
            if this.frequency_inner ~= 0
                stop(this.player_inner);
            end
            if this.frequency_outer ~= 0
                stop(this.player_outer);
            end
            disp('Stop the sound');
        end
    end
end