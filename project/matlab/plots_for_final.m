load('project_exp1_data')
start = str2double(project_exp1_data_parameters.Start);
increment = str2double(project_exp1_data_parameters.Increment);
time = project_exp1_data.X * increment;

Vin = smoothdata(project_exp1_data.CH1, 'movmean', 15);
Vout = smoothdata(project_exp1_data.CH2, 'movmean',15);

figure
plot(time, Vin); hold on
plot(time, Vout)
xlabel('Time (s)')
ylabel('Voltage (V)')
legend('Vin','Vout','Location','best')
title('Schmitt Trigger Hysteresis')

% estimate switching points from slope peaks
dt = time(2) - time(1);
dv = gradient(Vout) / dt;
dv_smooth = movmean(abs(dv), 25);

[pks, locs] = findpeaks(dv_smooth, 'MinPeakHeight', 0.5*max(dv_smooth));

V_switch = Vin(locs);
V_UT = max(V_switch);
V_LT = min(V_switch);
V_H  = V_UT - V_LT;

fprintf('UT: %.3f V\n', V_UT)
fprintf('LT: %.3f V\n', V_LT)
fprintf('Hysteresis: %.3f V\n', V_H)


base_dir = 'C:\Users\etuthill\OneDrive - Olin College of Engineering\Circuits\ENGR2410-01.26SP\project\matlab\project_exp3';
folders = dir(base_dir);
folders = folders([folders.isdir]);
folders = folders(~ismember({folders.name}, {'.','..'}));

results = table();
all_data = struct();
valid_i = 0;

for i = 1:length(folders)

    folder_name = folders(i).name;
    file_path = fullfile(base_dir, folder_name, 'NewFile1.csv');

    if ~isfile(file_path)
        continue
    end

    data = readmatrix(file_path);
    t_raw = data(:,1);

    % convert time into seconds if needed
    if t_raw(end) > 1
        t = t_raw * 1e-6;
    else
        t = t_raw;
    end

    Vin = movmean(data(:,2), 10);
    Vout = movmean(data(:,3), 10);

    dt = t(2) - t(1);

    % frequency from folder name
    num = regexp(folder_name,'\d+(\.\d+)?','match');
    freq = str2double(num{1});
    if contains(folder_name,'kHz'), freq = freq * 1e3; end

    freq_label = string(folder_name);

    Vin_f = Vin;
    Vout_f = Vout;

    % estimate switching thresholds from diff peaks
    dvout_instant = abs(gradient(Vout_f) ./ dt);
    [~, sw_idx] = findpeaks(dvout_instant, 'MinPeakHeight', max(dvout_instant)*0.4);

    if length(sw_idx) > 1
        curr_UT = max(Vin_f(sw_idx));
        curr_LT = min(Vin_f(sw_idx));
    else
        curr_UT = V_UT;
        curr_LT = V_LT;
    end

    swing = max(Vout) - min(Vout);
    dvout_s = movmean(abs(gradient(Vout_f)/dt), 10);
    sharpness = max(dvout_s);

    % vin threshold crossings
    vin_up_idx = find(Vin_f(1:end-1) < curr_UT & Vin_f(2:end) >= curr_UT);
    vin_dn_idx = find(Vin_f(1:end-1) > curr_LT & Vin_f(2:end) <= curr_LT);

    t_vin_rise = [];
    t_vin_fall = [];

    if ~isempty(vin_up_idx)
        t_vin_rise = arrayfun(@(k) interp1(Vin_f(k:k+1), t(k:k+1), curr_UT), vin_up_idx);
    end

    if ~isempty(vin_dn_idx)
        t_vin_fall = arrayfun(@(k) interp1(Vin_f(k:k+1), t(k:k+1), curr_LT), vin_dn_idx);
    end

    % vout midpoint crossings
    v_mid = (max(Vout_f) + min(Vout_f)) / 2;

    vout_up_idx = find(Vout_f(1:end-1) < v_mid & Vout_f(2:end) >= v_mid);
    vout_dn_idx = find(Vout_f(1:end-1) > v_mid & Vout_f(2:end) <= v_mid);

    t_vout_rise = [];
    t_vout_fall = [];

    if ~isempty(vout_up_idx)
        t_vout_rise = arrayfun(@(k) interp1(Vout_f(k:k+1), t(k:k+1), v_mid), vout_up_idx);
    end

    if ~isempty(vout_dn_idx)
        t_vout_fall = arrayfun(@(k) interp1(Vout_f(k:k+1), t(k:k+1), v_mid), vout_dn_idx);
    end

    % propagation delay calc 
    delay_vals = [];

    for k = 1:length(t_vin_rise)
        candidates = t_vout_rise(t_vout_rise > t_vin_rise(k));
        if ~isempty(candidates)
            d = candidates(1) - t_vin_rise(k);
            if d > 0 && d < 5e-6
                delay_vals(end+1) = d;
            end
        end
    end

    for k = 1:length(t_vin_fall)
        candidates = t_vout_fall(t_vout_fall > t_vin_fall(k));
        if ~isempty(candidates)
            d = candidates(1) - t_vin_fall(k);
            if d > 0 && d < 5e-6
                delay_vals(end+1) = d;
            end
        end
    end

    if isempty(delay_vals)
        delay_time = NaN;
    else
        delay_time = median(delay_vals,'omitnan');
    end

    % rise time calc
    vmin = min(Vout_f);
    vmax = max(Vout_f);
    v10 = vmin + 0.1*(vmax - vmin);
    v90 = vmin + 0.9*(vmax - vmin);

    rise_vals = [];

    for k = 1:length(vout_up_idx)
        idx0 = vout_up_idx(k);
        seg = max(1, idx0-50):min(length(Vout_f), idx0+50);

        vseg = Vout_f(seg);
        tseg = t(seg);

        i10 = find(vseg >= v10, 1, 'first');
        i90 = find(vseg >= v90, 1, 'first');

        if ~isempty(i10) && ~isempty(i90) && i90 > i10
            rise_vals(end+1) = abs(tseg(i90) - tseg(i10));
        end
    end

    if isempty(rise_vals)
        rise_time = NaN;
    else
        rise_time = median(rise_vals,'omitnan');
    end

    if ~isnan(rise_time) && rise_time > 0
        slew_rate = (0.8 * (vmax - vmin)) / rise_time;
    else
        slew_rate = NaN;
    end

    % store results
    valid_i = valid_i + 1;

    all_data(valid_i).t = t;
    all_data(valid_i).Vin = Vin;
    all_data(valid_i).Vout = Vout;
    all_data(valid_i).freq = freq;
    all_data(valid_i).label = freq_label;

    results = [results; table(freq, swing, sharpness, delay_time, rise_time, slew_rate)];
end

disp(results)

% sort and clean
results = sortrows(results,'freq');
freqs = results.freq;
x_khz = freqs / 1000;

% smooth
results = fillmissing(results,'linear');

results.swing = smoothdata(results.swing,'movmean',20);
results.sharpness = smoothdata(results.sharpness,'movmean',20);
results.delay_time = smoothdata(results.delay_time,'movmean',20);
results.slew_rate = smoothdata(results.slew_rate,'movmean',30);

% helper for pdf export
exportfig = @(name) exportgraphics(gcf,[name '.pdf'],'ContentType','vector');

% plots + exports
figure; semilogx(x_khz, results.swing, '.-'); xlabel('Frequency (kHz)'); ylabel('Swing (V)'); title('Output Swing vs Frequency'); exportfig('swing_plot')
figure; semilogx(x_khz, results.sharpness, '.-'); xlabel('Frequency (kHz)'); ylabel('Sharpness (V/s)'); title('Switching Sharpness vs Frequency'); exportfig('sharpness_plot')
figure; semilogx(x_khz, results.delay_time, '.-'); xlabel('Frequency (kHz)'); ylabel('Delay (s)'); title('Propagation Delay vs Frequency'); exportfig('delay_plot')
figure; semilogx(x_khz, results.slew_rate, '.-'); xlabel('Frequency (kHz)'); ylabel('Slew Rate (V/s)'); title('Slew Rate vs Frequency'); exportfig('slew_plot')

target_freqs = [100, 50000, 100000];
all_freqs = [all_data.freq];
sel = zeros(size(target_freqs));

for k = 1:length(target_freqs)
    [~, idx] = min(abs(all_freqs - target_freqs(k)));
    sel(k) = idx;
end

% waveform plots
for k = 1:3
    i = sel(k);

    figure
    plot(all_data(i).t, all_data(i).Vin, all_data(i).t, all_data(i).Vout)
    title("Waveforms: " + all_data(i).label)
    legend('Vin','Vout')
    xlabel('Time (s)')
    ylabel('Voltage (V)')
    exportgraphics(gcf,"waveform_" + k + ".pdf",'ContentType','vector')
end

% hysteresis loops
figure
hold on
for k = 1:3
    i = sel(k);
    plot(all_data(i).Vin, all_data(i).Vout, '.','DisplayName',all_data(i).label)
end
xlabel('Vin (V)')
ylabel('Vout (V)')
title('Hysteresis Loops at Selected Frequencies')
legend
exportfig('hysteresis_loops')