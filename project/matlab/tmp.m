clear;
close all;

folder_name = '5 kHz';

file_path = '/home/htejadaderas/Git/ENGR2420-01.26SP/project/matlab/project_exp3/2 kHz/NewFile1.csv';
table_opts = detectImportOptions(file_path);
table_opts.VariableNames = {'X', 'CH1', 'CH2'};
data = readtable(file_path, table_opts);
data_parameters = readtable(file_path, Range='D1:E2', ReadVariableNames=true);

t = data.X .* data_parameters.Increment - data_parameters.Start;

Vin  = movmean(data.CH1, max(3, round(length(t)/200)));
Vout = movmean(data.CH2, max(3, round(length(t)/200)));

dt = mean(diff(t));
dVout = gradient(Vout, dt);
ddt = mean(diff(dt));
ddVout = gradient(dVout, ddt);

% frequency from folder name
num = regexp(folder_name,'\d+(\.\d+)?','match');
freq = str2double(num{1});

if contains(folder_name,'kHz')
    freq = freq * 1e3;
end

    % Slope of 10% to 90% of Output Vout Rise
    vout_min = min(Vout);
    vout_max = max(Vout);

    v10 = vout_min + 0.1*(vout_max - vout_min);
    v90 = vout_min + 0.9*(vout_max - vout_min);


% TMP
    figure()
    plot(t, Vin)
    hold on;
    plot(t, Vout)

    ddt = mean(diff(dt));
    dddt = mean(diff(dt))
    ddVout = gradient(dVout, dt);
    dddVout = gradient(ddVout, dt);

    figure()
    hold on
    plot(t, Vout * 10^5)
    % plot(t, dVout)
    plot(t, ddVout/10^8)
        % plot(t, abs(ddVout/10^6))
    % plot(t, dddVout/10^12)
    legend('diff', 'vout', '2nd diff', '3rd diff')

    % Find Corner of Output Square Wave
    figure();
    [~, peak_idx] = findpeaks(abs(ddVout), MinPeakHeight=0.59 * max(ddVout))
    % If negative first, then fall; if positive first then rise
    
    % Start at falling edge and omit last edge if it does not have
    % corresponding edge
    for i = 1:length(peak_idx)
        specific_peak = ddVout(i);

        % Getting Time Values (fall)
        if specific_peak < 0 && flag_true == false
            start_fall = t(i);
            flag_fall = true;
        else
            end_fall = t(i);
        end

        % Getting Time Values (rise)
        if specific_peak > 0 && flag_false == false
            start_rise = t(i);
            flag_rise = true;
        else
            end_rise = t(i);

        
    end