figure;

% 100 nA weak inversion
semilogy(Vin_100n, abs(Iout_100n), 'b.', 'DisplayName', '100 nA'); hold on;

% 1 uA moderate inversion
semilogy(Vin_1m,   abs(Iout_1m),   'r.', 'DisplayName', '1 uA');

% 100 uA strong inversion
semilogy(Vin_100m, abs(Iout_100m), 'g.', 'DisplayName', '100 uA');

xlabel('V_{out} (V)');
ylabel('I_{out} (A)');
title('nMOS Current Mirror Output Characteristics');
legend("Location","best")


% thresholds for region selection
Vlow = 0.02;
Vhigh_frac = 0.7;


% 100 nA weak inversion
idx_low = Vin_100n < Vlow;
Vhigh_frac = 0.9;
idx_high = Vin_100n > Vhigh_frac * max(Vin_100n);
p = polyfit(Vin_100n(idx_low), abs(Iout_100n(idx_low)), 1);
ron_100n = 1 / p(1);

p = polyfit(Vin_100n(idx_high), Iout_100n(idx_high), 1);
ro_100n = 1 / p(1);

VA_100n = ro_100n * Iin_100n;
gain_100n = ro_100n / ron_100n;


% 1 uA moderate inversion
idx_low = Vin_1m < Vlow;
Vhigh_frac = 0.9;
idx_high = Vin_100n > Vhigh_frac * max(Vin_100n);
p = polyfit(Vin_1m(idx_low), Iout_1m(idx_low), 1);
ron_1m = 1 / p(1);

p = polyfit(Vin_1m(idx_high), Iout_1m(idx_high), 1);
ro_1m = 1 / p(1);

VA_1m = ro_1m * Iin_1m;
gain_1m = ro_1m / ron_1m;


% 100 uA strong inversion
idx_low = Vin_100m < Vlow;
Vhigh_frac = 0.9;
idx_high = Vin_100n > Vhigh_frac * max(Vin_100n);
p = polyfit(Vin_100m(idx_low), Iout_100m(idx_low), 1);
ron_100m = 1 / p(1);

p = polyfit(Vin_100m(idx_high), Iout_100m(idx_high), 1);
ro_100m = 1 / p(1);

VA_100m = ro_100m * Iin_100m;
gain_100m = ro_100m / ron_100m;


table( ...
    [Iin_100n; Iin_1m; Iin_100m], ...
    [ron_100n; ron_1m; ron_100m], ...
    [ro_100n; ro_1m; ro_100m], ...
    [VA_100n; VA_1m; VA_100m], ...
    [gain_100n; gain_1m; gain_100m], ...
    'VariableNames', {'Iin','ron','ro','VA','gain'})