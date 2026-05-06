%% exp3

clear;

% base_dir = "C:\Users\etuthill\OneDrive - Olin College of Engineering\Circuits\ENGR2410-01.26SP\project\matlab\project_exp3";
base_dir = '/home/htejadaderas/Git/ENGR2420-01.26SP/project/matlab/project_exp3';

folders = dir(base_dir);
folders = folders([folders.isdir]);
folders = folders(~ismember({folders.name}, {'.','..'}));

results = table();
all_data = struct();
valid_i = 0;

for i = 1:length(folders)

    % Get File
    folder_name = folders(i).name;
    file_path = fullfile(base_dir, folder_name, 'NewFile1.csv');

    if ~exist(file_path, 'file')
        continue;
    end

    % Extract Data
    table_opts = detectImportOptions(file_path);
    table_opts.VariableNames = {'X', 'CH1', 'CH2'};
    data = readtable(file_path, table_opts);
    data_parameters = readtable(file_path, Range='D1:E2', ReadVariableNames=true);

    t = data.X .* data_parameters.Increment;

    Vin  = movmean(data.CH1, max(3, round(length(t)/200)));
    Vout = movmean(data.CH2, max(3, round(length(t)/200)));

    dt = mean(diff(t));
    dVout = gradient(Vout, dt);

    % frequency from folder name
    num = regexp(folder_name,'\d+(\.\d+)?','match');
    freq = str2double(num{1});

    if contains(folder_name,'kHz')
        freq = freq * 1e3;
    end
end

function [sharpness, swing] = sharpness_swing_calcs(Vout, dVout)
    % Output Swing and Sharpness Calculation
    swing = max(Vout) - min(Vout);
    sharpness = max(dVout);
end

function slew = slew_calcs(t, Vout, dVout, freq)
    % Slope of 10% to 90% of Output Vout Rise
    vout_min = min(Vout);
    vout_max = max(Vout);

    v10 = vout_min + 0.1*(vout_max - vout_min);
    v90 = vout_min + 0.9*(vout_max - vout_min);

    % Find Corner of Output Square Wave
    [~, rise_corners] = findpeaks(dVout, 'MinPeakHeight', max(dVout)*0.5, 'MinPeakDistance', 10);
    [~, fall_corners] = findpeaks(-dVout, 'MinPeakHeight', max(-dVout)*0.5, 'MinPeakDistance', 10);

    rise_corners = rise_corners - 1;
    fall_corners = fall_corners - 1;


end

function delay_calcs()
    % Delay between Vin and Vout when hitting threshold voltage
end