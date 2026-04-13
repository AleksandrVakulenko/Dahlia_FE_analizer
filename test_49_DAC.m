
% NEED AN UPDATE

clc
Ammeter = Ammeter2('COM3');


%%
Ammeter.delete


%%
clc

% voltage = 32767;
% voltage = 30000;
% voltage = 20000;
% voltage = 10000;
% voltage = 5000;
voltage = 0;
% voltage = -5000;
% voltage = -10000;
% voltage = -20000;
% voltage = -30000;
% voltage = -32768;

Ammeter.DAC_set_voltage(voltage);

%%
clc

voltage = 0;


V_ref = 10; %V
voltage_code = floor(voltage/V_ref*2^15);

Ammeter.DAC_set_voltage(voltage_code);


%%

Binary = [
    32767
    30000
    20000
    10000
    5000
    0
    -5000
    -10000
    -20000
    -30000
    -32768
    ];

Voltage_out = [
    9.6
    8.8
    5.8
    2.8
    1.44
    -0.07
    -1.6
    -3.12
    -6.24
    -9.4
    -10.2
];


%%

voltage_array = [
32767
30000
20000
10000
5000
0
-5000
-10000
-20000
-30000
];


for i = 1:numel(voltage_array)

Ammeter.DAC_set_voltage(voltage_array(i));
pause(0.2)

Ammeter.DAC_set_voltage(-32768);
pause(0.2)

end
















