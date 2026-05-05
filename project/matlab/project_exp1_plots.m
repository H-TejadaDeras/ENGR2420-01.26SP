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