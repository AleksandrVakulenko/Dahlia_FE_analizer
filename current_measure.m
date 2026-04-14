


function [time_out, current_out] = current_measure(Ammeter, Meas_period, fig)

Ammeter.switch_feedback_res(0, 'low');
% pause(1.0)
Current_to_switch = 550e-12;
flag = false;

Draw_obj = FE_loop_utils.DWM_graph(fig);
Draw_obj.add_new_and_shadow_prev('r', '-', 1.2);

Ammeter.enable_feedback(1);
pause(0.1)
Ammeter.CMD_TS_reset;
Ammeter.CMD_data_req;

Device_state_byte = [];
timer = tic;
stop = false;
voltage_arr = [];
signal_arr = [];
time_arr = [];
while ~stop
    mtime = toc(timer);

    try
        [time, voltage, signal, Unit, ~, ~] = Ammeter.high_level_read;
        voltage_arr = [voltage_arr voltage(1:1:end)];
        signal_arr = [signal_arr signal(1:1:end)];
        time_arr = [time_arr time(1:1:end)];
    catch e
        Unit = "-";
%         disp(['Error: ' e.message])
    end
    
    if flag
        if mtime > 0.5
            if mean(signal_arr) < Current_to_switch
                Ammeter.switch_feedback_res(0, 'low');
                flag = false;
                disp('Switched to lower range')
            end
        end
    end

    Unit = char(Unit(end));
    switch Unit
        case "A"
            y_unit = "I, A";
        case "C"
            y_unit = "q, C";
        case "-"
            y_unit = "-";
    end

    Draw_obj.update_last(time_arr, signal_arr);
    xlabel('t, s');
    ylabel(y_unit);
%     ylim([-6e-9 6e-9])
    set(gca,'yscale','log')
    drawnow


    if mtime > Meas_period
        stop = true;
    end
end

Ammeter.CMD_data_req;
Ammeter.flush_data();
Ammeter.enable_feedback(0);
Draw_obj.gray_all;

time_out = time_arr;
current_out = signal_arr;

end















