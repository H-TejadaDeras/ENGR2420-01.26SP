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
% gradient approximates derivative using finite differences so dv divided by dt is an approximation of dVout dt
% this is how fast the output voltage is changing at each moment
% when the schmitt trigger switches states the output changes very quickly so the derivative spikes

dv_smooth = movmean(abs(dv), 25);
% take absolute value because only care about magnitude of slope not direction
% then smooth again because derivative is noisy

[pks, locs] = findpeaks(dv_smooth, 'MinPeakHeight', 0.5*max(dv_smooth));
% find peaks in slope magnitude these are switching events
% only keep peaks above half the maximum to avoid small flux

V_switch = Vin(locs);
% take the input voltage at the exact times where switching occurs
% this maps switching times to switching voltages

V_UT = max(V_switch);
V_LT = min(V_switch);
% upper threshold is the largest input voltage where a switch occurs
% lower threshold is the smallest input voltage where a switch occurs
% because schmitt trigger has hysteresis the 
% switching thresholds depend on direction so we there are 2 distinct values

V_H  = V_UT - V_LT;
% hysteresis width is just the difference 
% between upper and lower thresholds this is the width of the loop

fprintf('UT: %.3f V\n', V_UT)
fprintf('LT: %.3f V\n', V_LT)
fprintf('Hysteresis: %.3f V\n', V_H)

figure()
plot(Vin, Vout)
xlabel('Input Voltage (V)')
ylabel('Output Voltage (V)')
title('Hysteresis Curve')

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
    data = readmatrix(file_path);
    t_raw = data(:,1);

    % s or ms
    if t_raw(end) > 1
        t = t_raw * 1e-6;
    else
        t = t_raw;
    end

    Vin = movmean(data(:,2), 10);
    Vout = movmean(data(:,3), 10);
    % again smooth signals to lessen noise 

    dt = t(2) - t(1);
    % sampling interval used for all derivative approximations

    % frequency from folder name
    num = regexp(folder_name,'\d+(\.\d+)?','match');
    freq = str2double(num{1});
    if contains(folder_name,'kHz'), freq = freq * 1e3; end
    % find numeric frequency from folder name string using regex
    % if units are khz convert to hz

    freq_label = string(folder_name);

    Vin_f = Vin;
    Vout_f = Vout;

    % estimate switching thresholds from diff peaks
    dvout_instant = abs(gradient(Vout_f) ./ dt);
    % find slope magnitude again same idea as before 
    % large values are switching transitions

    [~, sw_idx] = findpeaks(dvout_instant, 'MinPeakHeight', max(dvout_instant)*0.4);
    % detect peaks at forty percent of max 

    if length(sw_idx) > 1
        curr_UT = max(Vin_f(sw_idx));
        curr_LT = min(Vin_f(sw_idx));
    else
        curr_UT = V_UT;
        curr_LT = V_LT;
    end
    % find thresholds for this dataset individually
    % if detection fails fallback to earlier value
    swing = max(Vout) - min(Vout);
    % output swing is just max - min voltage 
    % this basically just measures how close the output gets to rails

    dvout_s = movmean(abs(gradient(Vout_f)/dt), 10);
    sharpness = max(dvout_s);
    % sharpness is max
    % slope magnitude so sharper 
    % transitions mean higher dv dt

    % vin threshold crossings
    vin_up_idx = find(Vin_f(1:end-1) < curr_UT & Vin_f(2:end) >= curr_UT);
    vin_dn_idx = find(Vin_f(1:end-1) > curr_LT & Vin_f(2:end) <= curr_LT);
    % detect where vin crosses threshold by looking 
    % for sign changes across consecutive samples
    % first condition for upward crossing
    %  second for downward crossing

    t_vin_rise = [];
    t_vin_fall = [];

    if ~isempty(vin_up_idx)
        t_vin_rise = arrayfun(@(k) interp1(Vin_f(k:k+1), t(k:k+1), curr_UT), vin_up_idx);
    end
    % for each crossing linearly interpolate between 
    % two samples to estimate exact crossing time
    % this improves time resolution beyond discrete sampling because i was
    % having issues with this

    if ~isempty(vin_dn_idx)
        t_vin_fall = arrayfun(@(k) interp1(Vin_f(k:k+1), t(k:k+1), curr_LT), vin_dn_idx);
    end

    % vout midpoint crossings
    v_mid = 2.5;
    vout_up_idx = find(Vout_f(1:end-1) < v_mid & Vout_f(2:end) >= v_mid);
    vout_dn_idx = find(Vout_f(1:end-1) > v_mid & Vout_f(2:end) <= v_mid);
    % same crossing logic but now for output relative to midpoint

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
        % for each input rising crossing find the next output rising crossing in time

        if ~isempty(candidates)
            d = candidates(1) - t_vin_rise(k);
            % delay is difference between output event and input event

            if d > 0 && d < 5e-6
                delay_vals(end+1) = d;
            end
            % filter out impossible or fake values negative means 
            % ordering issue very large means mismatch of cycles
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
    % use median instead of mean because 
    % it is more robust to outliers and weird mismatches
    % had a lot of issue with delay stuff so yeah this is all a but weird

    % rise time calc
    vmin = min(Vout_f);
    vmax = max(Vout_f);
    v10 = vmin + 0.1*(vmax - vmin);
    v90 = vmin + 0.9*(vmax - vmin);
    % define 10 percent and 90 percent levels 
    % relative to full swing

    rise_vals = [];

    for k = 1:length(vout_up_idx)
        idx0 = vout_up_idx(k);
        seg = max(1, idx0-50):min(length(Vout_f), idx0+50);
        % take a window around the transition so we isolate a single edge

        vseg = Vout_f(seg);
        tseg = t(seg);

        i10 = find(vseg >= v10, 1, 'first');
        i90 = find(vseg >= v90, 1, 'first');
        % find indices where signal crosses 10 percent and 90 percent levels

        if ~isempty(i10) && ~isempty(i90) && i90 > i10
            rise_vals(end+1) = abs(tseg(i90) - tseg(i10));
        end
        % rise time is time difference between those crossings
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
    % slew rate approximates dv dt using 10 to 90 percent span which is 80 percent of total swing

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
% fill missing values using linear interpolation (awkward issues with delay
% strike again)

results.swing = smoothdata(results.swing,'movmean',20);
results.sharpness = smoothdata(results.sharpness,'movmean',20);
results.delay_time = smoothdata(results.delay_time,'movmean',20);
results.slew_rate = smoothdata(results.slew_rate,'movmean',30);
% smooth across frequency to reveal general trends 
% rather than noise between individual measurements

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