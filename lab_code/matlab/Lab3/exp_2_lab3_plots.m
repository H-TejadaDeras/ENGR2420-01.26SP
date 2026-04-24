load("lab3_exp2_data.mat")
load("lab3_exp1_data.mat")
Ic1k   = Iout1k  - Ib1k;
Ic10k  = Iout10k - Ib10k;
Ic100k = Iout100k - Ib100k;
%% Collector current comparison 
Ic_exp1 = Iout - Ib;
figure
semilogy(Vb, Ic_exp1, '.', "MarkerSize",8, 'DisplayName','No emitter resistor')
hold on
semilogy(Vb1k,   Ic1k,   '.',"MarkerSize",8, 'DisplayName','1k\Omega')
semilogy(Vb10k,  Ic10k,  '.',"MarkerSize",8, 'DisplayName','10k\Omega')
semilogy(Vb100k, Ic100k, '.',"MarkerSize",8, 'DisplayName','100k\Omega')
idx_exp = (Vb > 0.55) & (Vb < 0.70) & (Ic_exp1 > 0);
f_exp = fit(Vb(idx_exp)', log(Ic_exp1(idx_exp))', 'poly1');
Ic_fit_exp = exp(f_exp.p1*Vb + f_exp.p2);

UT_fit = 1/f_exp.p1; 
beta_measured = 175; 

semilogy(Vb, Ic_fit_exp, 'k', 'DisplayName', sprintf('Fit (U_T = %.1f mV)', UT_fit*1000));
title('Collector Current vs Base Voltage (Semilog)')
xlabel('Base Voltage (V)')
ylabel('Collector Current (A)')
legend('Location','best')
ylim([1e-10 1e-2])
%% 10k Ic vs Vb
figure
hold on
plot(Vb1k, Ic1k, 'b.', 'DisplayName','Measured Data (1k\Omega)')
plot(Vb10k, Ic10k, 'r.', 'DisplayName','Measured Data (10k\Omega)')
plot(Vb100k, Ic100k, 'g.', 'DisplayName','Measured Data (100k\Omega)')
% linear fits for the linear regions
idx1 = (Vb1k >= 0.8) & (Vb1k <= 3.9);
f1 = fit(Vb1k(idx1)', Ic1k(idx1)', 'poly1');
plot(Vb1k, f1.p1*Vb1k + f1.p2, 'b-', 'DisplayName', sprintf('1k\Omega Fit (G_m = %.2e \mho)', f1.p1))
idx2 = (Vb10k >= 0.75) & (Vb10k <= 5);
f2 = fit(Vb10k(idx2)', Ic10k(idx2)', 'poly1');
plot(Vb10k, f2.p1*Vb10k + f2.p2, 'r-', 'DisplayName', sprintf('10k\Omega Fit (G_m = %.2e \mho)', f2.p1))
idx3 = (Vb100k >= 0.75) & (Vb100k <= 5);
f3 = fit(Vb100k(idx3)', Ic100k(idx3)', 'poly1');
plot(Vb100k, f3.p1*Vb100k + f3.p2, 'g-', 'DisplayName', sprintf('100k\Omega Fit (G_m = %.2e \mho)', f3.p1))
title('Linear Collector Current vs Base Voltage')
xlabel('Base Voltage (V)')
ylabel('Collector Current (A)')
legend("Location","best")
ylim([-0.5*10^-3 3.5*10^-3])
%% rb calculations
Rb1k   = gradient(Vb1k)./gradient(Ib1k);
Rb10k  = gradient(Vb10k)./gradient(Ib10k);
Rb100k = gradient(Vb100k)./gradient(Ib100k);

%% rb vs Ib 
figure
loglog(Ib1k, Rb1k, 'b.', 'DisplayName','Measured (1 k\Omega)')
hold on
loglog(Ib10k, Rb10k, 'r.', 'DisplayName','Measured (10 k\Omega)')
loglog(Ib100k, Rb100k, 'g.', 'DisplayName','Measured (100 k\Omega)')

Ib_range = logspace(-11, -4, 200);

idx1 = (Ib1k > 1e-8) & (Ib1k < 1e-6); 
x1 = 1 ./ Ib1k(idx1);
y1 = Rb1k(idx1);

f1 = fit(x1', y1', 'poly1'); % y = UT*x + C
UT_1k = f1.p1;
C1k   = f1.p2;

Rb_fit_1k = UT_1k ./ Ib_range + C1k;

loglog(Ib_range, Rb_fit_1k, 'b-', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Fit 1k: U_T=%.1fmV, C=%.0f\\Omega', UT_1k*1e3, C1k))

% 10k
idx2 = (Ib10k > 0.000000005) & (Ib10k < 0.000001);
x2 = 1 ./ Ib10k(idx2);
y2 = Rb10k(idx2);

f2 = fit(x2', y2', 'poly1');
UT_10k = f2.p1;
C10k   = f2.p2;

Rb_fit_10k = UT_10k ./ Ib_range + C10k;

loglog(Ib_range, Rb_fit_10k, 'r-', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Fit 10k: U_T=%.1fmV, C=%.0f\\Omega', UT_10k*1e3, C10k))

% 100k
idx3 = (Ib100k > 0.000000005) & (Ib100k <  0.000001);
x3 = 1 ./ Ib100k(idx3);
y3 = Rb100k(idx3);

f3 = fit(x3', y3', 'poly1');
UT_100k = f3.p1;
C100k   = f3.p2;

Rb_fit_100k = UT_100k ./ Ib_range + C100k;

loglog(Ib_range, Rb_fit_100k, 'g-', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Fit 100k: U_T=%.1fmV, C=%.0f\\Omega', UT_100k*1e3, C100k))

title('Incremental Base Resistance vs Base Current')
xlabel('Base Current (A)')
ylabel('R_b (\Omega)')
legend('Location','best')


%% gm calculations
Gm1k   = gradient(Ic1k)./gradient(Vb1k);
Gm10k  = gradient(Ic10k)./gradient(Vb10k);
Gm100k = gradient(Ic100k)./gradient(Vb100k);

%% gm vs Ic 
figure
loglog(Ic1k, Gm1k, 'b.', 'DisplayName','Measured (1 k\Omega)')
hold on
loglog(Ic10k, Gm10k, 'r.', 'DisplayName','Measured (10 k\Omega)')
loglog(Ic100k, Gm100k, 'g.', 'DisplayName','Measured (100 k\Omega)')

Ic_range = logspace(-10, -2, 500);

% 1k
idx_fit1 = (Ic1k > 1e-6) & (Ic1k < 1e-3);
f_fit1 = fit((1./Ic1k(idx_fit1))', (1./Gm1k(idx_fit1))', 'poly1');
% Gm = 1 / (UT/Ic + R) -> 1/Gm = UT*(1/Ic) + R
UT1 = f_fit1.p1; R1 = f_fit1.p2;
Gm_plot1 = 1 ./ (UT1./Ic_range + R1);
loglog(Ic_range, Gm_plot1, 'b', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Fit (1k): U_T=%.1fmV, R=%.0f\\Omega', UT1*1e3, R1))

% 10m
=idx_fit10 = (Ic10k > 1e-6) & (Ic10k < 1e-4);
f_fit10 = fit((1./Ic10k(idx_fit10))', (1./Gm10k(idx_fit10))', 'poly1');
UT10 = f_fit10.p1; R10 = f_fit10.p2;
Gm_plot10 = 1 ./ (UT10./Ic_range + R10);
loglog(Ic_range, Gm_plot10, 'r', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Fit (10k): U_T=%.1fmV, R=%.0f\\Omega', UT10*1e3, R10))

% 100m
=idx_fit100 = (Ic100k > 1e-6) & (Ic100k < 1e-4);
f_fit100 = fit((1./Ic100k(idx_fit100))', (1./Gm100k(idx_fit100))', 'poly1');
UT100 = f_fit100.p1; R100 = f_fit100.p2;
Gm_plot100 = 1 ./ (UT100./Ic_range + R100);
loglog(Ic_range, Gm_plot100, 'g', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Fit (100k): U_T=%.1fmV, R=%.0f\\Omega', UT100*1e3, R100))

title('Incremental Transconductance vs Collector Current')
xlabel('Collector Current (A)')
ylabel('G_m (℧)')
legend('Location','best')
xlim([1e-10 1e-2])
ylim([1e-9 2e-3])