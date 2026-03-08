load('exp2_lab2_v2.mat')

% Voltage across Diode-Connected Transistor vs Input Voltage (all three)
figure();
semilogy(V_in_120, V_q_120, '.', DisplayName='120 \Omega')
hold on;
semilogy(V_in_10k, V_q_10k, '.', DisplayName='10 k\Omega')
semilogy(V_in_200k, V_q_200k, '.', DisplayName='200 k\Omega')

fit_vals = polyfit(V_in_120(find(V_in_120 > 1)), V_q_120(find(V_in_120 > 1)), 1);
plot(linspace(0, 3, 101), fit_vals(1) .* linspace(0, 3, 101) + fit_vals(2), DisplayName=['Steady State Transistor Voltage Fit, R = 120 \Omega: y = ', num2str(fit_vals(1), 3), 'x + ', num2str(fit_vals(2), 3)])

fit_vals = polyfit(V_in_10k(find(V_in_10k > 1)), V_q_10k(find(V_in_10k > 1)), 1);
plot(linspace(0, 3, 101), fit_vals(1) .* linspace(0, 3, 101) + fit_vals(2), DisplayName=['Steady State Transistor Voltage Fit, R = 10 k\Omega: y = ', num2str(fit_vals(1), 3), 'x + ', num2str(fit_vals(2), 3)])

fit_vals = polyfit(V_in_200k(find(V_in_200k > 1)), V_q_200k(find(V_in_200k > 1)), 1);
plot(linspace(0, 3, 101), fit_vals(1) .* linspace(0, 3, 101) + fit_vals(2), DisplayName=['Steady State Transistor Voltage Fit, R = 200 k\Omega: y = ', num2str(fit_vals(1), 3), 'x + ', num2str(fit_vals(2), 3)])

title('Voltage Across Transistor vs. Input Voltage')
xlabel('V_{in} (V)')
ylabel('V_{Q} (V)')
legend(Location="southoutside")

% Current Flowing into Circuit vs. Input Voltage
figure();
semilogy(V_in_120, I_in_120, '.', DisplayName='120 \Omega')
hold on;
semilogy(V_in_10k, I_in_10k, '.', DisplayName='10 k\Omega')
semilogy(V_in_200k, I_in_200k, '.', DisplayName='200 k\Omega')

fit_vals = fit(V_in_120(find(V_in_120 < 0.6))', I_in_120(find(V_in_120 < 0.6))', 'exp2'); %[output:46c4648b]
semilogy(linspace(0, 0.7, 101), fit_vals.a .* exp(linspace(0, 0.7, 101) .* fit_vals.b), DisplayName=['Effect of Transistor Fitted Line, R = 120 \Omega: y = ', num2str(fit_vals.a, 3), 'x + ', num2str(fit_vals.b)])
fit_vals = fit(V_in_10k(find(V_in_10k < 0.5))', I_in_10k(find(V_in_10k < 0.5))', 'exp2');
semilogy(linspace(0, 0.6, 101), fit_vals.a .* exp(linspace(0, 0.6, 101) .* fit_vals.b), DisplayName=['Effect of Transistor Fitted Line, R = 10 k\Omega: y = ', num2str(fit_vals.a, 3), 'x + ', num2str(fit_vals.b)])
fit_vals = fit(V_in_200k(find(V_in_200k < 0.4))', I_in_200k(find(V_in_200k < 0.4))', 'exp2');
semilogy(linspace(0, 0.4, 101), fit_vals.a .* exp(linspace(0, 0.4, 101) .* fit_vals.b), DisplayName=['Effect of Transistor Fitted Line, R = 200 k\Omega: y = ', num2str(fit_vals.a, 3), 'x + ', num2str(fit_vals.b)])

title('Current vs. Input Voltage of Circuit')
xlabel('V_{in} (V)')
ylabel('I_{in} (A)')
legend(Location="southoutside")

% Plot showing input current vs applied input voltage (3 plots)
U_T = 0.0191; % V; From Experiment 1 Data
I_s = 3e-15; % A

figure();
hold on;
plot(V_in_120, I_in_120, '.', DisplayName='Measured Data')
plot(log(((U_T/120)/I_s) + 1) * U_T, U_T/120, 'x', DisplayName=['(V_{on} = ', num2str(log(((U_T/120)/I_s) + 1) * U_T, 3), ' V, I_{on} = ', num2str(U_T/120, 3),' A) with U_{T} = 25 mV; I_{s} = 3 fA'])

fit_vals = polyfit(V_in_120(find(V_in_120 < 0.6)), I_in_120(find(V_in_120 < 0.6)), 1);
plot(linspace(0, 3, 101), fit_vals(1) .* linspace(0, 3, 101) + fit_vals(2), DisplayName=['\deltaV Transistor Dominance Fit: y = ', num2str(fit_vals(1), 3), 'x + ', num2str(fit_vals(2), 3)])

fit_vals = polyfit(V_in_120(find(0.6 < V_in_120 & V_in_120 < 1.1)), I_in_120(find(0.6 < V_in_120 & V_in_120 < 1.1)), 1);
plot(linspace(0.5, 1.5, 101), fit_vals(1) .* linspace(0.5, 1.5, 101) + fit_vals(2), DisplayName=['\deltaV Resistor Dominance Fit: y = ', num2str(fit_vals(1), 3), 'x + ', num2str(fit_vals(2), 3)])

title('Circuit with 120 \Omega Resistor IV Plot')
xlabel('V_{in} (V)')
ylabel('I_{in} (A)')
legend(Location='southoutside')

figure();
hold on;
plot(V_in_10k, I_in_10k, '.', DisplayName='Measured Data')
plot(log(((U_T/10e3)/I_s) + 1) * U_T, U_T/10e3, 'x', DisplayName=['(V_{on} = ', num2str(log(((U_T/10e3)/I_s) + 1) * U_T, 3), ' V, I_{on} = ', num2str(U_T/10e3, 3),' A) with U_{T} = 25 mV; I_{s} = 3 fA'])

fit_vals = polyfit(V_in_10k(find(V_in_10k < 0.4)), I_in_10k(find(V_in_10k < 0.4)), 1);
plot(linspace(0, 3, 101), fit_vals(1) .* linspace(0, 3, 101) + fit_vals(2), DisplayName=['\deltaV Transistor Dominance Fit: y = ', num2str(fit_vals(1), 3), 'x + ', num2str(fit_vals(2), 3)])

fit_vals = polyfit(V_in_10k(find(0.6 < V_in_10k & V_in_10k < 3)), I_in_10k(find(0.6 < V_in_10k & V_in_10k < 3)), 1);
plot(linspace(0, 3, 101), fit_vals(1) .* linspace(0, 3, 101) + fit_vals(2), DisplayName=['\deltaV Resistor Dominance Fit: y = ', num2str(fit_vals(1), 3), 'x + ', num2str(fit_vals(2), 3)])

title('Circuit with 10 k\Omega Resistor IV Plot')
xlabel('V_{in} (V)')
ylabel('I_{in} (A)')
legend(Location='southoutside')

figure();
hold on;
plot(V_in_200k, I_in_200k, '.', DisplayName='Measured Data')
plot(log(((U_T/200e3)/I_s) + 1) * U_T, U_T/200e3, 'x', DisplayName=['(V_{on} = ', num2str(log(((U_T/200e3)/I_s) + 1) * U_T, 3), ' V, I_{on} = ', num2str(U_T/200e3, 3),' A) with U_{T} = 25 mV; I_{s} = 3 fA'])

fit_vals = polyfit(V_in_200k(find(V_in_200k < 0.4)), I_in_200k(find(V_in_200k < 0.4)), 1);
plot(linspace(0, 3, 101), fit_vals(1) .* linspace(0, 3, 101) + fit_vals(2), DisplayName=['\deltaV Transistor Dominance Fit: y = ', num2str(fit_vals(1), 3), 'x + ', num2str(fit_vals(2), 3)])

fit_vals = polyfit(V_in_200k(find(0.6 < V_in_200k & V_in_200k < 3)), I_in_200k(find(0.6 < V_in_200k & V_in_200k < 3)), 1);
plot(linspace(0, 3, 101), fit_vals(1) .* linspace(0, 3, 101) + fit_vals(2), DisplayName=['\deltaV Resistor Dominance Fit: y = ', num2str(fit_vals(1), 3), 'x + ', num2str(fit_vals(2), 3)])

title('Circuit with 200 k\Omega Resistor IV Plot')
xlabel('V_{in} (V)')
ylabel('I_{in} (A)')
legend(Location='southoutside')

% I_on vs V_on
% figure();
% hold on;
% plot(log(((U_T/120)/I_s) + 1) * U_T, U_T/120, 'x', DisplayName='(V_{on}, I_{on}) with U_{T} = 25 mV; I_{s} = 3 fA; R = 120 \Omega')
% plot(log(((U_T/10e3)/I_s) + 1) * U_T, U_T/10e3, 'x', DisplayName='(V_{on}, I_{on}) with U_{T} = 25 mV; I_{s} = 3 fA; R = 10 k\Omega')
% plot(log(((U_T/200e3)/I_s) + 1) * U_T, U_T/200e3, 'x', DisplayName='(V_{on}, I_{on}) with U_{T} = 25 mV; I_{s} = 3 fA; R = 200 k\Omega')
% xlabel('V_{on} (V)')
% ylabel('I_{on} (A)')
% legend(Location='best')

% V_on and I_on as a function of R w/ Data
R_vals = linspace(0, 1e6, 1e6);

RGB = orderedcolors("gem");
default_colors = rgb2hex(RGB);

figure();
yyaxis left
loglog(R_vals, U_T ./ R_vals)
hold on;
xlabel('Resistance in Series (R)')
ylabel('I_{on} (A)')
yyaxis right
ylabel('V_{on} (V)')
semilogx(R_vals, log(((U_T./R_vals)/I_s) + 1) .* U_T)

yyaxis left
semilogx(120, U_T/120, 'x', Color=default_colors(5), LineWidth=2)
semilogx(10e3, U_T/10e3, 'x', Color=default_colors(6),LineWidth=2)
semilogx(200e3, U_T/200e3, 'x', Color=default_colors(7), LineWidth=2)
yyaxis right
semilogx(120, log(((U_T/120)/I_s) + 1) * U_T, 'x', Color=default_colors(5), LineWidth=2)
semilogx(10e3, log(((U_T/10e3)/I_s) + 1) * U_T, 'x', Color=default_colors(6), LineWidth=2)
semilogx(200e3, log(((U_T/200e3)/I_s) + 1) * U_T, 'x', Color=default_colors(7), LineWidth=2)

title('V_{on} and I_{on} with respect to R')
legend('I_{on} = U_{T}/R Theoretical Fit', 'R = 120 \Omega', 'R = 10 k\Omega', 'R = 200 k\Omega', 'V_{on} = ln(U_{T}/R)/I_{s} + 1 Theoretical Fit', '', '', '',Location='southoutside') %[output:79d97ae6]

% V_on and I_on as a function of R w/0=o Theoretical
% figure();
% yyaxis left
% semilogx(120, log(((U_T/120)/I_s) + 1) * U_T, 'x')
% hold on;
% semilogx(10e3, log(((U_T/10e3)/I_s) + 1) * U_T, 'x')
% semilogx(200e3, log(((U_T/200e3)/I_s) + 1) * U_T, 'x')
% yyaxis right
% semilogx(120, U_T/120, 'x')
% semilogx(10e3, U_T/10e3, 'x')
% semilogx(200e3, U_T/200e3, 'x')

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":40}
%---
%[output:46c4648b]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Negative data ignored"}}
%---
%[output:79d97ae6]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Negative data ignored"}}
%---
