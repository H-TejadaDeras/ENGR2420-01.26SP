%% exp3

clear;

% base_dir = "C:\Users\etuthill\OneDrive - Olin College of Engineering\Circuits\ENGR2410-01.26SP\project\matlab\project_exp3";
base_dir = '/home/htejadaderas/Git/ENGR2420-01.26SP/project/matlab/project_exp3';

folders = dir(base_dir);
folders = folders([folders.isdir]);
folders = folders(~ismember({folders.name}, {'.','..'}));

results = table();
all_data = struct();
valid_i = 0;

for i = 1:length(folders)

    % Get File
    folder_name = folders(i).name;
    file_path = fullfile(base_dir, folder_name, 'NewFile1.csv');

    if ~exist(file_path, 'file')
        continue;
    end

    % Extract Data
    table_opts = detectImportOptions(file_path);
    table_opts.VariableNames = {'X', 'CH1', 'CH2'};
    data = readtable(file_path, table_opts);
    data_parameters = readtable(file_path, Range='D1:E2', ReadVariableNames=true);

    t = data.X .* data_parameters.Increment;

    Vin  = movmean(data.CH1, max(3, round(length(t)/200)));
    Vout = movmean(data.CH2, max(3, round(length(t)/200)));

    dt = mean(diff(t));
    dVout = gradient(Vout, dt);

    % frequency from folder name
    num = regexp(folder_name,'\d+(\.\d+)?','match');
    freq = str2double(num{1});

    if contains(folder_name,'kHz')
        freq = freq * 1e3;
    end
end

function [sharpness, swing] = sharpness_swing_calcs(Vout, dVout)
    % Output Swing and Sharpness Calculation
    swing = max(Vout) - min(Vout);
    sharpness = max(dVout);
end

function slew = slew_calcs(t, Vout, dVout, freq)
    % Slope of 10% to 90% of Output Vout Rise
    vout_min = min(Vout);
    vout_max = max(Vout);

    v10 = vout_min + 0.1*(vout_max - vout_min);
    v90 = vout_min + 0.9*(vout_max - vout_min);

    % Find Corner of Output Square Wave
    [~, rise_corners] = findpeaks(dVout, 'MinPeakHeight', max(dVout)*0.5, 'MinPeakDistance', 10);
    [~, fall_corners] = findpeaks(-dVout, 'MinPeakHeight', max(-dVout)*0.5, 'MinPeakDistance', 10);

    rise_corners = rise_corners - 1;
    fall_corners = fall_corners - 1;


end

function delay_calcs()
    % Delay between Vin and Vout when hitting threshold voltage
end

function [start_rise, end_rise, start_fall, end_fall] = calc_risetime(file_path, freq)
    if freq < 40000 % current logic breaks above 40kHz
        table_opts = detectImportOptions(file_path);
        table_opts.VariableNames = {'X', 'CH1', 'CH2'};
        data = readtable(file_path, table_opts);
        data_parameters = readtable(file_path, Range='D1:E2', ReadVariableNames=true);
        
        t = data.X .* data_parameters.Increment - data_parameters.Start;
        
        Vin  = movmean(data.CH1, max(3, round(length(t)/200)));
        Vout = movmean(data.CH2, max(3, round(length(t)/200)));
        
        dt = mean(diff(t));
        dVout = gradient(Vout, dt);
        ddVout = gradient(dVout, dt);
        
        vout_min = min(Vout);
        vout_max = max(Vout);
        
        v10 = vout_min + 0.1*(vout_max - vout_min);
        v90 = vout_min + 0.9*(vout_max - vout_min);
        
        % TMP
        figure()
        plot(t, Vin)
        hold on;
        plot(t, Vout)
        
        ddVout = gradient(dVout, dt);
        
        figure()
        hold on
        plot(t, Vout * 10^5)
        plot(t, ddVout/10^8)
        legend('vout', '2 diff')
        
        % Take absolute value of second derivative so both rising/falling edges
        % become positive peaks
        ddVout_clean = smoothdata(abs(ddVout), 'gaussian', 5);
        
        % Find peaks in second derivative
        if freq < 45000
            [~, peak_idx] = findpeaks(ddVout_clean, 'MinPeakProminence', 0.15 * max(ddVout_clean));
        else
            thr = prctile(ddVout_clean, 90);
            [~, peak_idx] = findpeaks(ddVout_clean, 'MinPeakHeight', thr);
        end
        
        % state flags
        flag_rise = false;
        flag_fall = false;
        
        % arrays for rise and fall intervals
        start_rise = [];
        end_rise   = [];
        
        start_fall = [];
        end_fall   = [];
        
        % Midpoint voltage (used to decide if in upper or lower half)
        v_mid = (vout_max + vout_min) / 2;
        
        for i = 1:length(peak_idx)
            idx = peak_idx(i);
        
            % falling
        
            % If slope is negative then signal is going down
            if dVout(idx) < 0
                
                % Start of falling edge:
                % must be in upper half of waveform AND not already in a fall
                if ~flag_fall && Vout(idx) > v_mid
                    start_fall(end+1) = t(idx);
                    flag_fall = true;
        
                % End of falling edge:
                % must have moved into lower half of waveform
                elseif flag_fall && Vout(idx) < v_mid
                    end_fall(end+1) = t(idx);
                    flag_fall = false;
                end
            end
        
            % rising
        
            % If slope is positive then signal is going up
            if dVout(idx) > 0
                
                % Start of rising edge:
                % must be in lower half AND not already rising
                if ~flag_rise && Vout(idx) < v_mid
                    start_rise(end+1) = t(idx);
                    flag_rise = true;
        
                % End of rising edge:
                % must reach upper half
                elseif flag_rise && Vout(idx) > v_mid
                    end_rise(end+1) = t(idx);
                    flag_rise = false;
                end
            end
        end
        
        figure();
        plot(t, Vout);
        hold on;
        
        for i = 1:length(start_rise)
            xline(start_rise(i), 'g--'); % start of rise
            xline(end_rise(i), 'g-'); % end of rise
        end
        
        for i = 1:length(start_fall)
            xline(start_fall(i), 'r--'); % start of fall
            xline(end_fall(i), 'r-'); % end of fall
        end

end