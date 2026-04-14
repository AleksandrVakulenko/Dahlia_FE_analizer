
% LEGACY TEST FOR DIODE I-V CURVE


clc
Ammeter = Dahlia('COM3');

%%



Amp = 0.25; % V
Period = 10; % s
DC_bias = 0; % V
Duty = 50; % [100%]
wf_triangle = Pulse_waveform_init(Amp, Period, DC_bias, Duty, "positive", "sin", false);
Ammeter.send_long_cmd(201, wf_triangle);



%% WITH DATA REC

Ammeter.set_output_filter_freq('low');
pause(0.2);

Ammeter.switch_feedback_res(1, 'low');
% Ammeter.set_output_filter_freq('low');
Ammeter.enable_feedback(1);
% Ammeter.CMD_auto_range(0);

Ammeter.CMD_data_req;

pause(1);
Ammeter.CMD_run_sin;
pause(Period+0.1);
Ammeter.CMD_data_req;
pause(0.1);

% Ammeter.CMD_auto_range(0);
Ammeter.enable_feedback(0);



[time, voltage, signal, Unit, Relay_state, Device_state_byte] = Ammeter.high_level_read;
% [Full_time_stamp, signal, voltage, Relay_state_byte, Device_state_byte] = Ammeter.debug_read;
% time = double(Full_time_stamp)*100e-6;

figure
subplot(2, 1, 1)
plot(time, signal, '.')
ylabel(['Signal, ' char(Unit(1))])
xlabel('t, s')

subplot(2, 1, 2)
plot(time, voltage, '.')
ylabel('Voltage, V')
xlabel('t, s')

% voltage = filt_LP_0_5Hz(voltage);
% signal = filt_LP_0_5Hz(signal);

figure
plot(voltage, signal, '.')
ylabel(['Signal, ' char(Unit(1))])
xlabel('Voltage, V')
xline(0)
yline(0)
grid on
box on


%%

voltage = filt_LP_0_5Hz(voltage);
signal = filt_LP_0_5Hz(signal);

plot(voltage, signal, '.')
ylabel(['Signal, ' char(Unit(1))])
xlabel('Voltage, V')
xline(0)
yline(0)
grid on
box on


function signal_f = filt_50Hz(signal)
load('test_dahlia\Filter_50Hz.mat')
Level_shift = mean(signal(1:round(end/10)));
signal_f = filter(Filter_50Hz, signal-Level_shift);
signal_f = signal_f + Level_shift;
end

function signal_f = filt_LP_0_5Hz(signal)
load('test_dahlia\Filter_LP_0_5Hz.mat')
Level_shift = mean(signal(1:round(end/10)));
signal_f = filter(Filter_LP_0_5Hz, signal-Level_shift);
signal_f = signal_f + Level_shift;
end



