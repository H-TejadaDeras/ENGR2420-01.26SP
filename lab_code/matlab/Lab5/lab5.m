load("I1_measurements_lab5.mat")
load("I2_measurements_lab5.mat")
load("V_measurements_lab5.mat")

tmp_var = I_out1_25dV_60dV; I_out1_25dV_60dV = I_out2_25dV_60dV; I_out2_25dV_60dV = tmp_var;
tmp_var = I_out1_35dV_60dV; I_out1_35dV_60dV = I_out2_35dV_60dV; I_out2_35dV_60dV = tmp_var;
tmp_var = I_out1_45dV_60dV; I_out1_45dV_60dV = I_out2_45dV_60dV; I_out2_45dV_60dV = tmp_var;

tmp_var = I_out1_25dV_150dV; I_out1_25dV_150dV = I_out2_25dV_150dV; I_out2_25dV_150dV = tmp_var;
tmp_var = I_out1_35dV_150dV; I_out1_35dV_150dV = I_out2_35dV_150dV; I_out2_35dV_150dV = tmp_var;
tmp_var = I_out1_45dV_150dV; I_out1_45dV_150dV = I_out2_45dV_150dV; I_out2_45dV_150dV = tmp_var;

% IV Characteristics - V_b = 0.6 V
figure()
hold on;
plot(V_dm_25dV_60dV, I_out1_25dV_60dV, '.', DisplayName='I_{out 1} (V_2: 0.25 V, V_b: 0.6 V)')
plot(V_dm_35dV_60dV, I_out1_35dV_60dV, '.', DisplayName='I_{out 1} (V_2: 0.35 V, V_b: 0.6 V)')
plot(V_dm_45dV_60dV, I_out1_45dV_60dV, '.', DisplayName='I_{out 1} (V_2: 0.45 V, V_b: 0.6 V)')

plot(V_dm_25dV_60dV, I_out2_25dV_60dV, '.', DisplayName='I_{out 2} (V_2: 0.25 V, V_b: 0.6 V)')
plot(V_dm_35dV_60dV, I_out2_35dV_60dV, '.', DisplayName='I_{out 2} (V_2: 0.35 V, V_b: 0.6 V)')
plot(V_dm_45dV_60dV, I_out2_45dV_60dV, '.', DisplayName='I_{out 2} (V_2: 0.45 V, V_b: 0.6 V)')

plot(V_dm_25dV_60dV, (I_out1_25dV_60dV - I_out2_25dV_60dV), '--', DisplayName='I_{out 1} - I_{out2} (V_2: 0.25 V, V_b: 0.6 V)')
plot(V_dm_35dV_60dV, (I_out1_35dV_60dV - I_out2_35dV_60dV), '--', DisplayName='I_{out 1} - I_{out2} (V_2: 0.35 V, V_b: 0.6 V)')
plot(V_dm_45dV_60dV, (I_out1_45dV_60dV - I_out2_45dV_60dV), '--', DisplayName='I_{out 1} - I_{out2} (V_2: 0.45 V, V_b: 0.6 V)')

plot(V_dm_25dV_60dV, (I_out2_25dV_60dV + I_out1_25dV_60dV), '-.', DisplayName='I_{out 2} + I_{out1} (V_2: 0.25 V, V_b: 0.6 V)')
plot(V_dm_35dV_60dV, (I_out2_35dV_60dV + I_out1_35dV_60dV), '-.', DisplayName='I_{out 2} + I_{out1} (V_2: 0.35 V, V_b: 0.6 V)')
plot(V_dm_45dV_60dV, (I_out2_45dV_60dV + I_out1_45dV_60dV), '-.', DisplayName='I_{out 2} + I_{out1} (V_2: 0.45 V, V_b: 0.6 V)')

title('Current-Voltage Characteristics (V_b = 0.6 V)')
xlabel('Differential-Mode Input Voltage, V_1 - V_2 (V)')
ylabel('Current (A)')
lgd = legend(Location='southoutside');
lgd.Box = 'off';
lgd.NumColumns = 2;

% Common-source Node Voltage Characteristics - V_b = 0.6 V
figure()
hold on;
plot(V_dm_25dV_60dV, V_25dV_60dV, '.', DisplayName='V (V_2: 0.25 V, V_b: 0.6 V)')
plot(V_dm_35dV_60dV, V_35dV_60dV, '.', DisplayName='V (V_2: 0.35 V, V_b: 0.6 V)')
plot(V_dm_45dV_60dV, V_45dV_60dV, '.', DisplayName='V (V_2: 0.45 V, V_b: 0.6 V)')

title('Common-Source Node Voltage Characteristics (V_b = 0.6 V)')
xlabel('Differential-Mode Input Voltage, V_1 - V_2 (V)')
ylabel('Common-Source Node Voltage (V)')
lgd = legend(Location='southoutside');
lgd.Box = 'off';

% Incremental Differential-mode Transconductance Gain - V_b = 0.6 V
% TODO: Add Fits for transconductance

figure()
hold on;
plot(V_dm_25dV_60dV, (I_out1_25dV_60dV - I_out2_25dV_60dV), '.', DisplayName='I_{out 1} - I_{out2} (V_2: 0.25 V, V_b: 0.6 V)')
plot(V_dm_35dV_60dV, (I_out1_35dV_60dV - I_out2_35dV_60dV), '.', DisplayName='I_{out 1} - I_{out2} (V_2: 0.35 V, V_b: 0.6 V)')
plot(V_dm_45dV_60dV, (I_out1_45dV_60dV - I_out2_45dV_60dV), '.', DisplayName='I_{out 1} - I_{out2} (V_2: 0.45 V, V_b: 0.6 V)')

vals_range = find(V_dm_25dV_60dV > -0.1 & V_dm_25dV_60dV < 0.1);
plot_range = linspace(-0.15, 0.15, 101);
tmp = (I_out1_25dV_60dV - I_out2_25dV_60dV);
fit_vals = polyfit(V_dm_25dV_60dV(vals_range), tmp(vals_range), 1);
plot(plot_range, fit_vals(1) .* plot_range + fit_vals(2), DisplayName=['Incremental Differential-Mode Transconductance Gain: y = ', num2str(fit_vals(1), 3), 'x ', char(8487), ' + ', num2str(fit_vals(2), 3), ' V'])

vals_range = find(V_dm_35dV_60dV > -0.1 & V_dm_35dV_60dV < 0.1);
plot_range = linspace(-0.15, 0.15, 101);
tmp = (I_out1_35dV_60dV - I_out2_35dV_60dV);
fit_vals = polyfit(V_dm_35dV_60dV(vals_range), tmp(vals_range), 1);
plot(plot_range, fit_vals(1) .* plot_range + fit_vals(2), DisplayName=['Incremental Differential-Mode Transconductance Gain: y = ', num2str(fit_vals(1), 3), 'x ', char(8487), ' + ', num2str(fit_vals(2), 3), ' V'])

vals_range = find(V_dm_45dV_60dV > -0.1 & V_dm_45dV_60dV < 0.1);
plot_range = linspace(-0.15, 0.15, 101);
tmp = (I_out1_45dV_60dV - I_out2_45dV_60dV);
fit_vals = polyfit(V_dm_45dV_60dV(vals_range), tmp(vals_range), 1);
plot(plot_range, fit_vals(1) .* plot_range + fit_vals(2), DisplayName=['Incremental Differential-Mode Transconductance Gain: y = ', num2str(fit_vals(1), 3), 'x ', char(8487), ' + ', num2str(fit_vals(2), 3), ' V'])

title('Incremental Transconductance Gain Characteristics (V_b = 0.6 V)')
xlabel('Differential-Mode Input Voltage, V_1 - V_2 (V)')
ylabel('Differential-Mode Input Current, I_1 - I_2 (A)')
lgd = legend(Location='southoutside');
lgd.Box = 'off';

% IV Characteristics - V_b = 1.5 V
figure()
hold on;
plot(V_dm_25dV_150dV, I_out1_25dV_150dV, '.', DisplayName='I_{out 1} (V_2: 0.25 V, V_b: 1.5 V)')
plot(V_dm_35dV_150dV, I_out1_35dV_150dV, '.', DisplayName='I_{out 1} (V_2: 0.35 V, V_b: 1.5 V)')
plot(V_dm_45dV_150dV, I_out1_45dV_150dV, '.', DisplayName='I_{out 1} (V_2: 0.45 V, V_b: 1.5 V)')

plot(V_dm_25dV_150dV, I_out2_25dV_150dV, '.', DisplayName='I_{out 2} (V_2: 0.25 V, V_b: 1.5 V)')
plot(V_dm_35dV_150dV, I_out2_35dV_150dV, '.', DisplayName='I_{out 2} (V_2: 0.35 V, V_b: 1.5 V)')
plot(V_dm_45dV_150dV, I_out2_45dV_150dV, '.', DisplayName='I_{out 2} (V_2: 0.45 V, V_b: 1.5 V)')

plot(V_dm_25dV_150dV, (I_out1_25dV_150dV - I_out2_25dV_150dV), '--', DisplayName='I_{out 1} - I_{out2} (V_2: 0.25 V, V_b: 1.5 V)')
plot(V_dm_35dV_150dV, (I_out1_35dV_150dV - I_out2_35dV_150dV), '--', DisplayName='I_{out 1} - I_{out2} (V_2: 0.35 V, V_b: 1.5 V)')
plot(V_dm_45dV_150dV, (I_out1_45dV_150dV - I_out2_45dV_150dV), '--', DisplayName='I_{out 1} - I_{out2} (V_2: 0.45 V, V_b: 1.5 V)')

plot(V_dm_25dV_150dV, (I_out2_25dV_150dV + I_out1_25dV_150dV), '-.', DisplayName='I_{out 2} + I_{out1} (V_2: 0.25 V, V_b: 1.5 V)')
plot(V_dm_35dV_150dV, (I_out2_35dV_150dV + I_out1_35dV_150dV), '-.', DisplayName='I_{out 2} + I_{out1} (V_2: 0.35 V, V_b: 1.5 V)')
plot(V_dm_45dV_150dV, (I_out2_45dV_150dV + I_out1_45dV_150dV), '-.', DisplayName='I_{out 2} + I_{out1} (V_2: 0.45 V, V_b: 1.5 V)')

title('Current-Voltage Characteristics (V_b = 1.5 V)')
xlabel('Differential-Mode Input Voltage, V_1 - V_2 (V)')
ylabel('Current (A)')
lgd = legend(Location='southoutside');
lgd.Box = 'off';
lgd.NumColumns = 2;


Gdm_60 = zeros(1,3);

% V2 = 0.25 V
vals_range = find(V_dm_25dV_60dV > -0.1 & V_dm_25dV_60dV < 0.1);
tmp = I_out1_25dV_60dV - I_out2_25dV_60dV;
fit_vals = polyfit(V_dm_25dV_60dV(vals_range), tmp(vals_range), 1);
Gdm_60(1) = fit_vals(1);

% V2 = 0.35 V
vals_range = find(V_dm_35dV_60dV > -0.1 & V_dm_35dV_60dV < 0.1);
tmp = I_out1_35dV_60dV - I_out2_35dV_60dV;
fit_vals = polyfit(V_dm_35dV_60dV(vals_range), tmp(vals_range), 1);
Gdm_60(2) = fit_vals(1);

% V2 = 0.45 V
vals_range = find(V_dm_45dV_60dV > -0.1 & V_dm_45dV_60dV < 0.1);
tmp = I_out1_45dV_60dV - I_out2_45dV_60dV;
fit_vals = polyfit(V_dm_45dV_60dV(vals_range), tmp(vals_range), 1);
Gdm_60(3) = fit_vals(1);

fprintf('Gdm (0.6 V bias): %.3e, %.3e, %.3e S\n', Gdm_60);

I_tail_60 = zeros(1,3)

% V2 = 0.25 V
vals = find(abs(V_dm_25dV_60dV) < 0.05);
I_tail_60(1) = mean(I_out1_25dV_60dV(vals) + I_out2_25dV_60dV(vals));

% V2 = 0.35 V
vals = find(abs(V_dm_35dV_60dV) < 0.05);
I_tail_60(2) = mean(I_out1_35dV_60dV(vals) + I_out2_35dV_60dV(vals));

% V2 = 0.45 V
vals = find(abs(V_dm_45dV_60dV) < 0.05);
I_tail_60(3) = mean(I_out1_45dV_60dV(vals) + I_out2_45dV_60dV(vals));

fprintf('Tail current (0.6 V bias): %.3e, %.3e, %.3e A\n', I_tail_60);

Gdm_150 = zeros(1,3);

% V2 = 0.25 V
vals_range = find(V_dm_25dV_150dV > -0.1 & V_dm_25dV_150dV < 0.1);
tmp = I_out1_25dV_150dV - I_out2_25dV_150dV;
fit_vals = polyfit(V_dm_25dV_150dV(vals_range), tmp(vals_range), 1);
Gdm_150(1) = abs(fit_vals(1));

% V2 = 0.35 V
vals_range = find(V_dm_35dV_150dV > -0.1 & V_dm_35dV_150dV < 0.1);
tmp = I_out1_35dV_150dV - I_out2_35dV_150dV;
fit_vals = polyfit(V_dm_35dV_150dV(vals_range), tmp(vals_range), 1);
Gdm_150(2) = abs(fit_vals(1));

% V2 = 0.45 V
vals_range = find(V_dm_45dV_150dV > -0.1 & V_dm_45dV_150dV < 0.1);
tmp = I_out1_45dV_150dV - I_out2_45dV_150dV;
fit_vals = polyfit(V_dm_45dV_150dV(vals_range), tmp(vals_range), 1);
Gdm_150(3) = abs(fit_vals(1));

fprintf('Gdm (1.5 V bias): %.3e, %.3e, %.3e S\n', Gdm_150);

I_tail_150 = zeros(1,3);

% V2 = 0.25 V
vals = find(abs(V_dm_25dV_150dV) < 0.05);
I_tail_150(1) = mean(I_out1_25dV_150dV(vals) + I_out2_25dV_150dV(vals));

% V2 = 0.35 V
vals = find(abs(V_dm_35dV_150dV) < 0.05);
I_tail_150(2) = mean(I_out1_35dV_150dV(vals) + I_out2_35dV_150dV(vals));

% V2 = 0.45 V
vals = find(abs(V_dm_45dV_150dV) < 0.05);
I_tail_150(3) = mean(I_out1_45dV_150dV(vals) + I_out2_45dV_150dV(vals));

fprintf('Tail current (1.5 V bias): %.3e, %.3e, %.3e A\n', I_tail_150);
