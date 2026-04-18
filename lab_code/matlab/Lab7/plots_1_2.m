load('lab7_exp1.mat')

figure;
hold on; 

plot(V_in_25dV, V_out_25dV, '.');
plot(V_in_35dV, V_out_35dV, '.');
plot(V_in_45dV, V_out_45dV,'.');

xlabel('V_{in}');
ylabel('V_{out}');
title('Voltage Transfer Characteristics (VTC)');
legend('V_{bias}=2.5V','V_{bias}=3.5V','V_{bias}=4.5V','Location','best');
%%
load('lab7_exp2_1.mat')

figure; hold on; 

Vdm = V_dm_45dV;
Vout = -V_out_45dV(1:length(Vdm));

plot(Vdm, Vout, '.');

fit_line = 211.804 * Vdm + 0.251;

plot(Vdm, fit_line, '-', 'LineWidth', 2);

xlabel('V_{dm}');
ylabel('V_{out}');
title('V_{out} vs V_{dm} (Gain)');
legend('Data','Linear Fit: y = 211.804x + 0.251','Location','best');

ylim([-0.5 5.5])
%%
load('lab7_exp2_2.mat')

figure; 
hold on;

V = V_out_45dV(1:length(I_out));

plot(V, I_out, '.');

idx = (V >= 0.6) & (V <= .80);

p = polyfit(V(idx), I_out(idx), 1);
fit_line = polyval(p, V);
plot(V, fit_line, '-', 'LineWidth', 2);
xlabel('V_{out}');
ylabel('I_{out}');
title('Output I-V Characteristic');
legend('Data','Best-fit line','Location','best');
ylim([-0.5*10^-6, 3*10^-6])
%%
load('lab7_exp2_3.mat')

figure; 
hold on;

plot(Vdm_45dV, I_out, '.');

idx = (Vdm_45dV >= -0.09) & (Vdm_45dV <= 0.09);

p = polyfit(Vdm_45dV(idx), I_out(idx), 1);
fit_line = polyval(p, Vdm_45dV);
plot(Vdm_45dV, fit_line, '-', 'LineWidth', 2);
xlabel('V_{dm}');
ylabel('I_{out}');
title('I_{out} vs V_{dm}');
legend('Data','Best-fit line','Location','best');
ylim([-0.5*10^-6, 3*10^-6])

%% 
data = readmatrix('exp3_1_highres.csv');

CH1 = data(:,2);
CH2 = data(:,3);

t0 = -6.00e-4;
dt = 1.00e-6;

t = t0 + (0:length(CH1)-1)' * dt;

figure;


plot(t, CH1, 'b'); hold on;
plot(t, CH2, 'r');


xlabel('Time (μs)');
ylabel('Voltage (V)');
title('Unity-Gain Follower Response');

legend({'Input', 'Output'}, 'Location', 'best');

set(gca, 'FontSize', 12, 'LineWidth', 1);
ylim([0.9 1.2])

window = 75; 

CH1_smooth = movmean(CH1, window);
CH2_smooth = movmean(CH2, window);

figure;
plot(t, CH1_smooth, 'b.'); hold on;
plot(t, CH2_smooth, 'r.');

xlabel('Time (μs)');
ylabel('Voltage (V)');
title('Smoothed Unity-Gain Follower Response');
legend({'Input (smoothed)', 'Output (smoothed)'}, 'Location', 'best');