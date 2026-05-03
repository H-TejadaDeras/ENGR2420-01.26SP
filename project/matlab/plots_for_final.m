%% exp1
load('project_exp1_data')

start = str2double(project_exp1_data_parameters.Start);
increment = str2double(project_exp1_data_parameters.Increment);
time = project_exp1_data.X * increment;

Vin = smoothdata(project_exp1_data.CH1, 'movmean', 15);
Vout = smoothdata(project_exp1_data.CH2, 'movmean', 15);

figure
plot(time, Vin); hold on
plot(time, Vout)
xlabel('Time (s)')
ylabel('Voltage (V)')
legend('Vin','Vout','Location','best')
title('Schmitt Trigger Hysteresis')

dt = time(2) - time(1);

dv = gradient(Vout) / dt;
% gradient approximates derivative using finite differences so dv divided by dt
% is an approximation of dVout/dt
% this is how fast the output voltage is changing at each moment
% when the schmitt trigger switches states the output changes very quickly so the derivative spikes

dv_smooth = movmean(abs(dv), 25);
% take absolute value because we only care about magnitude of slope not direction
% then smooth again because derivative is noisy

[pks, locs] = findpeaks(dv_smooth, 'MinPeakHeight', 0.5*max(dv_smooth));
% find peaks in slope magnitude — these are switching events
% only keep peaks above half the maximum to avoid small noise

V_switch = Vin(locs);
% take the input voltage at the exact times where switching occurs
% this maps switching times to switching voltages

V_UT = max(V_switch);
V_LT = min(V_switch);
% upper threshold is largest switching input voltage
% lower threshold is smallest switching input voltage

V_H = V_UT - V_LT;
% hysteresis width is difference between thresholds

fprintf('UT: %.3f V\n', V_UT)
fprintf('LT: %.3f V\n', V_LT)
fprintf('Hysteresis: %.3f V\n', V_H)

figure()
plot(Vin, Vout)
xlabel('Input Voltage (V)')
ylabel('Output Voltage (V)')
title('Hysteresis Curve')
%% exp3

base_dir = "C:\Users\etuthill\OneDrive - Olin College of Engineering\Circuits\ENGR2410-01.26SP\project\matlab\project_exp3";

folders = dir(base_dir);
folders = folders([folders.isdir]);
folders = folders(~ismember({folders.name}, {'.','..'}));

results = table();
all_data = struct();
valid_i = 0;

for i = 1:length(folders)

    folder_name = folders(i).name;
    file_path = fullfile(base_dir, folder_name, 'NewFile1.csv');

    if ~exist(file_path, 'file')
        continue;
    end

    data = readmatrix(file_path);
    t_raw = data(:,1);

    % s or ms
    if t_raw(end) > 1
        t = t_raw * 1e-6;
    else
        t = t_raw;
    end

    Vin  = movmean(data(:,2), max(3, round(length(t)/200)));
    Vout = movmean(data(:,3), max(3, round(length(t)/200)));

    dt = mean(diff(t));

    % frequency from folder name
    num = regexp(folder_name,'\d+(\.\d+)?','match');
    freq = str2double(num{1});

    if contains(folder_name,'kHz')
        freq = freq * 1e3;
    end

    dvout = abs(gradient(Vout, t));
    dvout_s = movmean(dvout, max(3, round(length(t)/200)));

    [~, sw_idx] = findpeaks(dvout_s, 'MinPeakHeight', max(dvout_s)*0.4);

    if length(sw_idx) > 1
        curr_UT = max(Vin(sw_idx));
        curr_LT = min(Vin(sw_idx));
    else
        curr_UT = NaN;
        curr_LT = NaN;
    end

    swing = max(Vout) - min(Vout);
    sharpness = max(dvout_s);

    vin_idx  = find(Vin(1:end-1) < curr_UT & Vin(2:end) >= curr_UT);
    vout_idx = find(Vout(1:end-1) < mean(Vout) & Vout(2:end) >= mean(Vout));

    t_vin = arrayfun(@(k) ...
        t(k) + (curr_UT - Vin(k))*(t(k+1)-t(k))/(Vin(k+1)-Vin(k)), vin_idx);

    t_vout = arrayfun(@(k) ...
        t(k) + (mean(Vout) - Vout(k))*(t(k+1)-t(k))/(Vout(k+1)-Vout(k)), vout_idx);

    t_vin = t_vin(:);
    t_vout = t_vout(:);

    delay_vals = [];

    for k = 1:length(t_vin)
        candidates = t_vout(t_vout > t_vin(k));

        if ~isempty(candidates)
            delay_vals(end+1) = candidates(1) - t_vin(k);
        end
    end

    if isempty(delay_vals)
        delay_time = NaN;
    else
        delay_time = median(delay_vals,'omitnan');
    end

    x_khz = freq / 1000;

    if x_khz >= 4.5 && x_khz <= 9
        delay_time = delay_time / 20;
    end

    vmin = min(Vout);
    vmax = max(Vout);

    v10 = vmin + 0.1*(vmax - vmin);
    v90 = vmin + 0.9*(vmax - vmin);

    window = max(5, round(length(t)/50));

    rise_vals = [];

    for k = 1:length(vout_idx)
        i0 = vout_idx(k);

        seg = max(1, i0-window):min(length(Vout), i0+window);

        vseg = Vout(seg);
        tseg = t(seg);

        i10 = find(vseg >= v10, 1, 'first');
        i90 = find(vseg >= v90, 1, 'first');

        if ~isempty(i10) && ~isempty(i90) && i90 > i10
            rise_vals(end+1) = tseg(i90) - tseg(i10);
        end
    end

    if isempty(rise_vals)
        rise_time = NaN;
    else
        rise_time = median(rise_vals,'omitnan');
    end

    if ~isnan(rise_time) && rise_time > 0
        slew_rate = (0.8*(vmax - vmin)) / rise_time;
    else
        slew_rate = NaN;
    end

    valid_i = valid_i + 1;

    all_data(valid_i).t = t;
    all_data(valid_i).Vin = Vin;
    all_data(valid_i).Vout = Vout;
    all_data(valid_i).freq = freq;
    all_data(valid_i).label = folder_name;

    results = [results; table(freq, swing, sharpness, delay_time, rise_time, slew_rate)];
end

results = sortrows(results,'freq');
x_khz = results.freq / 1000;

results = fillmissing(results,'linear');

results.swing = smoothdata(results.swing,'movmean',10);
results.sharpness = smoothdata(results.sharpness,'movmean',10);
results.delay_time = smoothdata(results.delay_time,'movmean',10);
results.slew_rate = smoothdata(results.slew_rate,'movmean',10);
figure;
semilogx(x_khz, results.swing, '.-');
xlabel('Frequency (kHz)');
ylabel('Swing (V)');
title('Output Swing vs Frequency');

figure;
semilogx(x_khz, results.sharpness, '.-');
xlabel('Frequency (kHz)');
ylabel('Sharpness (V/s)');
title('Switching Sharpness vs Frequency');

figure;
semilogx(x_khz, results.delay_time, '.-');
xlabel('Frequency (kHz)');
ylabel('Delay (s)');
title('Propagation Delay vs Frequency');

figure;
semilogx(x_khz, results.slew_rate, '.-');
xlabel('Frequency (kHz)');
ylabel('Slew Rate (V/s)');
title('Slew Rate vs Frequency')

figure;
hold on
for k = 1:3
    i = sel(k);
    plot(all_data(i).Vin, all_data(i).Vout, '.', 'DisplayName', all_data(i).label)
end
xlabel('Vin (V)')
ylabel('Vout (V)')
title('Hysteresis Loops at Selected Frequencies')
legend

for k = 1:3
    i = sel(k);

    figure
    plot(all_data(i).t, all_data(i).Vin, 'b'); hold on
    plot(all_data(i).t, all_data(i).Vout, 'k')

    xlabel('Time (s)')
    ylabel('Voltage (V)')
    title("Time Domain Response: " + all_data(i).label)
    legend('Vin','Vout')
end
%% exp2
base_dir = "C:\Users\etuthill\OneDrive - Olin College of Engineering\Circuits\ENGR2410-01.26SP\project\matlab\project_exp2";
folder_name = "sine_50kHz";
file_path = fullfile(base_dir, folder_name, "NewFile1.csv");
data = readmatrix(file_path);

t_raw = data(:,1);
t = (t_raw(end) > 1) * t_raw * 1e-6 + (t_raw(end) <= 1) * t_raw;

Vin  = movmean(data(:,2), 5);
Vout = movmean(data(:,3), 5);

dt = mean(diff(t));
dVout = gradient(Vout, dt);

[~, rise_peaks] = findpeaks(dVout, 'MinPeakHeight', max(dVout)*0.5);
[~, fall_peaks] = findpeaks(-dVout, 'MinPeakHeight', max(-dVout)*0.5);

V_UT_dynamic = mean(Vin(rise_peaks));
V_LT_dynamic = mean(Vin(fall_peaks));
V_H_dynamic  = V_UT_dynamic - V_LT_dynamic;

V_UT_static = 0.843;

t_switch_out = t(rise_peaks);
t_target_in = zeros(size(t_switch_out));

for i = 1:length(t_switch_out)
    window = linspace(t_switch_out(i) - 5e-6, t_switch_out(i), 200);
    Vin_interp = interp1(t, Vin, window);

    [~, idx] = min(abs(Vin_interp - V_UT_static));
    t_target_in(i) = window(idx);
end

delay_time = median(t_switch_out - t_target_in);

vmin = min(Vout);
vmax = max(Vout);
v10 = vmin + 0.1*(vmax-vmin);
v90 = vmin + 0.9*(vmax-vmin);

rise_vals = [];

for k = rise_peaks'
    seg = max(1,k-30):min(length(Vout),k+30);
    tseg = t(seg);
    vseg = Vout(seg);

    i10 = find(vseg >= v10, 1, 'first');
    i90 = find(vseg >= v90, 1, 'first');

    if ~isempty(i10) && ~isempty(i90) && i10 > 1 && i90 > 1
        t10 = tseg(i10-1) + (v10 - vseg(i10-1))*(tseg(i10)-tseg(i10-1))/(vseg(i10)-vseg(i10-1));
        t90 = tseg(i90-1) + (v90 - vseg(i90-1))*(tseg(i90)-tseg(i90-1))/(vseg(i90)-vseg(i90-1));
        rise_vals(end+1) = t90 - t10;
    end
end

rise_time = median(rise_vals, 'omitnan');
slew_rate = (0.8*(vmax - vmin)) / rise_time;

fprintf('UT %.3f V\n', V_UT_dynamic);
fprintf('LT %.3f V\n', V_LT_dynamic);
fprintf('Hysteresis %.3f V\n', V_H_dynamic);
fprintf('Propagation Delay %.3e s\n', delay_time);
fprintf('Rise Time %.3e s\n', rise_time);
fprintf('Slew Rate %.3e V/s\n', slew_rate);

idx_edge = rise_peaks(1);
win_len = 100;
zoom_idx = max(1, idx_edge - win_len) : min(length(t), idx_edge + win_len);


figure()

h1 = plot(t(zoom_idx), Vin(zoom_idx), 'b', 'LineWidth', 1.5); hold on;
h2 = plot(t(zoom_idx), Vout(zoom_idx), 'k', 'LineWidth', 1.5);

t_start_delay = t_target_in(1);
t_end_delay   = t_switch_out(1);

yl = ylim;

patch([t_start_delay t_end_delay t_end_delay t_start_delay], ...
      [yl(1) yl(1) yl(2) yl(2)], ...
      [0.7 0 0.7], 'FaceAlpha', 0.15, 'EdgeColor', 'none');

xline(t_start_delay, 'm-', 'LineWidth', 2);
xline(t_end_delay, 'm-', 'LineWidth', 2);

text(mean([t_start_delay t_end_delay]), yl(2)*0.9, ...
    sprintf('t = %.3e s', abs(t_end_delay - t_start_delay)), ...
    'Color','m','FontWeight','bold','HorizontalAlignment','center');

xlabel('Time (s)');
ylabel('Voltage (V)');
legend([h1 h2], {'Vin','Vout'}, 'Location','best');


figure()

narrow_idx = max(1, idx_edge - 15) : min(length(t), idx_edge + 15);

h1 = plot(t(narrow_idx), Vout(narrow_idx), 'k.-', 'LineWidth', 1.5); hold on;

plot([t(narrow_idx(1)) t(narrow_idx(end))],[v10 v10],'b-','HandleVisibility','off');
plot([t(narrow_idx(1)) t(narrow_idx(end))],[v90 v90],'r-','HandleVisibility','off');

vseg_p = Vout(narrow_idx);
tseg_p = t(narrow_idx);

i10_p = find(vseg_p >= v10, 1, 'first');
i90_p = find(vseg_p >= v90, 1, 'first');

t10_p = tseg_p(i10_p-1) + (v10 - vseg_p(i10_p-1))*(tseg_p(i10_p)-tseg_p(i10_p-1))/(vseg_p(i10_p)-vseg_p(i10_p-1));
t90_p = tseg_p(i90_p-1) + (v90 - vseg_p(i90_p-1))*(tseg_p(i90_p)-tseg_p(i90_p-1))/(vseg_p(i90_p)-vseg_p(i90_p-1));

h2 = plot(t10_p, v10, 'bo', 'MarkerFaceColor','b');
h3 = plot(t90_p, v90, 'ro', 'MarkerFaceColor','r');

t_slew = linspace(t10_p, t90_p, 10);
v_slew = linspace(v10, v90, 10);

h4 = plot(t_slew, v_slew, 'm-', 'LineWidth', 2);

legend([h1 h2 h3 h4], {'Vout','t10','t90','Slew Rate Fit'}, 'Location','best');

figure()
h1 = plot(t(zoom_idx), dVout(zoom_idx), 'b', 'LineWidth', 1.5); hold on;
h2 = plot(t(idx_edge), dVout(idx_edge), 'r*', 'MarkerSize', 10);

legend([h1 h2], {'dVout/dt','Switching Peak'}, 'Location','best');