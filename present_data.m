clc
clear all
close all
% Please import data as table with the title "data"
% Clean all recordings of 0Hz
data = readtable('data.xls');
data = data(find(data.freq ~= 0), :);

cnt = 0;
C = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560], [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330],[0.6350 0.0780 0.1840]};

% Split into runs
for run_no = 2:25
    run = data(find(data.run_id == run_no), :);
    monitoring_freqs = table2array(unique(run(:, 1)));
    for idx_freq = 1:length(monitoring_freqs)
        selected_rows = run(find(run.freq == monitoring_freqs(idx_freq)), :);
        selected_rows = unique(selected_rows,'rows');
        data_inner = table2array(selected_rows(find(selected_rows.channel_name == "inner"), 3:12));
        data_inner_1 = table2array(selected_rows(find(selected_rows.channel_name == "inner"), 17));
        data_outer = table2array(selected_rows(find(selected_rows.channel_name == "outer"), 3:12));
        data_outer_1 = table2array(selected_rows(find(selected_rows.channel_name == "outer"), 17));
%         if ~checkzeros(selected_rows)
%             continue
%         end
        if selected_rows.freq_outer == selected_rows.freq
            plot_data = data_outer - data_inner;
            plot_data_1 = data_outer_1 - data_inner_1;
        else % if selected_rows.freq_inner == selected_rows.freq 
         	plot_data = data_inner - data_outer;
            plot_data_1 = data_inner_1 - data_outer_1;
        end    
        
        hold on
        color = C{mod(cnt, length(C)) + 1};
        cnt = 1 + cnt;
        scatter(ones(1,length(plot_data))*monitoring_freqs(idx_freq), plot_data, 'MarkerEdgeColor', color);
        scatter(monitoring_freqs(idx_freq), plot_data_1,'filled', 'MarkerFaceColor', color);
    end
end
hold off
disp("END");


% hold on
% for i = 1:width(y)
%     scatter(x, y(:,i))
% end
% hold off
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


