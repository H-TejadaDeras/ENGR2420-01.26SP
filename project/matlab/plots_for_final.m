load('project_exp1_data')


start = str2double(project_exp1_data_parameters.Start);
increment = str2double(project_exp1_data_parameters.Increment);

time = project_exp1_data.X * increment;
Vin = project_exp1_data.CH1;
Vout = project_exp1_data.CH2;

figure
plot(time, Vin); hold on
plot(time, Vout)
xlabel('Time (s)')
ylabel('Voltage (V)')
legend('Vin','Vout')
title('Schmitt Trigger Hysteresis')

dV = diff(Vout);
threshold = 0.5 * max(abs(dV));

idx = find(abs(dV) > threshold);
V_switch = Vin(idx);

V_UT = max(V_switch);
V_LT = min(V_switch);
V_H  = V_UT - V_LT;

fprintf('UT: %.3f V\n', V_UT)
fprintf('LT: %.3f V\n', V_LT)
fprintf('Hysteresis: %.3f V\n', V_H)



%%
clear
load('project_exp2_data.mat')

data_names = {
'sine_5Hz_data'
'sine_500Hz_data'
'sine_50kHz_data'
'sine_200kHz_data'
};

param_names = {
'sine_5Hz_data_parameters'
'sine_500Hz_data_parameters'
'sine_50kHz_data_parameters'
'sine_200kHz_data_parameters'
};

results = table();

for i = 1:length(data_names)

    T = eval(data_names{i});
    P = eval(param_names{i});

    increment = str2double(P.Increment);

    t = T.X * increment;
    Vin = T.CH1;
    Vout = T.CH2;

    % frequency label
    name = data_names{i};
    freq_str = extractBetween(name, 'sine_', '_data');
    freq_label = string(freq_str{1});

    swing = max(Vout) - min(Vout);

    dVout = abs(diff(Vout));
    sharpness = max(dVout);

    % delay
    mid_in  = (max(Vin) + min(Vin)) / 2;
    mid_out = (max(Vout) + min(Vout)) / 2;

    vin_idx  = find(Vin(1:end-1) < mid_in  & Vin(2:end) >= mid_in);
    vout_idx = find(Vout(1:end-1) < mid_out & Vout(2:end) >= mid_out);

    if ~isempty(vin_idx) && ~isempty(vout_idx)

        vin_cross_time = t(vin_idx(1)) + ...
            (mid_in - Vin(vin_idx(1))) * (t(vin_idx(1)+1)-t(vin_idx(1))) / ...
            (Vin(vin_idx(1)+1)-Vin(vin_idx(1)));

        vout_cross_time = t(vout_idx(1)) + ...
            (mid_out - Vout(vout_idx(1))) * (t(vout_idx(1)+1)-t(vout_idx(1))) / ...
            (Vout(vout_idx(1)+1)-Vout(vout_idx(1)));

        delay_time = vout_cross_time - vin_cross_time;

    else
        delay_time = NaN;
    end

    % rise time
    vmin = min(Vout);
    vmax = max(Vout);
    v10 = vmin + 0.1*(vmax - vmin);
    v90 = vmin + 0.9*(vmax - vmin);

    %  where the signal crosses 10% and 90% on rise
    idx10_cross = find(Vout(1:end-1) < v10 & Vout(2:end) >= v10, 1, 'first');
    idx90_cross = find(Vout(1:end-1) < v90 & Vout(2:end) >= v90, 1, 'first');

    if ~isempty(idx10_cross) && ~isempty(idx90_cross)
        %  exact time for the 10% crossing
        t10 = t(idx10_cross) + (v10 - Vout(idx10_cross)) * (t(idx10_cross+1) - t(idx10_cross)) / (Vout(idx10_cross+1) - Vout(idx10_cross));
        
        % the exact time for the 90% crossing
        t90 = t(idx90_cross) + (v90 - Vout(idx90_cross)) * (t(idx90_cross+1) - t(idx90_cross)) / (Vout(idx90_cross+1) - Vout(idx90_cross));
        
        rise_time = t90 - t10;
        
        if rise_time <= 0
            rise_time = increment; 
        end
    else
        rise_time = NaN;
    end

    % slew
    if ~isnan(rise_time) && rise_time > 0
        slew_rate = (0.8 * (vmax - vmin)) / rise_time;
    else
        slew_rate = NaN;
    end
    results = [results; table(freq_label, swing, sharpness, delay_time, rise_time, slew_rate)];

    figure
    plot(t, Vin, '.-'); 
    hold on
    plot(t, Vout)
    title("Input vs Output at " + freq_label)
    legend('Vin','Vout')
    xlabel('Time (s)')
    ylabel('Voltage (V)')

    figure
    plot(Vin, Vout, '.-')
    xlabel('Vin (V)')
    ylabel('Vout (V)')
    title("Hysteresis Loop at " + freq_label)

end

disp(results)


N = height(results);
freqs = zeros(N,1);

for i = 1:N
    label = results.freq_label(i);

    if contains(label,"kHz")
        num = extractBefore(label,"kHz");
        freqs(i) = str2double(num) * 1e3;
    else
        num = extractBefore(label,"Hz");
        freqs(i) = str2double(num);
    end
end

x_khz = freqs / 1000;



% swing (vmax - vmin)
figure
plot(x_khz, results.swing, 'o-')
xlabel('Frequency (kHz)')
ylabel('Swing (V)')
title('Output Swing vs Frequency')

% transition speed
figure
plot(x_khz, results.sharpness, 'o-')
xlabel('Frequency (kHz)')
ylabel('Sharpness')
title('Switching Sharpness vs Frequency')

% delay (vin crossing point - vout crossing point)
figure
plot(x_khz, results.delay_time, 'o-')
xlabel('Frequency (kHz)')
ylabel('Delay (s)')
title('Propagation Delay vs Frequency')

% slew rate
figure
plot(x_khz, results.slew_rate, 'o-')
xlabel('Frequency (kHz)')
ylabel('Slew Rate (V/s)')
title('Output Switching Speed vs Frequency')
