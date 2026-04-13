

% LEGACY since V1.0.1
% 

clc
Ammeter = Ammeter2('COM3');

%%

clc

Amp = 1; % V
Period = 0.4; % s
DC_bias = 0; % V
Duty = 50; % [100%]
wf_triangle = Pulse_waveform_init(Amp, Period, DC_bias, Duty, "b", "tri", false);
wf_sin = Pulse_waveform_init(Amp, Period, DC_bias, Duty, "b", "sin", false);
wf_noise = Pulse_waveform_init(Amp, Period, DC_bias, Duty, "b", "noise", false);
wf_square = Pulse_waveform_init(Amp, Period, DC_bias, Duty, "b", "square", false);

Ammeter.send_long_cmd(201, wf_triangle);
Ammeter.send_long_cmd(201, wf_sin);
Ammeter.send_long_cmd(201, wf_noise);
Ammeter.send_long_cmd(201, wf_square);

%%

Ammeter.CMD_run_triangle;
Ammeter.CMD_run_sin;
Ammeter.CMD_run_noise;
Ammeter.CMD_run_square;

%%

Ammeter.CMD_run_triangle;

%%

Ammeter.CMD_run_sin;

%%

Ammeter.CMD_run_square;

%% WITH DATA REC

Ammeter.CMD_data_req;

Ammeter.CMD_run_triangle;
pause(2.0);
Ammeter.CMD_data_req;
pause(0.1);

[Full_time_stamp, ADC_1_voltage, ADC_2_voltage, Relay_state_byte, Device_state_byte] = Ammeter.debug_read;
time = double(Full_time_stamp)*100e-6;

figure
subplot(2, 1, 1)
plot(time, ADC_1_voltage, '.')
ylabel('ADC_1, V')
xlabel('t, s')

subplot(2, 1, 2)
plot(time, ADC_2_voltage, '.')
ylabel('ADC_2, V')
xlabel('t, s')

%% DELETE

Ammeter.delete


%% FILTER LOW

Ammeter.set_output_filter_freq('low')


%% FILTER HIGH

Ammeter.set_output_filter_freq('high')


%% RUN ALL

Ammeter.CMD_run_noise;
pause(Period*1.1)
Ammeter.CMD_run_triangle;
pause(Period*1.1)
Ammeter.CMD_run_sin;
pause(Period*1.1)
Ammeter.CMD_run_square;
