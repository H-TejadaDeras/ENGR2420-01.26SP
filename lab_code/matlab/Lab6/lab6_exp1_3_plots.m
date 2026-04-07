load("lab6_exp1_data.mat")
load("lab6_exp3_data.mat")

figure
plot(V1_25dV_15dV, V_out_25dV_15dV,'.-',"LineWidth",1.5,"MarkerSize",10)
hold on
plot(V1_35dV_15dV, V_out_35dV_15dV,'.-',"LineWidth",1.5,"MarkerSize",10)
plot(V1_45dV_15dV, V_out_45dV_15dV,'.-',"LineWidth",1.5,"MarkerSize",10)

xlabel('V1 (V)')
ylabel('Vout (V)')
title('Differential Amplifier VTC (Strong Inversion)')
legend('V2 = 2.5 V','V2 = 3.5 V','V2 = 4.5 V',"Location","best")

figure
plot(V1_25dV_625mV, V_out_25dV_625mV,'.-',"LineWidth",1.5,"MarkerSize",10)
hold on
plot(V1_35dV_625mV, V_out_35dV_625mV,'.-',"LineWidth",1.5,"MarkerSize",10)
plot(V1_45dV_625mV, V_out_45dV_625mV,'.-',"LineWidth",1.5,"MarkerSize",10)

xlabel('V1 (V)')
ylabel('Vout (V)')
title('Differential Amplifier VTC (Weak/Moderate Inversion)')
legend('V2 = 2.5 V','V2 = 3.5 V','V2 = 4.5 V',"Location","best")

%% exp 3
figure
plot(V_in_15dV, V_out_15dV,'.',"MarkerSize",8)
hold on

idx = V_in_15dV >= 0.5 & V_in_15dV <= 4.2;

p = polyfit(V_in_15dV(idx), V_out_15dV(idx),1);

plot(V_in_15dV, polyval(p,V_in_15dV),"LineWidth",1.5)

xlabel('Vin (V)')
ylabel('Vout (V)')
title('Unity Gain Follower')
legend('Measured data','Best-fit line',"Location","best")

gain = p(1);
txt = sprintf('Gain = %.3f', gain);
text(0.6, max(V_out_15dV)-0.2, txt, "FontSize",12)