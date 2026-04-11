gain = load("lab6_exp2_vdm_gain.mat");

x = gain.V_dm_25dV;
y = gain.V_out_25dV;

idx = (x > -0.012 & x < 0.012);

p_gain = polyfit(x(idx), y(idx), 1);

figure;
plot(x, y, '.'); hold on;
plot(x, polyval(p_gain, x), '--', 'LineWidth', 2);
xlabel('V_{dm} (V)');
ylabel('V_{out} (V)');
title('Differential-Mode Voltage Gain');
ylim([0,6])

Av = p_gain(1);

legend('Data', sprintf('Fit (A_v = %.2f)', Av), 'Location','best');
%%

iv = load("lab6_exp2_output_IV.mat");

x = iv.V_out_25dV;
y = iv.I_out_25dV;

idx = (x > 1.5);

p_iv = polyfit(x(idx), y(idx), 1);

figure;
plot(x, y, '.'); hold on;
plot(x, polyval(p_iv, x), '--', 'LineWidth', 2);
xlabel('V_{out} (V)');
ylabel('I_{out} (A)');
title('Output I-V Characteristic');

ro = 1 / p_iv(1);

legend('Data', sprintf('Fit (r_o = %.2f \\Omega)', ro), 'Location','best');

%%
trans = load("lab6_exp2_incremental_transconductance.mat");

x = -trans.V_dm_25dV_set;
I1 = trans.I_out_25dV_set;

Ib = mean(I1);
I2 = Ib - I1;

y = I1 - I2;

window = (x > -0.05 & x < 0.05);
bad = (x > -0.03 & x < 0.024);
idx = window & ~bad;

p_gm = polyfit(x(idx), y(idx), 1);

figure;
plot(x, y, '.'); hold on;
plot(x, polyval(p_gm, x), '--', 'LineWidth', 2);
xlabel('V_{dm} (V)');
ylabel('I_1 - I_2 (A)');
title('Incremental Transconductance');

gm = p_gm(1);

legend('Data', sprintf('Fit (g_m = %.4f mho)', gm), 'Location','best');