

Ammeter = Ammeter2('COM4');


clc
Feloop_fig = figure;


freq = 4;
amp = 8;

voltage_gain = 1;
voltage_divider = 1;
init_pulse = 1;

Loop_opts = loop_options('amp', amp, ...
    'gain', voltage_gain, ...
    'divider', voltage_divider, ...
    'period', 1/freq, ...
    'post', 0.0, ...
    'delay', 0.05, ...
    'refnum', 1, ...
    'init_pulse', init_pulse, ...
    'voltage_ch', 0);

Ammeter.Capacitor("150n");
feloop = hysteresis_PE_DWM3(Ammeter, Loop_opts, Feloop_fig);





% Ammeter.switch_feedback_res(1, 'low');
% Meas_period = 2;
% [time_out, current_out] = current_measure(Ammeter, Meas_period, Feloop_fig);



Ammeter.delete;

