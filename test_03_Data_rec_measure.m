

% TEST FOR MEASUREMENT


clc
clear

Meas_period = 4;

figure('Position', [526.0000  360.5000  560.0000  420.0000])


Ammeter = Dahlia('COM3');

Amp = 0.25; % V
Period = 2.0; % s
DC_bias = 0; % V
Duty = 50; % [100%]
wf_triangle = Pulse_waveform_init(Amp, Period, DC_bias, Duty, "b", "sine", false);
Ammeter.send_long_cmd(201, wf_triangle);

Ammeter.set_input_ch_direction('internal');
Ammeter.switch_feedback_res(0, 'low');

% Ammeter.enable_feedback(1);
% Ammeter.CMD_data_req;
% Ammeter.CMD_run_sin;
Ammeter.CMD_measurement_run;
pause(0.005)

Device_state_byte = [];
timer = tic;
stop = false;
voltage_arr = [];
signal_arr = [];
time_arr = [];
while ~stop
    mtime = toc(timer);
    if mtime > Meas_period
        stop = true;
    end

    try
        [time, voltage, signal, Unit, Relay_state, Device_state_byte] = Ammeter.high_level_read;
        voltage_arr = [voltage_arr voltage(1:1:end)];
        signal_arr = [signal_arr signal(1:1:end)];
        time_arr = [time_arr time(1:1:end)];
    catch e
        beep
        disp('no data')
        disp(['Error: ' e.message])
    end

    subplot(2,1,1)
    cla
    plot(time_arr, voltage_arr)
%     yline(0)
%     title([num2str(mtime, '%.1f') ' / ' num2str(Meas_period, '%.1f')])

    subplot(2,1,2)
    cla
    plot(time_arr, signal_arr)
%     yline(0)
%     title([num2str(mtime, '%.1f') ' / ' num2str(Meas_period, '%.1f')])
    drawnow

    if ~isempty(Device_state_byte) && Device_state_byte(end) == 0
        stop = true;
    end

end

Ammeter.flush_data;
Ammeter.delete;









