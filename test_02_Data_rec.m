
% TEST FOR INPUT SIGNALS

% TEST FOR DATA INTEGRITY
% 2024.07.23 PASSED for 16 kSPS
% 2024.07.24 NOT PASSED for 16 kSPS with wfgen
clc
Ammeter = Ammeter2('COM3');


%%

Ammeter.delete


%% CAP

clc
Ammeter.switch_feedback_res(1, 'low');
% Ammeter.switch_feedback_cap(0, 1);

Ammeter.cap_short(0);
Ammeter.enable_feedback(1);
pause(1.02)

Ammeter.CMD_data_req;
% pause(10.0);
Timer = tic;
Period = 10; % s
time = toc(Timer);
while time < Period
    time = toc(Timer);
    disp([num2str(time, '%0.1f') ' / ' num2str(Period, '%0.1f') ' s'])
end
Ammeter.CMD_data_req;

Ammeter.enable_feedback(0);
Ammeter.cap_short(1);


disp('READY')

%% RES

clc
Ammeter.set_input_ch_direction('external');
Ammeter.switch_feedback_res(1, 'high');

Ammeter.enable_feedback(1);
pause(2)

Ammeter.CMD_data_req;
Timer = tic;
Period = 30; % s
time = toc(Timer);
while time < Period
    time = toc(Timer);
    disp([num2str(time, '%0.1f') ' / ' num2str(Period, '%0.1f') ' s'])
end
Ammeter.CMD_data_req;

Ammeter.enable_feedback(0);



disp('READY')

%%

[time, ADC_1_voltage, ADC_2_voltage, Unit, Relay_state, Device_state_byte] = Ammeter.high_level_read;


%%

time_clk = time/100e-6;
figure
plot(time_clk(1:end-1) - time_clk(1), diff(time_clk), '.-', 'MarkerEdgeColor', 'r')

figure
title('queue cap')
plot(time - time(1), Device_state_byte)
ylim([0 max(Device_state_byte)+3])
ylabel('capacity')
xlabel('t, s')


%%
figure
plot(time, ADC_1_voltage, '.')
figure
plot(time, ADC_2_voltage, '.')


%% FILTER form 10 GOhm
load('Filter_50Hz.mat')
signal = ADC_1_voltage/10e9*1e15;
Level_shift = mean(signal(1:round(end/10)));
signal_f = filter(Filter_50Hz, signal-Level_shift);
signal_f = signal_f + Level_shift;

time = time - time(1);


hold on
% plot(time, signal, '.b')
plot(time, signal_f, '.r')

ylabel('I, fA')
xlabel('t, s')

%%



figure
hold on
% plot(time - time(1), 1e6*(movmean(ADC_1_voltage, 1) - mean(ADC_1_voltage)), '.-');
% plot(time, ADC_1_voltage, '.-');
plot(time, 1e0*movmean(ADC_2_voltage, 1));











