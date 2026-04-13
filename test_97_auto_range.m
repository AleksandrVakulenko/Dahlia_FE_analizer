
% LEGACY
% TEST FOR UNRELEASET AUTO-RANGE FUNCTION

clc
Ammeter = Ammeter2('COM3');

%%
Ammeter.CMD_data_req;
Ammeter.CMD_auto_range(1);
pause(0.5)
Ammeter.CMD_auto_range(0);
Ammeter.CMD_data_req;
%%



%% WITH DATA REC

Ammeter.switch_feedback_res(0, 'low');

Ammeter.enable_feedback(1);
Ammeter.cap_short(0);
Ammeter.CMD_data_req;

pause(2);
Ammeter.switch_feedback_res(1, 'high')
pause(2);
Ammeter.switch_feedback_res(2, 'high')
pause(2);
Ammeter.switch_feedback_res(3, 'high')
pause(2);

Ammeter.CMD_data_req;
Ammeter.cap_short(1);
Ammeter.enable_feedback(0);


pause(0.05);
%%
[Full_time_stamp, ADC_1_voltage, ADC_2_voltage, Relay_state_byte, Device_state_byte] = Ammeter.debug_read;
time = double(Full_time_stamp)*100e-6;

% ADC_1_voltage = filt_50Hz(ADC_1_voltage);
% ADC_2_voltage = filt_50Hz(ADC_2_voltage);

figure
subplot(2, 1, 1)
plot(time, ADC_1_voltage, '.')
ylabel('ADC_1, V')
xlabel('t, s')

subplot(2, 1, 2)
plot(time, ADC_2_voltage, '.')
ylabel('ADC_2, V')
xlabel('t, s')






%%


Ammeter.delete;



%%

function signal_f = filt_50Hz(signal)
load('Filter_50Hz.mat')
Level_shift = mean(signal(1:round(end/10)));
signal_f = filter(Filter_50Hz, signal-Level_shift);
signal_f = signal_f + Level_shift;
end










