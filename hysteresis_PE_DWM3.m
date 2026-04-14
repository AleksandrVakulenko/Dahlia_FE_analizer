%FIXME: ADD SAMPLE STRUCT

function feloop = hysteresis_PE_DWM3(ammeter_obj, Loop_opts, fig, inverse)
amp = Loop_opts.amp;
period = Loop_opts.period;
post_period = Loop_opts.post_period;
gain = Loop_opts.gain;
divider = Loop_opts.divider;
delay = Loop_opts.delay; %s
refnum = Loop_opts.refnum;
init_pulse = Loop_opts.init_pulse;
voltage_ch = Loop_opts.voltage_ch;

obj = ammeter_obj;

WF_str.amp = amp/gain;
WF_str.period = period;
WF_str.type = 'sin';


% % FIXME: add pulse train mode to box
% obj.set_post_period(post_period);

switch voltage_ch
    case 1
        obj.set_input_ch_direction('external');
    case 0
        obj.set_input_ch_direction('internal');
    otherwise
        % FIXME: add reinit_CMD
        obj.delete;
        error('Wrong "voltage_ch" value in Loop_options')
end

Draw_obj = FE_loop_utils.DWM_graph(fig);
draw_cmd = true;

if ~inverse
    init_pol = 'negative';
else
    init_pol = 'positive';
end

switch init_pulse
    case 1
        set_waveform(obj, WF_str, init_pol);
        measure_part(obj, draw_cmd, amp, Draw_obj, divider); % UPDATE
        pause(delay)
    case 0
        % nothing to do here
    otherwise
        % FIXME: add reinit_CMD
        obj.delete;
        error('Wrong "voltage_ch" value in Loop_options')
end


feloop = struct;

if ~inverse
    feloop = measure_pos_part(obj, WF_str, draw_cmd, amp, Draw_obj, divider, delay, refnum, feloop);
    feloop = measure_neg_part(obj, WF_str, draw_cmd, amp, Draw_obj, divider, delay, refnum, feloop);
else
    feloop = measure_neg_part(obj, WF_str, draw_cmd, amp, Draw_obj, divider, delay, refnum, feloop);
    feloop = measure_pos_part(obj, WF_str, draw_cmd, amp, Draw_obj, divider, delay, refnum, feloop);
end




Draw_obj.gray_all;
% feloop = align_sizes(feloop);

end


function feloop = measure_pos_part(obj, WF_str, draw_cmd, amp, Draw_obj, divider, delay, refnum, feloop)

set_waveform(obj, WF_str, 'positive')
[E_part, P_part] = measure_part(obj, draw_cmd, amp, Draw_obj, divider); % UPDATE
feloop.init.E.p = E_part;
feloop.init.P.p = P_part;
pause(delay)

set_waveform(obj, WF_str, 'positive')
[E_part, P_part] = measure_part(obj, draw_cmd, amp, Draw_obj, divider); % UPDATE
feloop.ref.E.p = E_part;
feloop.ref.P.p = P_part;
pause(delay)

if refnum > 1
    for rn = 1:refnum-1
        set_waveform(obj, WF_str, 'positive')
        [E_part, P_part] = measure_part(obj, draw_cmd, amp, Draw_obj, divider); % UPDATE
        feloop.refnext(rn).E.p = E_part;
        feloop.refnext(rn).P.p = P_part;
        pause(delay)
    end
end

end


function feloop = measure_neg_part(obj, WF_str, draw_cmd, amp, Draw_obj, divider, delay, refnum, feloop)

set_waveform(obj, WF_str, 'negative')
[E_part, P_part] = measure_part(obj, draw_cmd, amp, Draw_obj, divider); % UPDATE
feloop.init.E.n = E_part;
feloop.init.P.n = P_part;
pause(delay)

set_waveform(obj, WF_str, 'negative')
[E_part, P_part] = measure_part(obj, draw_cmd, amp, Draw_obj, divider); % UPDATE
feloop.ref.E.n = E_part;
feloop.ref.P.n = P_part;
pause(delay)

if refnum > 1
    for rn = 1:refnum-1
        set_waveform(obj, WF_str, 'negative')
        [E_part, P_part] = measure_part(obj, draw_cmd, amp, Draw_obj, divider); % UPDATE
        feloop.refnext(rn).E.n = E_part;
        feloop.refnext(rn).P.n = P_part;
        pause(delay)
    end
end

end


function [E_part, P_part, time] = measure_part(Ammeter, draw_cmd, amp, Draw_obj, divider)

Draw_obj.add_new_and_shadow_prev('r', '-', 1.2);

Ammeter.CMD_measurement_run;
pause(0.05)

Device_state_byte = [];
voltage_arr = [];
signal_arr = [];
time_arr = [];
stop = false;
while ~stop


    try
        [time, voltage, signal, Unit, Relay_state, Device_state_byte] = Ammeter.high_level_read;
        voltage_arr = [voltage_arr voltage(1:1:end)*divider];
        signal_arr = [signal_arr signal(1:1:end)];
        time_arr = [time_arr time(1:1:end)];
    catch e
        Unit = "-";
%         disp(['Error: ' e.message])
    end


    if ~isempty(Device_state_byte) && Device_state_byte(end) == 0
        stop = true;
    end

    Unit = char(Unit(end));

    % y-units
    switch Unit
        case "A"
            y_unit = "I, A";
        case "C"
            y_unit = "q, C";
    end

    if draw_cmd
        Draw_obj.update_last(voltage_arr, signal_arr);
        xlim([-amp*1.1 amp*1.1]);
        xlabel('voltage, V');
        ylabel(y_unit);
        drawnow
    end

end

E_part = voltage_arr;
P_part = signal_arr;
time = time_arr;

% disp([num2str(numel(E_part))])

end


function set_waveform(Ammeter, WF_str, polarity)
Duty = 50;
wf_gen = FE_loop_utils.Pulse_waveform_init(WF_str.amp, WF_str.period, 0, Duty, polarity, WF_str.type, false);
Ammeter.send_long_cmd(201, wf_gen);

end




