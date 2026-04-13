
% PASSED for V1.0.1

%%

clc
Ammeter = Ammeter2('COM3');


%%

Ammeter.switch_feedback_cap(3, 0);
Ammeter.cap_short(0);
pause(0.5)
Ammeter.CMD_cap_reset;
pause(0.5)
Ammeter.cap_short(1);
Ammeter.re_init_relays;

%%
Ammeter.delete



%%
clc
pause(0.5)
Ammeter.set_input_ch_direction('external');
Relay_state = Ammeter.CMD_get_relay_state()
pause(0.5);
Ammeter.set_input_ch_direction('internal');
Relay_state = Ammeter.CMD_get_relay_state()

pause(0.5)

Ammeter.set_output_filter_freq('low');
Relay_state = Ammeter.CMD_get_relay_state()
pause(0.5);
Ammeter.set_output_filter_freq('high');
Relay_state = Ammeter.CMD_get_relay_state()

%%

clc
Ammeter.enable_feedback(1);
Relay_state = Ammeter.CMD_get_relay_state()
pause(0.5)

Ammeter.enable_feedback(0);
Relay_state = Ammeter.CMD_get_relay_state()


%%

period = 0.25;

clc
Ammeter.switch_feedback_res(0, 'low');
pause(period);
Ammeter.switch_feedback_res(1, 'low');
pause(period);
Ammeter.switch_feedback_res(2, 'low');
pause(period);
Ammeter.switch_feedback_res(3, 'low');
pause(period);

Ammeter.switch_feedback_res(0, 'high');
pause(period);
Ammeter.switch_feedback_res(1, 'high');
pause(period);
Ammeter.switch_feedback_res(2, 'high');
pause(period);
Ammeter.switch_feedback_res(3, 'high');
pause(period);


%%
period = 0.25;

clc
Ammeter.switch_feedback_cap(0, 1);
pause(period);
Ammeter.switch_feedback_cap(1, 1);
pause(period);
Ammeter.switch_feedback_cap(2, 1);
pause(period);
Ammeter.switch_feedback_cap(3, 1);
pause(period);

Ammeter.switch_feedback_cap(0, 0);
pause(period);
Ammeter.switch_feedback_cap(1, 0);
pause(period);
Ammeter.switch_feedback_cap(2, 0);
pause(period);
Ammeter.switch_feedback_cap(3, 0);
pause(period);



%%
clc
Ammeter.cap_short(1);
Relay_state = Ammeter.CMD_get_relay_state()
pause(0.1);
Ammeter.cap_short(0);
Relay_state = Ammeter.CMD_get_relay_state()

%%

clc
Ammeter.re_init_relays
Relay_state = Ammeter.CMD_get_relay_state()


%%

Ammeter.res_range_higher();

%%

Ammeter.res_range_lower();






