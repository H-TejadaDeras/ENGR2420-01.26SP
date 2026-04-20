clear; close all; clc;

%% exp1
load('lab7_exp1.mat')

figure; hold on;

plot(V_in_25dV, -V_out_25dV, '.');
plot(V_in_35dV, -V_out_35dV, '.');
plot(V_in_45dV, -V_out_45dV, '.');

xlabel('V_{in} (V)');
ylabel('V_{out} (V)');
title('Voltage Transfer Characteristics (VTC)');
legend('V_{ref} = 2.5 V','V_{ref} = 3.5 V','V_{ref} = 4.5 V','Location','best');


%% exp 2 a
load('lab7_exp2_1.mat')

figure; hold on;

Vdm = V_dm_45dV;
Vout = -V_out_45dV(1:length(Vdm));

plot(Vdm, Vout, '.');

gain = 181.704;
offset = -0.1;

fit_line = gain * Vdm + offset;
plot(Vdm, fit_line, 'LineWidth', 2);

xlabel('V_{dm} (V)');
ylabel('V_{out} (V)');
title('Differential-Mode Voltage Gain');
legend('Data','Linear Fit','Location','best');

ylim([-0.5 5.5])

text(-0.75, 4.5, sprintf('A_v = %.2f V/V', gain), 'FontSize', 12);


%% exp 2 b
load('lab7_exp2_2_v2.mat')

figure; hold on;

V = V_out_45dV;
I = I_out_45dV;

plot(V, I, '.');

idx = (V >= 1.5) & (V <= 2.5);

p = polyfit(V(idx), I(idx), 1);
slope = p(1);
r_out = 1 / slope;

fit_line = polyval(p, V);
plot(V, fit_line, 'LineWidth', 2);

xlabel('V_{out} (V)');
ylabel('I_{out} (A)');
title('Output I-V Characteristic');
legend('Data','Linear Fit','Location','best');

text(1.6, max(I)*0.8, sprintf('r_{out} = %.2e \\Omega', r_out), 'FontSize', 12);


%% exp 2 c
load('lab7_exp2_3.mat')

figure; hold on;

plot(Vdm_45dV, I_out, '.');

idx = (Vdm_45dV >= -0.06) & (Vdm_45dV <= 0.0);

p = polyfit(Vdm_45dV(idx), I_out(idx), 1);
gm = p(1);

fit_line = polyval(p, Vdm_45dV);
plot(Vdm_45dV, fit_line, 'LineWidth', 2);

xlabel('V_{dm} (V)');
ylabel('I_{out} (A)');
title('Incremental Transconductance');
legend('Data','Linear Fit','Location','best');

ylim([-0.5e-6, 3e-6])


text(0.05, 1.5*10^-6, sprintf('g_m = %.2e ℧', gm), 'FontSize', 12);

%% gain compare
Av_calc = gm * r_out;
fprintf('Gain from VTC: %.2f V/V\n', gain);
fprintf('Gain from gm*rout: %.2f V/V\n', Av_calc);


%% exp2

data = readmatrix('Short Pulse\NewFile1.csv');

CH1 = data(:,2);
CH2 = data(:,3);

CH1_smooth = movmean(CH1, 10);
CH2_smooth = movmean(CH2, 10);

t0 = -6.00e-4;
dt = 1.00e-6;
t = t0 + (0:length(CH1)-1)' * dt;
t = t - t(1);

offset_correction = mean(CH2_smooth(1:50)) - mean(CH1_smooth(1:50));
CH2_aligned = CH2_smooth - offset_correction;

[~, rise_idx_in] = max(diff(CH1_smooth));
[~, fall_idx_in] = min(diff(CH1_smooth));
t_rise_edge = t(rise_idx_in);
t_fall_edge = t(fall_idx_in);

figure;
plot(t, CH1_smooth, 'b.'); hold on;
plot(t, CH2_aligned, 'r.');
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Unity-Gain Follower (50mV)');


idx_rise = (t > t_rise_edge + 5e-6) & (t < t_rise_edge + 108e-6);

t_rise = t(idx_rise);
v_rise = CH2_aligned(idx_rise);

Vf_r = v_rise(end);
Vi_r = v_rise(1);

mask_r = abs(v_rise - Vf_r) > 1e-4;
t_r = t_rise(mask_r);
v_r = v_rise(mask_r);

y_r = log(abs(v_r - Vf_r));
p_r = polyfit(t_r, y_r, 1);
tau_rise = -1 / p_r(1);

t_fit_rise = t;
Vfit_rise = Vf_r + (Vi_r - Vf_r) * exp(-(t_fit_rise - t_r(1)) / tau_rise);

plot(t_fit_rise, Vfit_rise, 'k-', 'LineWidth', 2);

idx_fall = (t > t_fall_edge + 5e-6) & (t < t_fall_edge + 105e-6);

t_fall = t(idx_fall);
v_fall = CH2_aligned(idx_fall);

Vf_f = v_fall(end);
Vi_f = v_fall(1);

mask_f = abs(v_fall - Vf_f) > 1e-4;
t_f = t_fall(mask_f);
v_f = v_fall(mask_f);

y_f = log(abs(v_f - Vf_f));
p_f = polyfit(t_f, y_f, 1);
tau_fall = -1 / p_f(1);

t_fit_fall = t;
Vfit_fall = Vf_f + (Vi_f - Vf_f) * exp(-(t_fit_fall - t_f(1)) / tau_fall);

plot(t_fit_fall, Vfit_fall, 'm-', 'LineWidth', 2);

legend('Input (V)','Output (V)','Rise Fit','Fall Fit','Location','bestoutside');

xlim([0 1.2*10^-3])
ylim([1.47 1.54])
text(0.625*10^-3, 1.5, sprintf('\\tau_{rise} = %.2e s', tau_rise), ...
    'FontSize', 11, 'Color', 'k');

text(0.355*10^-3, 1.525, sprintf('\\tau_{fall} = %.2e s', tau_fall), ...
    'FontSize', 11, 'Color', 'm');

%% exp 3

data = readmatrix('Long Pulse\NewFile1.csv');

CH1 = data(:,2);
CH2 = data(:,3);

CH1_smooth = movmean(CH1,4);
CH2_smooth = movmean(CH2,4);

t0 = -6.00e-4;
dt = 1.00e-6;
t = t0 + (0:length(CH1)-1)' * dt;
t = t - t(1);

offset_correction = mean(CH2_smooth(1:50)) - mean(CH1_smooth(1:50));
CH2_aligned = CH2_smooth - offset_correction;

[~, rise_idx_in] = max(diff(CH1_smooth));
[~, fall_idx_in] = min(diff(CH1_smooth));
t_rise_edge = t(rise_idx_in);
t_fall_edge = t(fall_idx_in);

figure;
plot(t, CH1_smooth, 'b.'); hold on;
plot(t, CH2_aligned, 'r.');
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Unity-Gain Follower (3V)');

idx_rise = (t > t_rise_edge + 2e-6) & (t < t_rise_edge + 60e-6);

p_rise = polyfit(t(idx_rise), CH2_aligned(idx_rise), 1);
slew_rise = p_rise(1);

t_fit = linspace(min(t), max(t), 500);
plot(t_fit, polyval(p_rise, t_fit), 'k-', 'LineWidth', 2);

idx_fall = (t > t_fall_edge + 2e-6) & (t < t_fall_edge + 40e-6);

p_fall = polyfit(t(idx_fall), CH2_aligned(idx_fall), 1);
slew_fall = p_fall(1);

plot(t_fit, polyval(p_fall, t_fit), 'm-', 'LineWidth', 2);

legend('Input (V)','Output (V)','Rise Fit','Fall Fit','Location','bestoutside');

ylim([-0.5 3.5])

text(0.1e-03, -0.2, ...
    sprintf('SR_{rise} = %.2e V/s', slew_rise),'FontSize', 11, 'Color', 'k');

text(0.35e-03, 2.75, ...
    sprintf('SR_{fall} = %.2e V/s', slew_fall),'FontSize', 11, 'Color', 'm');

