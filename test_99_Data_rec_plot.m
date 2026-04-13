

% LEGACY (DONT WORK)

Voltage_array = [-10:0.1:10 0];


figure
Time_g = [];
ADC_2_g = [];
Voltage_target = [];

Ammeter.flush_data;
Ammeter.CMD_data_req;

Period = 100;
stop = 0;
Timer = tic;
k = 0;
while(~stop)
    Time_passed = toc(Timer);
    k = k + 1;

    if k <= numel(Voltage_array)
        V_ref = 10; %V
        voltage_code = floor(Voltage_array(k)/V_ref*2^15);
        Ammeter.DAC_set_voltage(voltage_code);
    else
        stop = 1;
    end
    
    
    if ~stop
        pause(0.05)
        [~] = Ammeter.debug_read;
        pause(0.05)
        [time, voltage, ADC_2_voltage, Unit, Relay_state, Device_state_byte] = Ammeter.high_level_read;
        Time_g = [Time_g time];
        ADC_2_g = [ADC_2_g ADC_2_voltage];
        Voltage_target = [Voltage_target repmat(Voltage_array(k), 1, numel(ADC_2_voltage))];
    end

    cla
    plot(Time_g, 1e6*movmean(ADC_2_g, 100));
    yline(0);
    drawnow
    

    if Time_passed > Period
        stop = 1;
    end
end

Ammeter.CMD_data_req;


figure
plot(Voltage_target, Voltage_target-ADC_2_g,'.')

%%
clc
Ammeter = Ammeter2('COM3');


%%

figure
Time_g = [];
ADC_2_g = [];

Ammeter.flush_data;
Ammeter.CMD_data_req;

Period = 200;
stop = 0;
Timer = tic;
k = 0;
while(~stop)
    Time_passed = toc(Timer);

    [time, voltage, ADC_2_voltage, Unit, Relay_state, Device_state_byte] = Ammeter.high_level_read;
    Time_g = [Time_g time];
    ADC_2_g = [ADC_2_g ADC_2_voltage];

    cla
    plot(Time_g, 1e6*movmean(ADC_2_g, 1));
    yline(0);
    drawnow

    pause(0.1)
    if Time_passed > Period
        stop = 1;
    end
end

Ammeter.CMD_data_req;


%%

plot(double(Time_g(1:end-1))*0.0001, diff(Time_g), '.')









