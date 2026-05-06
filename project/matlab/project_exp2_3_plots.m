%% exp 2

clear;

base_dir = "C:\Users\etuthill\OneDrive - Olin College of Engineering\Circuits\ENGR2410-01.26SP\project\matlab\project_exp2";

folder_name = "sine_50kHz";
file_path = fullfile(base_dir, folder_name, 'NewFile1.csv');

table_opts = detectImportOptions(file_path);
table_opts.VariableNames = {'X','CH1','CH2'};
data = readtable(file_path, table_opts);
data_parameters = readtable(file_path, Range='D1:E2', ReadVariableNames=true);

t = data.X .* data_parameters.Increment;

Vin  = smoothdata(data.CH1,'movmean',15);
Vout = smoothdata(data.CH2,'movmean',15);

dt = mean(diff(t));
dVout = gradient(Vout)/dt;

freq = 50000;

UT = 0.843;
LT = 0.421;
v_thresh = (UT + LT)/2;

[slew, swing] = slew_swing_calcs(Vout, dVout);
rise_fall = rise_fall_calc(t, Vout, dVout, freq);

avg_rise = rise_fall.avg_rise;
avg_fall = rise_fall.avg_fall;

t_in = t(Vin(1:end-1) < v_thresh & Vin(2:end) >= v_thresh);
t_out = t(Vout(1:end-1) < v_thresh & Vout(2:end) >= v_thresh);

[~, r] = max(dVout);
[~, f] = min(dVout);

win = 20;

i1r = max(1, r-win); i2r = min(length(t), r+win);
i1f = max(1, f-win); i2f = min(length(t), f+win);

p_rise = polyfit(t(i1r:i2r), Vout(i1r:i2r), 1);
p_fall = polyfit(t(i1f:i2f), Vout(i1f:i2f), 1);

slew_rise = p_rise(1);
slew_fall = p_fall(1);

figure
plot(t, Vin, '.'); hold on
plot(t, Vout, '.')
xlabel('Time (s)')
ylabel('Voltage (V)')
title('50 kHz Time Response')
legend('Vin','Vout','Location','bestoutside')

dVout_mag = movmean(abs(dVout), 25);

dt = mean(diff(t));
min_dist_time = 1e-6; 
min_dist_samples = round(min_dist_time / dt);

[pks, locs] = findpeaks(dVout_mag,'MinPeakHeight', 0.5*max(dVout_mag), 'MinPeakDistance', min_dist_samples);

figure

subplot(2,1,1)
plot(t, Vout, '.'); hold on
plot(t(i1r:i2r), polyval(p_rise,t(i1r:i2r)), '-')
plot(t(i1f:i2f), polyval(p_fall,t(i1f:i2f)), '-')

xlabel('Time (s)')
ylabel('Voltage (V)')
title('Sharpness Extraction')

legend('Vout', sprintf('Rise Fit (%.2e V/s)', slew_rise), sprintf('Fall Fit (%.2e V/s)', slew_fall), 'Location','bestoutside')

subplot(2,1,2)
plot(t, dVout_mag, '.'); hold on
plot(t(locs), pks, 'o', 'MarkerSize', 7, 'LineWidth', 2)

xlabel('Time (s)')
ylabel('|dVout/dt| (V/s)')
title('Derivative Peak Detection')

legend('|dVout/dt|', sprintf('Detected Peaks (N = %d)', numel(pks)), 'Location','bestoutside')

avg_delay = delay_calcs(t, Vin, Vout);

figure

h1 = plot(t, Vin, '.'); hold on
h2 = plot(t, Vout, '.');
h3 = yline(v_thresh);

h4 = plot(t_in, v_thresh*ones(size(t_in)), 'o', 'MarkerSize', 7, 'LineWidth', 2);
h5 = plot(t_out, v_thresh*ones(size(t_out)), 'x', 'MarkerSize', 7, 'LineWidth', 2);

h6 = plot(nan, nan, 'w-', 'LineWidth', 2);

xlabel('Time (s)')
ylabel('Voltage (V)')
title('Propagation Delay Extraction')

legend([h1 h2 h3 h4 h5 h6], ...
{'Vin','Vout','Threshold','Vin Crossings','Vout Crossings', ...
sprintf('Avg Delay = %.2e s', avg_delay)}, ...
'Location','bestoutside')

vout_min = min(Vout);
vout_max = max(Vout);

v10 = vout_min + 0.1*(vout_max - vout_min);
v90 = vout_min + 0.9*(vout_max - vout_min);

figure

plot(t, Vout, '.'); hold on
yline(v10, '--')
yline(v90, '--')

xlabel('Time (s)')
ylabel('Voltage (V)')
title('Rise and Fall Time Extraction')

legend('Vout', '10% Level', '90% Level', sprintf('Rise Time = %.2e s', avg_rise), sprintf('Fall Time = %.2e s', avg_fall), 'Location','bestoutside')

%% exp3

clear;

% base_dir = "C:\Users\etuthill\OneDrive - Olin College of Engineering\Circuits\ENGR2410-01.26SP\project\matlab\project_exp3";
base_dir = '/home/htejadaderas/Git/ENGR2420-01.26SP/project/matlab/project_exp3';

% list of all folders in dataset directory
folders = dir(base_dir);
folders = folders([folders.isdir]);
folders = folders(~ismember({folders.name},{'.','..'}));

results = table();
valid_i = 0;

% loop through each frequency folder and extract
for i = 1:length(folders)

    folder_name = folders(i).name;
    file_path = fullfile(base_dir, folder_name, 'NewFile1.csv');

    % read data
    table_opts = detectImportOptions(file_path);
    table_opts.VariableNames = {'X', 'CH1', 'CH2'};
    data = readtable(file_path, table_opts);

    % read scaling parameters 
    data_parameters = readtable(file_path, Range='D1:E2', ReadVariableNames=true);

    % convert sample index to real time
    t = data.X .* data_parameters.Increment;

    % smooth
    Vin  = movmean(data.CH1, max(3, round(length(t)/200)));
    Vout = movmean(data.CH2, max(3, round(length(t)/200)));

    % derivative of output for slew estimation
    dt = mean(diff(t));
    dVout = gradient(Vout, dt);

    % extract  frequency from folder name string
    num = regexp(folder_name,'\d+(\.\d+)?','match');
    freq = str2double(num{1});
    if contains(folder_name,'kHz')
        freq = freq * 1e3;
    end

    % compute slew rate and output swing
    [slew, swing] = slew_swing_calcs(Vout, dVout);

    % compute propagation delay between vin and vout crossings
    avg_delay = delay_calcs(t, Vin, Vout);

    % compute rise and fall times using 10–90 percent method
    rise_fall = rise_fall_calc(t, Vout, dVout, freq);

    valid_i = valid_i + 1;

    % store extracted in results table
    results.freq(valid_i,1) = freq;
    results.slew(valid_i,1) = slew;
    results.swing(valid_i,1) = swing;
    results.delay(valid_i,1) = avg_delay;
    results.rise_time(valid_i,1) = rise_fall.avg_rise;
    results.fall_time(valid_i,1) = rise_fall.avg_fall;

end

% sort results so plots follow increasing frequency order
results = sortrows(results,'freq');

% smooth 
w = 15;
freq_s  = results.freq;
slew_s  = movmean(results.slew, w);
swing_s = movmean(results.swing, w);
delay_s = movmean(results.delay, w);
rise_s  = movmean(results.rise_time, w);
fall_s  = movmean(results.fall_time, w);
% plot slew rate vs frequency
figure;
semilogx(freq_s, slew_s, 'o-');
xlabel('Frequency (Hz)');
ylabel('Sharpness (V/s)');
title('Frequency vs Sharpness');

% plot output swing vs frequency
figure;
semilogx(freq_s, swing_s, 'o-');
xlabel('Frequency (Hz)');
ylabel('Output Swing (V)');
title('Frequency vs Output Swing');

% plot propagation delay vs frequency
figure;
semilogx(freq_s, delay_s, 'o-');
xlabel('Frequency (Hz)');
ylabel('Propagation Delay (s)');
title('Frequency vs Delay');

% plot rise and fall time vs frequency
figure;
semilogx(freq_s, rise_s, 'o-'); hold on;
semilogx(freq_s, fall_s, 's-');
xlabel('Frequency (Hz)');
ylabel('Time (s)');
title('Frequency vs Rise / Fall Time');
legend('Rise Time','Fall Time');

% slew and swing calculation
function [slew, swing] = slew_swing_calcs(Vout, dVout)
% computes output swing and maximum slew rate from waveform
swing = max(Vout) - min(Vout);
slew = max(dVout);
end


% propagation delay calculation
function avg_delay = delay_calcs(t, Vin, Vout)
% finds delay between vin and vout threshold crossings using midpoint threshold

UT = 0.843;
LT = 0.421;

% use midpoint of hysteresis as reference
v_thresh = (UT + LT) / 2;

% detect rising threshold crossings for input and output
t_in_rise  = t(Vin(1:end-1) < v_thresh & Vin(2:end) >= v_thresh);
t_out_rise = t(Vout(1:end-1) < v_thresh & Vout(2:end) >= v_thresh);

% match crossings and find average delay
num_matches = min(length(t_in_rise), length(t_out_rise));

if num_matches > 0
    avg_delay = mean(t_out_rise(1:num_matches) - t_in_rise(1:num_matches));
else
    avg_delay = NaN;
end
end

% I checked this one pretty extensively through plotting in tmp.m and it
% works consistently
% rise and fall time calculation
function rise_fall = rise_fall_calc(t, Vout, dVout, freq)
    
    % this function estimates rise and fall times of the output waveform
    % using a 10%–90% threshold method and a simple state machine (PIE
    % flashbacks) it tracks when the signal enters and exits transition regions
    
    % get signal bounds
    vout_min = min(Vout);
    vout_max = max(Vout);
    
    % define 10% and 90% voltage levels for timing transitions
    v10 = vout_min + 0.1*(vout_max - vout_min);
    v90 = vout_min + 0.9*(vout_max - vout_min);
    
    % arrays to store timestamps of transitions
    start_rise = [];
    end_rise = [];
    start_fall = [];
    end_fall = [];
    
    % numeric states (I hate matlab)
    HIGH = 1;
    FALLING = 2;
    LOW = 3;
    RISING = 4;
    
    % midpoint to decide initial state of waveform
    v_mid = (vout_max + vout_min) / 2;
    
    % initialize state based on starting output level (crazy simple in
    % comparison to what we were doing before)
    if Vout(1) < v_mid
        flag_state = LOW;
    else
        flag_state = HIGH;
    end
    
    % loop through waveform and detect threshold crossings
    % this acts like a finite state machine tracking edges
    for i = 2:length(t)
    
        % detect start of falling edge (crossing below 90%)
        if flag_state == HIGH && Vout(i) < v90 && Vout(i-1) >= v90
            start_fall(end+1) = t(i);
            flag_state = FALLING;
    
        % detect end of falling edge (crossing below 10%)
        elseif flag_state == FALLING && Vout(i) < v10 && Vout(i-1) <= v10
            end_fall(end+1) = t(i);
            flag_state = LOW;
    
        % detect start of rising edge (crossing above 10%)
        elseif flag_state == LOW && Vout(i) > v10 && Vout(i-1) <= v10
            start_rise(end+1) = t(i);
            flag_state = RISING;
    
        % detect end of rising edge (crossing above 90%)
        elseif flag_state == RISING && Vout(i) > v90 && Vout(i-1) >= v90
            end_rise(end+1) = t(i);
            flag_state = HIGH;
        end
    
    end
    
    % match rise start/end pairs and compute average rise time
    num_rises = min(length(start_rise), length(end_rise));
    rise_fall.avg_rise = mean(end_rise(1:num_rises) - start_rise(1:num_rises));
    
    % match fall start/end pairs and compute average fall time
    num_falls = min(length(start_fall), length(end_fall));
    rise_fall.avg_fall = mean(end_fall(1:num_falls) - start_fall(1:num_falls));
    
    % return raw transition timestamps for plotting
    rise_fall.start_rise = start_rise;
    rise_fall.end_rise = end_rise;
    rise_fall.start_fall = start_fall;
    rise_fall.end_fall = end_fall;
end

% Waveform Plots
load("project_exp2_data_waveforms.mat")

t = data_100Hz.X .* data_parameters_100Hz.Increment;
Vin = movmean(data_100Hz.CH1, max(3, round(length(t)/200)));
Vout = movmean(data_100Hz.CH2, max(3, round(length(t)/200)));

figure()
hold on;
plot(t, Vin, '.', DisplayName='V_{in}')
plot(t, Vout, '.', DisplayName='V_{out}')
xlabel('Time (s)')
ylabel('Voltage (V)')
title('100 Hz Waveform')
legend()

t = data_50kHz.Var1 .* data_parameters_50kHz.Increment;
Vin = movmean(data_50kHz.Var2, max(3, round(length(t)/200)));
Vout = movmean(data_50kHz.Var3, max(3, round(length(t)/200)));

figure()
hold on;
plot(t, Vin, '.', DisplayName='V_{in}')
plot(t, Vout, '.', DisplayName='V_{out}')
xlabel('Time (s)')
ylabel('Voltage (V)')
title('50 kHz Waveform')
legend()

t = data_100kHz.Var1 .* data_parameters_100kHz.Increment;
Vin = movmean(data_100kHz.Var2, max(3, round(length(t)/200)));
Vout = movmean(data_100kHz.Var3, max(3, round(length(t)/200)));

figure()
hold on;
plot(t, Vin, '.', DisplayName='V_{in}')
plot(t, Vout, '.', DisplayName='V_{out}')
xlabel('Time (s)')
ylabel('Voltage (V)')
title('100 kHz Waveform')
legend()

% Hysteresis Curve

figure()
hold on;

Vin = movmean(data_100Hz.CH1, max(3, round(length(t)/200)));
Vout = movmean(data_100Hz.CH2, max(3, round(length(t)/200)));

plot(Vin, Vout, '.', DisplayName='100 Hz')

Vin = movmean(data_50kHz.Var2, max(3, round(length(t)/200)));
Vout = movmean(data_50kHz.Var3, max(3, round(length(t)/200)));

plot(Vin, Vout, '.', DisplayName='50 kHz')

Vin = movmean(data_100kHz.Var2, max(3, round(length(t)/200)));
Vout = movmean(data_100kHz.Var3, max(3, round(length(t)/200)));

plot(Vin, Vout, '.', DisplayName='100 kHz')

xlabel('Input Voltage (V)')
ylabel('Output Voltage (V)')
title('Hysteresis Loops at Selected Frequencies')
legend()