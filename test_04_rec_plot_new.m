



Meas_period = 5;

figure


Ammeter = Ammeter2('COM9');
pause(0.1)
Amp = 0.25; % V
Period = 2; % s
DC_bias = 0; % V
Duty = 50; % [100%]
wf_triangle = Pulse_waveform_init(Amp, Period, DC_bias, Duty, "b", "sine", false);
Ammeter.send_long_cmd(201, wf_triangle);
pause(0.1)


Ammeter.switch_feedback_res(2, 'low');
Ammeter.enable_feedback(1);
Ammeter.CMD_TS_reset;
Ammeter.CMD_data_stream(true);
Ammeter.CMD_run_sin;

timer = tic;
stop = false;
voltage_arr = [];
signal_arr = [];
Dev_state = [];
time_arr = [];
while ~stop
    mtime = toc(timer);
    if mtime > Meas_period
        stop = true;
    end

    try
    
    [time, voltage, signal, Relay_state, Device_state_byte] = Ammeter.high_level_read;

    voltage_arr = [voltage_arr voltage(1:5:end)];
    signal_arr = [signal_arr signal(1:5:end)];
    Dev_state = [Dev_state Device_state_byte];
    time_arr = [time_arr time(1:5:end)];
    catch
        disp('no data')
    end
    timer2 = tic;
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

    disp(1/toc(timer2));
end

Ammeter.CMD_data_stream(false);
Ammeter.enable_feedback(0);
Ammeter.delete;









