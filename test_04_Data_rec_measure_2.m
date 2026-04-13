

% TEST FOR MEASUREMENT



%%


Ammeter = Dahlia('COM3');

clc
figure('Position', [526.0000  360.5000  560.0000  420.0000])



Amp = 1.0; % V
Period = 50.0; % s
DC_bias = 0; % V
Duty = 50; % [100%]
wf_gen = Pulse_waveform_init(Amp, Period, DC_bias, Duty, "b", "tri", true);
Ammeter.send_long_cmd(201, wf_gen);



if Period >= 1
    Ammeter.set_output_filter_freq('low');
else
    Ammeter.set_output_filter_freq('high');
end
Ammeter.set_input_ch_direction('internal');

Ammeter.switch_feedback_res(0, 'low');
Ammeter.enable_feedback(1);
pause(3);

Ammeter.CMD_TS_reset;
Ammeter.CMD_data_stream(true);
pause(0.1);
% Ammeter.CMD_run_sin;
Ammeter.CMD_run_triangle;
Ammeter.DAC_set_voltage(0);

Meas_period = Period*2.1;
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
    yline(0)
%     title([num2str(mtime, '%.1f') ' / ' num2str(Meas_period, '%.1f')])

    subplot(2,1,2)
    cla
    plot(time_arr, signal_arr*1e12)
%     yline(0)
%     title([num2str(mtime, '%.1f') ' / ' num2str(Meas_period, '%.1f')])
    drawnow

    if ~isempty(Device_state_byte) && Device_state_byte(end) == 0
%         stop = true;
    end

end

Ammeter.enable_feedback(0);
Ammeter.CMD_data_stream(false);
Ammeter.flush_data;
Ammeter.delete;


%%

voltage_arr_f = filter(Filter_LP_5Hz, voltage_arr);
signal_arr_f = filter(Filter_LP_5Hz, signal_arr);

figure
hold on
plot(time_arr, voltage_arr, 'b')
plot(time_arr, voltage_arr_f, 'r', 'linewidth', 1.5)
yline(0)



%%

figure


subplot(2,1,1)
hold on
plot(time_arr, voltage_arr, 'b')
plot(time_arr, voltage_arr_f, 'r', 'linewidth', 1.5)
yline(0)


subplot(2,1,2)
hold on
plot(time_arr, signal_arr*1e12, 'b')
plot(time_arr, signal_arr_f*1e12, 'r', 'linewidth', 1.5)
yline(0)










