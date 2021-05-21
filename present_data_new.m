clc
clear all
close all
% folder = 'rec/**/';
folder = 'test_dir/';
files = dir(strcat(folder, 'data_*.xls'));

% [file, path] = uigetfile('*.xls',...
%                          'Select One or More Files', ...
%                          'MultiSelect', 'on');
% files = dir(strcat(path, file));

data = merge_all_files(files);

cnt = 0;
global C
C = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250] ...
    [0.4940 0.1840 0.5560], [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330]...
    [0.6350 0.0780 0.1840], [1 1 0], [1 0 1], [0 1 1], [0 0 1], [1 0 0], [0 1 0]};

fixed.cover = "on";
% fixed.length_outer = 40;
fixed.freq_signal = 0;
fixed = struct2table(fixed);
variable.x = "freq_noise";
variable.y(1) = "length_outer";

show_data(data, variable, fixed)
% variable.primary = "signal";
% show_data(data, variable, fixed)
disp("END");

function [] = show_data(data, variable, fixed)
    cnt = 0;
    x_label = 'f_n';%variable.x;
    for yy = 1:length(variable.y)
        figure
        y_name = variable.y(yy);
        y_chosen = unique(data.(y_name));
        for i = 1:length(y_chosen)
            plot_aux = [];
            % filter data according to fixed criteria
            y_data = data(data.(y_name) == y_chosen(i), :);
            y_data = filter_data(y_data, fixed);
            % find all unique variable.x elements of data
            x_all = unique(data.(variable.x));
            for x_id = 1:length(x_all)
                x_current = x_all(x_id);
                % find all data for one point in x-axis
                y_data_current = y_data(y_data.(variable.x) == x_current, :);
                
                runs = unique(y_data_current.run_id);
                for run_no = 1:length(runs)
                    % Select all data from the single run
                    run = y_data_current(y_data_current.run_id == runs(run_no), :);
                    selected_rows = run(run.freq == run.(variable.x), :);
                    selected_rows = unique(selected_rows, 'rows');
                    selected_freq = unique(selected_rows.freq);
                    if size(selected_freq) ~= 1
                        error("SRANJE");
                    end
                    if height(selected_rows) == 0
                        continue
                    end 
                    % Select median values
                    data_signal = selected_rows(selected_rows.channel_name == "signal", :).median;
                    data_noise = selected_rows(selected_rows.channel_name == "noise", :).median;
                    plot_data = data_signal - data_noise;
%                     plot_data = data_signal;
                    
                    plot_aux = [plot_aux; selected_freq, plot_data];  
                end
            end
            hold on
            global C
            color = C{mod(cnt, length(C)) + 1};

            if size(plot_aux) ~= 0
                s = scatter(plot_aux(:,1), plot_aux(:,2), 'filled', 'MarkerFaceColor', color, 'DisplayName', string(y_chosen(i)));
            end
            cnt = 1 + cnt;
        end
        hline = refline(0, 0);
        hline.Color = 'k';
        xlabel(x_label)
        ylabel('Difference of amplitudes signal and noise mic')
        hold off        
    end
end

function [selected] = filter_data(data, fixed_criteria_list)
    selected = data;
    for j = 1:length(fixed_criteria_list.Properties.VariableNames)
        name = string(fixed_criteria_list.Properties.VariableNames(j));
        selection = selected.(name) == fixed_criteria_list.(name);
        selected = selected(selection, :);
    end
end

function [out] = merge_all_files(files)
    out = [];
    new_id = 0;
    for idx = 1:length(files)
        data = readtable(strcat(files(idx).folder, '\', files(idx).name));
        data.file(:) = string(files(idx).name);
        
        % Clean all recordings of 0Hz
%         data = data(data.freq ~= 0, :);  
    %     data.file = repmat(files(idx).name, height(data), 1);
        data.Properties.VariableNames = regexprep(data.Properties.VariableNames,'freq_outer','freq_noise');
        data.Properties.VariableNames = regexprep(data.Properties.VariableNames,'freq_inner','freq_signal');

        headers = data.Properties.VariableNames;
        temp = [];
        for i = 1:length(headers)
            if startsWith(headers(i), 'data_')
                temp = [temp, data.(string(headers(i)))];
                data.(string(headers(i))) = [];
            end
%             if headers(i) == "median"
%                 data.median = mag2db(data.median);
%             end
        end
%         data.data = temp;

        runs = unique(data.run_id);
        for run_no = 1:length(runs)
            temp = data(data.run_id == runs(run_no), :);
            temp.run_id(:) = new_id;
            if size(out) == 1
                out = temp;
            else
                out = [out; temp];
            end
            new_id = new_id + 1;
        end
    end
end
