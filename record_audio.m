function [audio_filename] = record_audio(seconds)
    close all
    clear classes

    % Reloading the python module
    audio_capture = py.importlib.import_module('audio_capture');
    py.importlib.reload(audio_capture);
    fprintf("python script version -> %s\n", string(py.audio_capture.version()));

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