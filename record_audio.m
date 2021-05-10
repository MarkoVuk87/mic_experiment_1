function [list_of_filenames] = record_audio(num_attempts, seconds)
    index = num_attempts;
    while index > 0
        fprintf("Attempt %i of %i: ", num_attempts+1-index, num_attempts);
        audio_file = record_audio_single(seconds);
        if audio_file ~= "error"
            list_of_filenames(:,index)=audio_file;
            index = index-1;
        end
    end
end

function [audio_filename] = record_audio_single(seconds)
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