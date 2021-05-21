clc
clear all
close all
% Please import data as table with the title "data"
folder = 'rec/**/';
% folder = 'test_dir/';
files = dir(strcat(folder, 'data*05-18*.xls'));

data = merge_all_files(files);

cnt = 0;
global C
C = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250] ...
    [0.4940 0.1840 0.5560], [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330]...
    [0.6350 0.0780 0.1840], [1 1 0], [1 0 1], [0 1 1], [0 0 1], [1 0 0], [0 1 0]};

details.cover = "off";
details.length_outer = 41;
details.primary = "outer";

show_data(data, details)
details.primary = "inner";
show_data(data, details)
disp("END");


function [out] = checkzeros(rows)
    out = 1;
    if nnz(rows.freq_outer) ~= length(rows.freq_outer)
        return
    end 
    if nnz(rows.freq_inner) ~= length(rows.freq_inner)
        return
    end
    out = 0;
    return
end

function [out] = merge_all_files(files)
    out = [];
    new_id = 0;
    for idx = 1:length(files)
        data = readtable(strcat(files(idx).folder, '\', files(idx).name));
        % Clean all recordings of 0Hz
%         data = data(data.freq ~= 0, :);  
    %     data.file = repmat(files(idx).name, height(data), 1);

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

function [] = show_data(data, details)
    cnt = 0;
    figure
    freqs = unique(data.freq);
    if details.primary == "outer"
        primary = "freq_outer";
        secondary = "freq_inner";
    else
        primary = "freq_inner";
        secondary = "freq_outer";        
    end
        
    % Split into runs
    for fqidx = 1:length(freqs)
        plot_aux = [];
        selected = data(data.(primary) == freqs(fqidx) & ...
                        data.cover == details.cover & ...
                        data.length_outer == details.length_outer, :);
        runs = unique(selected.run_id);
        for run_no = 1:length(runs)
            % Select all data from the single run
            run = selected(selected.run_id == runs(run_no), :);
            selected_rows = run(run.freq == run.(secondary), :);
            selected_rows = unique(selected_rows, 'rows');
            selected_freq = unique(selected_rows.freq);
            if size(selected_freq) ~= 1
                error("SRANJE");
            end
            if height(selected_rows) == 0
                continue
            end
            % Select median values
            data_inner = selected_rows(selected_rows.channel_name == "inner", :).median;
            data_outer = selected_rows(selected_rows.channel_name == "outer", :).median;
            plot_data = data_inner - data_outer;

            hold on
            global C
            color = C{mod(cnt, length(C)) + 1};
            plot_aux = [plot_aux; selected_freq, plot_data];
        end
        if freqs(fqidx) == 0
            base_values = plot_aux;
            base_values = [base_values; 0,0];
    %     else
    %         temp = unique(plot_aux(:,1));
    %         for idx = 1:length(temp)
    %             plot_aux(find(plot_aux(:,1) == temp(idx), 2), 2) = plot_aux(find(plot_aux(:,1) == temp(idx), 2), 2) - base_values(find(base_values(:,1) == temp(idx), 2), 2);
    %         end
        end
        if size(plot_aux) ~= 0
            s = scatter(plot_aux(:,1), plot_aux(:,2), 'filled', 'MarkerFaceColor', color, 'DisplayName',string(freqs(fqidx)));
        end
        cnt = 1 + cnt;
    end
    xlabel(details.primary + ' mic frequency')
    ylabel('Difference of amplitudes inner and outer mic')
    hold off
end