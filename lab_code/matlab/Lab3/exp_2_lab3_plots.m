load("lab3_exp2_data.mat")

Ic1k   = Iout1k  - Ib1k;
Ic10k  = Iout10k - Ib10k;
Ic100k = Iout100k - Ib100k;

figure
semilogy(Vb1k,   Ic1k,   '.')
hold on
semilogy(Vb10k,  Ic10k,  '.')
semilogy(Vb100k, Ic100k, '.')
title('Collector Current vs Base Voltage (All Resistors)')
xlabel('Base Voltage (V)')
ylabel('Collector Current (A)')
legend('1k','10k','100k',"Location",'best')

%% 1k
figure
plot(Vb1k, Ic1k, '.', 'DisplayName','Measured Data')
title('Collector Current vs Base Voltage (1kΩ)')
xlabel('Base Voltage (V)')
ylabel('Collector Current (A)')
hold on

idx = (Vb1k >= 0.8) & (Vb1k <= 3.9);
f1 = fit(Vb1k(idx)', Ic1k(idx)', 'poly1');

Ic_fit1 = f1.p1*Vb1k + f1.p2;

eqn = sprintf('Fit: I_c = %.3e V_b + %.3e',f1.p1,f1.p2);
plot(Vb1k, Ic_fit1, 'DisplayName',eqn)

text(0.05,0.9,sprintf('G_m = %.3e S',f1.p1),'Units','normalized')

legend("Location","best")

%% 10k
figure
plot(Vb10k, Ic10k, '.', "DisplayName","Measured Data")
title('Collector Current vs Base Voltage (10kΩ)')
xlabel('Base Voltage (V)')
ylabel('Collector Current (A)')
hold on

idx = (Vb10k >= 0.75) & (Vb10k <= 5);
f2 = fit(Vb10k(idx)', Ic10k(idx)', 'poly1');

Ic_fit2 = f2.p1*Vb10k + f2.p2;

eqn = sprintf('Fit: I_c = %.3e V_b + %.3e',f2.p1,f2.p2);
plot(Vb10k, Ic_fit2, 'DisplayName',eqn)

text(0.05,0.9,sprintf('G_m = %.3e S',f2.p1),'Units','normalized')

legend("Location","best")

%% 100k
figure
plot(Vb100k, Ic100k, '.', "DisplayName","Measured Data")
title('Collector Current vs Base Voltage (100kΩ)')
xlabel('Base Voltage (V)')
ylabel('Collector Current (A)')
hold on

idx = (Vb100k >= 0.75) & (Vb100k <= 5);
f3 = fit(Vb100k(idx)', Ic100k(idx)', 'poly1');

Ic_fit3 = f3.p1*Vb100k + f3.p2;

eqn = sprintf('Fit: I_c = %.3e V_b + %.3e',f3.p1,f3.p2);
plot(Vb100k, Ic_fit3, 'DisplayName',eqn)

text(0.05,0.9,sprintf('G_m = %.3e S',f3.p1),'Units','normalized')

legend("Location","best")

%% rb
Rb1k   = gradient(Vb1k)./gradient(Ib1k);
Rb10k  = gradient(Vb10k)./gradient(Ib10k);
Rb100k = gradient(Vb100k)./gradient(Ib100k);

%% rb vs Ib (1k)
figure
loglog(Ib1k, Rb1k, '.', 'DisplayName','Measured')
hold on

idx = (Ib1k >= 10^-8.95) & (Ib1k <= 10^-7.1) & (Rb1k > 0);
fRb1 = fit(log(Ib1k(idx))', log(Rb1k(idx))', 'poly1');

A = exp(fRb1.p2);
m = fRb1.p1;

Rb_fit1 = A*Ib1k.^m;

eqn = sprintf('Fit: R_b = %.3e I_b^{%.2f}',A,m);
loglog(Ib1k, Rb_fit1,'DisplayName',eqn)

text(0.05,0.9,sprintf('Exponent m = %.2f',m),'Units','normalized')

title('Incremental Base Resistance vs Base Current (1kΩ)')
xlabel('Base Current (A)')
ylabel('R_b (\Omega)')
legend('Location','best')

%% rb vs Ib (10k)
figure
loglog(Ib10k, Rb10k, '.', 'DisplayName','Measured')
hold on

idx = (Ib10k >= 10^-9.6) & (Ib10k <= 10^-7.7) & (Rb10k > 0);
fRb2 = fit(log(Ib10k(idx))', log(Rb10k(idx))', 'poly1');

A = exp(fRb2.p2);
m = fRb2.p1;

Rb_fit2 = A*Ib10k.^m;

eqn = sprintf('Fit: R_b = %.3e I_b^{%.2f}',A,m);
loglog(Ib10k, Rb_fit2,'DisplayName',eqn)

text(0.05,0.9,sprintf('Exponent m = %.2f',m),'Units','normalized')

title('Incremental Base Resistance vs Base Current (10kΩ)')
xlabel('Base Current (A)')
ylabel('R_b (\Omega)')
legend('Location','best')

%% rb vs Ib (100k)
figure
loglog(Ib100k, Rb100k, '.', 'DisplayName','Measured')
hold on

idx = (Ib100k >= 10^-9.8) &(Ib100k <= 10^-8.1) & (Rb100k > 0);
fRb3 = fit(log(Ib100k(idx))', log(Rb100k(idx))', 'poly1');

A = exp(fRb3.p2);
m = fRb3.p1;

Rb_fit3 = A*Ib100k.^m;

eqn = sprintf('Fit: R_b = %.3e I_b^{%.2f}',A,m);
loglog(Ib100k, Rb_fit3,'DisplayName',eqn)

text(0.05,0.9,sprintf('Exponent m = %.2f',m),'Units','normalized')

title('Incremental Base Resistance vs Base Current (100kΩ)')
xlabel('Base Current (A)')
ylabel('R_b (\Omega)')
legend('Location','best')

%% gm
Gm1k   = gradient(Ic1k)./gradient(Vb1k);
Gm10k  = gradient(Ic10k)./gradient(Vb10k);
Gm100k = gradient(Ic100k)./gradient(Vb100k);

%% gm vs Ic (1k)
figure
loglog(Ic1k, Gm1k, '.', 'DisplayName','Measured')
hold on

idx = (Ic1k >= 10^-9.2) & (Ic1k <= 10^-5.4) & (Gm1k > 0);
fGm1 = fit(log(Ic1k(idx))', log(Gm1k(idx))', 'poly1');

A = exp(fGm1.p2);
m = fGm1.p1;

Gm_fit1 = A*Ic1k.^m;

eqn = sprintf('Fit: G_m = %.3e I_c^{%.2f}',A,m);
loglog(Ic1k, Gm_fit1,'DisplayName',eqn)

text(0.05,0.9,sprintf('Exponent m = %.2f',m),'Units','normalized')

title('Incremental Transconductance vs Collector Current (1kΩ)')
xlabel('Collector Current (A)')
ylabel('G_m (S)')
legend('Location','best')

%% gm vs Ic (10k)
figure
loglog(Ic10k, Gm10k, '.', 'DisplayName','Measured')
hold on

idx = (Ic10k >= 1e-9) & (Ic10k <= 10^-5.4) & (Gm10k > 0);
fGm2 = fit(log(Ic10k(idx))', log(Gm10k(idx))', 'poly1');

A = exp(fGm2.p2);
m = fGm2.p1;

Gm_fit2 = A*Ic10k.^m;

eqn = sprintf('Fit: G_m = %.3e I_c^{%.2f}',A,m);
loglog(Ic10k, Gm_fit2,'DisplayName',eqn)

text(0.05,0.9,sprintf('Exponent m = %.2f',m),'Units','normalized')

title('Incremental Transconductance vs Collector Current (10kΩ)')
xlabel('Collector Current (A)')
ylabel('G_m (S)')
legend('Location','best')

%% gm vs Ic (100k)
figure
loglog(Ic100k, Gm100k, '.', 'DisplayName','Measured')
hold on

idx = (Ic100k >= 10^-9.5) & (Ic100k <= 10^-6.5) & (Gm100k > 0);
fGm3 = fit(log(Ic100k(idx))', log(Gm100k(idx))', 'poly1');

A = exp(fGm3.p2);
m = fGm3.p1;

Gm_fit3 = A*Ic100k.^m;

eqn = sprintf('Fit: G_m = %.3e I_c^{%.2f}',A,m);
loglog(Ic100k, Gm_fit3,'DisplayName',eqn)

text(0.05,0.9,sprintf('Exponent m = %.2f',m),'Units','normalized')

title('Incremental Transconductance vs Collector Current (100kΩ)')
xlabel('Collector Current (A)')
ylabel('G_m (S)')
legend('Location','best')