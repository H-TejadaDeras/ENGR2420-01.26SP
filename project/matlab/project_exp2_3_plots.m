%% exp2

% base_dir = "C:\Users\etuthill\OneDrive - Olin College of Engineering\Circuits\ENGR2410-01.26SP\project\matlab\project_exp2";
base_dir = '/home/htejadaderas/Git/ENGR2420-01.26SP/project/matlab/project_exp2';
folder_name = "sine_5Hz";
file_path = fullfile(base_dir, folder_name, "NewFile1.csv");

% Extract Data
table_opts = detectImportOptions(file_path);
table_opts.VariableNames = {'X', 'CH1', 'CH2'};
data = readtable(file_path, table_opts);
data_parameters = readtable(file_path, Range='D1:E2', ReadVariableNames=true);

t = data.X .* data_parameters.Increment;

% Smooth Out Data and Find Corners of Square Waves
Vin  = movmean(data.CH1, 5);
Vout = movmean(data.CH2, 5);

dt = mean(diff(t));
dVout = gradient(Vout, dt);

[~, rise_corners] = findpeaks(dVout, 'MinPeakHeight', max(dVout)*0.5, 'MinPeakDistance', 10);
[~, fall_corners] = findpeaks(-dVout, 'MinPeakHeight', max(-dVout)*0.5, 'MinPeakDistance', 10);

% Calculate Output Swing and Swing Sharpness Calculations
[sharpness, swing] = sharpness_swing_calcs(Vout, dVout);

% Determine Area of Analysis
idx_edge = rise_corners(1);
win_len = 100;
zoom_idx = max(1, idx_edge - win_len) : min(length(t), idx_edge + win_len);

% Slew Rate Calculation
figure()

narrow_idx = max(1, idx_edge - 15) : min(length(t), idx_edge + 15);

h1 = plot(t(narrow_idx), Vout(narrow_idx), 'k.-', 'LineWidth', 1.5); hold on;

plot([t(narrow_idx(1)) t(narrow_idx(end))],[v10 v10],'b-','HandleVisibility','off');
plot([t(narrow_idx(1)) t(narrow_idx(end))],[v90 v90],'r-','HandleVisibility','off');

vseg_p = Vout(narrow_idx);
tseg_p = t(narrow_idx);

i10_p = find(vseg_p >= v10, 1, 'first');
i90_p = find(vseg_p >= v90, 1, 'first');

t10_p = tseg_p(i10_p-1) + (v10 - vseg_p(i10_p-1))*(tseg_p(i10_p)-tseg_p(i10_p-1))/(vseg_p(i10_p)-vseg_p(i10_p-1));
t90_p = tseg_p(i90_p-1) + (v90 - vseg_p(i90_p-1))*(tseg_p(i90_p)-tseg_p(i90_p-1))/(vseg_p(i90_p)-vseg_p(i90_p-1));

h2 = plot(t10_p, v10, 'bo', 'MarkerFaceColor','b');
h3 = plot(t90_p, v90, 'ro', 'MarkerFaceColor','r');

t_slew = linspace(t10_p, t90_p, 10);
v_slew = linspace(v10, v90, 10);

h4 = plot(t_slew, v_slew, 'm-', 'LineWidth', 2);

legend([h1 h2 h3 h4], {'Vout','t10','t90','Slew Rate Fit'}, 'Location','best');


function [sharpness, swing] = sharpness_swing_calcs(Vout, dVout)
    % Output Swing and Sharpness Calculation
    swing = max(Vout) - min(Vout);
    sharpness = max(dVout);
end