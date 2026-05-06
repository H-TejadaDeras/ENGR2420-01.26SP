clear;
close all;

folder_name = '5 kHz';
%file_path = '/home/htejadaderas/Git/ENGR2420-01.26SP/project/matlab/project_exp3/1 kHz/NewFile1.csv';
file_path = 'C:\Users\etuthill\OneDrive - Olin College of Engineering\Circuits\ENGR2410-01.26SP\project\matlab\project_exp3\200 Hz\NewFile1.csv';

table_opts = detectImportOptions(file_path);
table_opts.VariableNames = {'X', 'CH1', 'CH2'};
data = readtable(file_path, table_opts);
data_parameters = readtable(file_path, Range='D1:E2', ReadVariableNames=true);

t = data.X .* data_parameters.Increment - data_parameters.Start;

Vin  = movmean(data.CH1, max(3, round(length(t)/200)));
Vout = movmean(data.CH2, max(3, round(length(t)/200)));

dt = mean(diff(t));
dVout = gradient(Vout, dt);
ddVout = gradient(dVout, dt);
% frequency from folder name
num = regexp(folder_name,'\d+(\.\d+)?','match');
freq = str2double(num{1});

if contains(folder_name,'kHz')
    freq = freq * 1e3;
end

%     % Slope of 10% to 90% of Output Vout Rise
%     vout_min = min(Vout);
%     vout_max = max(Vout);
% 
%     v10 = vout_min + 0.1*(vout_max - vout_min);
%     v90 = vout_min + 0.9*(vout_max - vout_min);
% 
% 
% % TMP
%     figure()
%     plot(t, Vin)
%     hold on;
%     plot(t, Vout)
%     ddVout = gradient(dVout, dt);
%     dddVout = gradient(ddVout, dt);
% 
%     figure()
%     hold on
%     plot(t, Vout * 10^5)
%     %plot(t, dVout)
%     %plot(t, ddVout/10^8)
%     plot(t, abs(ddVout/10^6))
%     %plot(t, dddVout/10^13)
%     legend('vout', '2 diff')
% 
% 
% 
% 
% 
%     % Find peaks in second derivative (these correspond to edges)
% 
%     ddVout_abs = abs(ddVout);
%     ddVout_clean = smoothdata(abs(ddVout_abs), 'gaussian', 10);
%     [~, peak_idx] = findpeaks(ddVout_clean, 'MinPeakProminence', 0.1 * max(ddVout_clean));
% 
%     % If negative first, then fall; if positive first then rise
% 
% 
%  % state flags
% flag_rise = false;
% flag_fall = false;
% 
% % arrays for rise and fall intervals
% start_rise = [];
% end_rise   = [];
% 
% start_fall = [];
% end_fall   = [];
% 
% % Midpoint voltage (used to decide if in upper or lower half)
% v_mid = (vout_max + vout_min) / 2;
% 
% for i = 1:length(peak_idx)
%     idx = peak_idx(i);
% 
%     % falling
% 
%     % If slope is negative then signal is going down
%     if dVout(idx) < 0
% 
%         % Start of falling edge:
%         % must be in upper half of waveform AND not already in a fall
%         if ~flag_fall && Vout(idx) > v_mid
%             start_fall(end+1) = t(idx);
%             flag_fall = true;
% 
%         % End of falling edge:
%         % must have moved into lower half of waveform
%         elseif flag_fall && Vout(idx) < v_mid
%             end_fall(end+1) = t(idx);
%             flag_fall = false;
%         end
%     end
% 
%     % rising
% 
%     % If slope is positive then signal is going up
%     if dVout(idx) > 0
% 
%         % Start of rising edge:
%         % must be in lower half AND not already rising
%         if ~flag_rise && Vout(idx) < v_mid
%             start_rise(end+1) = t(idx);
%             flag_rise = true;
% 
%         % End of rising edge:
%         % must reach upper half
%         elseif flag_rise && Vout(idx) > v_mid
%             end_rise(end+1) = t(idx);
%             flag_rise = false;
%         end
%     end
% end
% 
% 
% figure();
% plot(t, Vout);
% hold on;
% 
% for i = 1:length(start_rise)
%     xline(start_rise(i), 'g--'); % start of rise
%     xline(end_rise(i), 'g-'); % end of rise
% end
% 
% for i = 1:length(start_fall)
%     xline(start_fall(i), 'r--'); % start of fall
%     xline(end_fall(i), 'r-'); % end of fall
% end



% Slope of 10% to 90% of Output Vout Rise
vout_min = min(Vout);
vout_max = max(Vout);
v10 = vout_min + 0.1*(vout_max - vout_min);
v90 = vout_min + 0.9*(vout_max - vout_min);

% TMP
figure()
plot(t, Vin)
hold on;
plot(t, Vout)
legend('Vin', 'Vout')

% arrays for rise and fall idx
start_rise = [];
end_rise   = [];
start_fall = [];
end_fall   = [];

% find initial state based on first data point
v_mid = (vout_max + vout_min) / 2;
if Vout(1) < v_mid
    flag_state = 'low';
else
    flag_state = 'high';
end

for i = 2:length(t)
    % Look for start of fall- Crossing v90 downwards
    if strcmp(flag_state, 'high') && Vout(i) < v90 && Vout(i-1) >= v90
        start_fall(end+1) = t(i);
        flag_state = 'falling';
        
    % Look for end of fall - Crossing v10 downwards
    elseif strcmp(flag_state, 'falling') && Vout(i) < v10 && Vout(i-1) >= v10
        end_fall(end+1) = t(i);
        flag_state = 'low';
        
    % Look for start of rise - Crossing v10 upwards
    elseif strcmp(flag_state, 'low') && Vout(i) > v10 && Vout(i-1) <= v10
        start_rise(end+1) = t(i);
        flag_state = 'rising';
        
    % Look for end of rise - Crossing v90 upwards
    elseif strcmp(flag_state, 'rising') && Vout(i) > v90 && Vout(i-1) <= v90
        end_rise(end+1) = t(i);
        flag_state = 'high';
    end
end


figure();
plot(t, Vout, 'LineWidth', 1.5);
hold on;


for i = 1:length(start_rise)
    xline(start_rise(i), 'g--'); % start of rise
    xline(end_rise(i), 'g-'); % end of rise
end
for i = 1:length(start_fall)
    xline(start_fall(i), 'r--'); % start of fall
    xline(end_fall(i), 'r-'); % end of fall
end