% current version: 1.0.1

% bug report:
% 1) ctrl+C on running script test_04_Data_rec_measure_2.m &
% F9 on Ammeter.delete -->
% unable to reconnect

classdef Dahlia < handle
    %--------------------------------PUBLIC--------------------------------
    methods (Access = public)
        function obj = Dahlia(port_name)
            close_all_classes(class(obj));
            obj.COM_port_str = char(port_name);
            port_name_check(obj.COM_port_str);
            obj.Serial_obj = serialport(obj.COM_port_str, 9600);
            disp(['Dahlia connected at port: ' obj.COM_port_str])
            obj.connected_flag = 1;
        end

        function delete(obj)
            if obj.connected_flag == 1
                %                 obj.sink_to_gnd();
                delete(obj.Serial_obj);
                disp('Dahlia closed');
            end
        end

        %-------------------------------CMD--------------------------------
        function toggle_LED(obj) % FIXME: delete in future update
            warning('CMD is ignored since V1.0.0');
        end

        function re_init_relays(obj)
            obj.send_cmd(1);
        end

        function enable_feedback(obj, state)
            if state ~= 0 && state ~= 1
                error(['Wrong argument: ' char(state)]);
            end
            obj.send_cmd(2, state);
        end

        function cap_short(obj, state)
            if state ~= 0 && state ~= 1
                error(['Wrong argument: ' char(state)]);
            end
            obj.send_cmd(3, state);
        end

        function set_input_ch_direction(obj, direction)
            % direction: 'internal'(default) 'external'
            if direction == "internal"
                last_byte_A = uint8(0);
            elseif direction == "external"
                last_byte_A = uint8(1);
            else
                error(['Wrong argument: ' char(direction)]);
            end
            obj.send_cmd(4, last_byte_A);
        end

        function set_output_filter_freq(obj, freq)
            % freq: 'high'(default) 'low'
            if freq == "high"
                last_byte_A = uint8(0);
            elseif freq == "low"
                last_byte_A = uint8(1);
            else
                error(['Wrong argument: ' char(direction)]);
            end
            obj.send_cmd(5, last_byte_A);
        end

        function switch_feedback_res(obj, fb_num, freq)
            % fb_num values 0->3
            % freq: 'high' 'low'
            % FIXME: add default value
            if fb_num > 3
                fb_num = 3;
            end
            if fb_num < 0
                fb_num = 0;
            end
            if freq == "high"
                last_byte_B = uint8(0);
            elseif freq == "low"
                last_byte_B = uint8(1);
            else
                error('wrong freq value')
            end
            last_byte_A = uint8(fb_num);
            obj.send_cmd(6, last_byte_A, last_byte_B);
        end

        function switch_feedback_cap(obj, fb_num, varargin)
            % fb_num values 0->3
            % second argument "start_shorted"; value = 1/0; default value = 1
            narginchk(2, 3)
            if fb_num > 3
                fb_num = 3;
            end
            if fb_num < 0
                fb_num = 0;
            end
            if nargin == 3
                last_byte_B = uint8(varargin{1});
            else
                last_byte_B = uint8(1);
            end
            last_byte_A = uint8(fb_num);
            obj.send_cmd(7, last_byte_A, last_byte_B);
        end

        function DAC_set_voltage(obj, voltage)
            d_bytes = typecast(single(voltage), 'uint32');
            obj.send_cmd(14, d_bytes);
        end

        function CMD_data_stream(obj, arg)
            % FIXME: toggle for data send; (!!! legacy CMD, will be remover in future updates)
            obj.send_cmd(8, arg);
        end

        function CMD_data_req(obj)
            % FIXME: toggle for data send; (!!! legacy CMD, will be remover in future updates)
            obj.send_cmd(9);
        end

        function Relay_state = CMD_get_relay_state(obj)
            obj.send_cmd(12);
            pause(0.05);
            [~, ~, ~, Relay_state] = obj.debug_read();
            Relay_state = relay_byte_parse(Relay_state);
        end

        function res_range_higher(obj)
            obj.send_cmd(10);
        end

        function res_range_lower(obj)
            obj.send_cmd(11);
        end

        function Capacitor(obj, cap)
            switch cap
                case "20u"
                    obj.switch_feedback_cap(3, 1);
                case "150n"
                    obj.switch_feedback_cap(2, 1);
                case "1n"
                    obj.switch_feedback_cap(1, 1);
                case "10p"
                    obj.switch_feedback_cap(0, 1);
            end
            pause(0.002)
        end

        function CMD_run_triangle(obj)
            obj.send_cmd(19);
        end
        function CMD_run_sin(obj)
            obj.send_cmd(18);
        end
        function CMD_run_noise(obj)
            obj.send_cmd(17);
        end
        function CMD_run_square(obj)
            obj.send_cmd(16);
        end
        function CMD_cap_reset(obj)
            obj.send_cmd(15);
        end

        function CMD_TS_reset(obj)
            obj.send_cmd(13);
        end

        function CMD_measurement_run(obj)
            obj.send_cmd(20);
        end

        function CMD_measurement_stop(obj)
            obj.send_cmd(21);
        end

        function send_long_cmd(obj, cmd, data)
            if cmd < 200
                warning('long CMD ignored/ wrong CMD code')
            else
                [d_bytes, size_bytes] = convert2bytes(data);
                [~, checksum_bytes] = FE_loop_utils.adler32(d_bytes);
%                 checksum_bytes(1) = 2;
                CMD_packet = [uint8(cmd) uint8(0) uint8(0) size_bytes checksum_bytes d_bytes];
                N = numel(CMD_packet);
                if N > 1024 % FIXME: magic constant
                    warning("ERROR! LONG PACKET >1024 bytes")
                else
                    write(obj.Serial_obj, uint8(CMD_packet), "uint8");
                    pause(0.012);
                end
            end
        end

        %----------------------------CMD_END-------------------------------


        %--------------------------Acquisition-----------------------------
        function [Full_time_stamp, ADC_1_voltage, ADC_2_voltage, Relay_state_byte, Device_state_byte] = debug_read(obj)
            table = obj.get_raw_data;
            if ~isempty(table)
                [Data_table, CMD_table] = split_tables(table);
                [Device_state_byte, Relay_state_byte, Full_time_stamp, ...
                ADC_1_voltage, ADC_2_voltage] = parse_data_table(Data_table);
            else
                error('no data avilable') %FIXME: add error handler
            end
        end

        function [Time, Voltage, Signal, Unit, Relay_state, Device_state_byte] = high_level_read(obj)
            try
                [Full_time_stamp, ADC_1_voltage, ADC_2_voltage, Relay_state_byte, Device_state_byte] = obj.debug_read;
                % FIXME: add filtering
                [Relay_state, Unit, multiplier] = relay_byte_parse(Relay_state_byte);
                Time = double(Full_time_stamp)*100e-6; % s
                Voltage = ADC_2_voltage; % V
                Signal = (-1)*ADC_1_voltage.*multiplier;
%                 Device_state_byte = Device_state_byte;
            catch e
                error(e.message);
            end
        end    

        function flush_data(obj)
            serial_flush(obj.Serial_obj);
        end
        %------------------------Acquisition_END---------------------------
    end


    %-------------------------------PRIVATE--------------------------------
    properties (Access = private)
        COM_port_str = '';
        Serial_obj = [];
        number_of_bytes = 16;
        connected_flag = 0;
    end

    methods (Access = private)
        function send_cmd(obj, cmd, varargin)
            narginchk(2, 4);
            if nargin > 2
                arg_a = varargin{1};
            else
                arg_a = 0;
            end
            if nargin > 3
                arg_b = varargin{2};
            else
                arg_b = 0;
            end
            arg_a_bytes = flip(typecast(uint32(arg_a), 'uint8'));
            arg_b_bytes = flip(typecast(uint32(arg_b), 'uint8'));
            CMD_packet = [uint8(cmd) arg_a_bytes arg_b_bytes];
            % uint8(CMD_packet)
            write(obj.Serial_obj, uint8(CMD_packet), "uint8");
            pause(0.012);
        end



        function Data = get_raw_data(obj)
            serial_obj = obj.Serial_obj;
            Bytes_count = serial_obj.NumBytesAvailable;

            if Bytes_count < obj.number_of_bytes
                Data = [];
            else
                Bytes_to_read = floor(Bytes_count/obj.number_of_bytes)*obj.number_of_bytes;
                Data = read(serial_obj, Bytes_to_read, "uint8");
                Data = reshape(Data, [obj.number_of_bytes numel(Data)/obj.number_of_bytes]);
            end
        end

    end
end


% -------------------------------------------------------------------------

function [Data_table, CMD_table] = split_tables(table)

Data_table = table;
CMD_rows = 1; % FIXME: magic constant
CMD_value_data = 170; % FIXME: magic constant

CMD = Data_table(CMD_rows, :);

range = CMD ~= CMD_value_data;
CMD_table = Data_table(:,range);
Data_table(:,range) = [];
Data_table(1,:) = [];

end

function [Device_state, Relay_state_byte, Full_time_stamp, ADC_1_voltage, ADC_2_voltage] = parse_data_table(Data_table)

Device_state_rows = 2 - 1; % FIXME: magic constant
Relay_state_rows = 3 - 1; % FIXME: magic constant
TS_epoch_rows = 4 - 1; % FIXME: magic constant
TS_time_rows = (5:8) - 1; % FIXME: magic constant
ADC1_argA_row = (9:12) - 1; % FIXME: magic constant
ADC2_argB_row = (13:16) - 1;  % FIXME: magic constant
ADC1_ref_voltage = 4.096*3; % FIXME: magic constant
ADC2_ref_voltage = 4.096*3; % FIXME: magic constant

%
Device_state = Data_table(Device_state_rows, :);
Relay_state_byte = Data_table(Relay_state_rows, :);

%
Time_stamp_epoch_part = Data_table(TS_epoch_rows, :);
Time_stamp_epoch = uint64(typecast(uint8(Time_stamp_epoch_part), 'uint8'));

Time_stamp_time_part = Data_table(TS_time_rows, :);
Time_stamp_time_part = reshape(Time_stamp_time_part, [1 numel(Time_stamp_time_part)]);
Time_stamp_time = uint64(typecast(uint8(Time_stamp_time_part), 'uint32'));

Full_time_stamp = Time_stamp_epoch*uint64(2^32) + Time_stamp_time;

%
ADC1_part = Data_table(ADC1_argA_row, :);
ADC1_part = reshape(ADC1_part, [1 numel(ADC1_part)]);
ADC_1_code = double(typecast(uint8(ADC1_part), 'int32'));
ADC_1_voltage = ADC_1_code/2^17*ADC1_ref_voltage;
% ADC_1_voltage = ADC_1_code;

ADC2_part = Data_table(ADC2_argB_row, :);
ADC2_part = reshape(ADC2_part, [1 numel(ADC1_part)]);
ADC_2_code = double(typecast(uint8(ADC2_part), 'int32'));
ADC_2_voltage = ADC_2_code/2^17*ADC2_ref_voltage;
% ADC_2_voltage = ADC_2_code;

end


function [Relay_state, unit, multiplier] = relay_byte_parse(byte)

bits_char = dec2bin(byte, 8);
bits_char = bits_char';
bit_array = str2num(reshape(bits_char, numel(bits_char), 1));
bit_array = reshape(bit_array, 8, numel(bits_char)/8)';
bit_array = flip(bit_array, 2);

bit_array_last = bit_array(end, :);
Relay_state = get_relay_state(bit_array_last);

bit_array_fb = bit_array(:, [4, 2, 1]);

[unit, multiplier] = Feedback_table(bit_array_fb);

end

function Relay_state = get_relay_state(bit_array_last)

if bit_array_last(8)
    Relay_state.output_freq = 'high';
else
    Relay_state.output_freq = 'low';
end

if bit_array_last(7)
    Relay_state.v_ch = 'internal';
else
    Relay_state.v_ch = 'external';
end

Relay_state.sink_to_gnd = bit_array_last(6);
Relay_state.cap_shorted = bit_array_last(5);

if bit_array_last(4)
    Relay_state.fb_type = 'res';
else
    Relay_state.fb_type = 'cap';
end

if bit_array_last(3)
    Relay_state.fb_freq = 'high';
else
    Relay_state.fb_freq = 'low';
end

Relay_state.feedback = bit_array_last(2)*2+bit_array_last(1);

end

function [unit, multiplier] = Feedback_table(Relay_state_byte)
% 	res10G  =  0; 0b000
% 	res10M  =  1; 0b001
% 	res10k  =  2; 0b010
% 	res20   =  3; 0b011
% 	cap20u  =  4; 0b100
% 	cap150n =  5; 0b101
% 	cap1n   =  6; 0b110
% 	cap10p  =  7; 0b111

unit = strings(1, size(Relay_state_byte, 1));
multiplier = zeros(1, size(Relay_state_byte, 1));

% units = ["A", "C"]; %FIXME: replace by units class

correction_cap = [1, 1, 1, 1];
multiplier_cap = [20e-6, 150e-9, 1e-9, 10e-12];
multiplier_cap = multiplier_cap.*correction_cap;

correction_res = [1, 1, 1, 1];
multiplier_res = [1/10e9, 1/10e6, 1/10e3, 1/5];
multiplier_res = multiplier_res.*correction_res;

FB_num = (Relay_state_byte(:, 2)*2 + Relay_state_byte(:, 3) + 1)';
range_res = logical(Relay_state_byte(:, 1));

multiplier(~range_res) = multiplier_cap(FB_num(~range_res));
multiplier(range_res) = multiplier_res(FB_num(range_res));


% multiplier_res(4)
unit(~range_res) = "C";
unit(range_res) = "A";

end






% -------------------------------------------------------------------------

function port_name_check(port_name)
Avilable_ports = serialportlist('available');

if ~(sum(Avilable_ports == port_name) == 1)
    Text_ports_list = '';
    for i = 1:numel(Avilable_ports)
        Text_ports_list = [Text_ports_list char(Avilable_ports(i)) newline];
    end

    msg = ['ERROR: No such com port name.' newline ...
        'List of avilable ports:' newline ...
        Text_ports_list ...
        'Provided name: ' port_name];
    error(msg)
end
end


function serial_flush(serial_obj)
pause(0.05) %FIXME: why pause?
Bytes_count = serial_obj.NumBytesAvailable;
if Bytes_count > 0
    read(serial_obj, Bytes_count, "uint8");
end
end


function close_all_classes(class_name)
input_class_name = class_name;
baseVariables = evalin('base' , 'whos');
Indexes = string({baseVariables.class}) == input_class_name;
Var_names = string({baseVariables.name});
Var_names = Var_names(Indexes);
Valid = zeros(size(Var_names));
for i = 1:numel(Var_names)
    Valid(i) = evalin('base', ['isvalid(' char(Var_names(i)) ')']);
end
Valid = logical(Valid);
Var_names = Var_names(Valid);
for i = 1:numel(Var_names)
    evalin('base', ['delete(' char(Var_names(i)) ')']);
end
end





function [d_bytes, size_bytes] = convert2bytes(data)
    % class(data)
    switch class(data)
        case "uint"
            [d_bytes, size_bytes] = data_uint8_to_bytes(data);
        case "uint32"
            [d_bytes, size_bytes] = data_uint32_to_bytes(data);
        case "int32"
            [d_bytes, size_bytes] = data_int32_to_bytes(data);
        case "single"
            [d_bytes, size_bytes] = data_single_to_bytes(data);
        case "FE_loop_utils.Pulse_waveform_init"
            [d_bytes, size_bytes] = data_wf_pulse_to_bytes(data);
        otherwise
            error('Wrong type to byte conversion')
    end
end



function [data, size_bytes] = data_uint8_to_bytes(data)
    data_size = uint16(numel(data));
    size_bytes = flip(typecast(data_size, 'uint8'));
end


function [d_bytes, size_bytes] = data_uint32_to_bytes(data)
    d_bytes = typecast(uint32(data), 'uint8');
    d_bytes = reshape(d_bytes, 4, numel(d_bytes)/4);
    d_bytes = flip(d_bytes, 1);
    d_bytes = reshape(d_bytes, 1, numel(d_bytes));
    
    data_size = uint16(numel(d_bytes));
    size_bytes = flip(typecast(data_size, 'uint8'));
end


function [d_bytes, size_bytes] = data_int32_to_bytes(data)
    d_bytes = typecast(int32(data), 'uint8');
    d_bytes = reshape(d_bytes, 4, numel(d_bytes)/4);
    d_bytes = flip(d_bytes, 1);
    d_bytes = reshape(d_bytes, 1, numel(d_bytes));
    
    data_size = uint16(numel(d_bytes));
    size_bytes = flip(typecast(data_size, 'uint8'));
end


function [d_bytes, size_bytes] = data_single_to_bytes(data)
    d_bytes = typecast(data, 'uint8');
    data_size = uint16(numel(d_bytes));
    size_bytes = flip(typecast(data_size, 'uint8'));
end


function [d_bytes, size_bytes] = data_wf_pulse_to_bytes(data)
    [prop_float, prop_uint8] = data.get_prop();
    [d_bytes1, size_bytes1] = data_single_to_bytes(prop_float);
    [d_bytes2, size_bytes2] = data_uint8_to_bytes(prop_uint8);
    d_bytes = [d_bytes1 d_bytes2];
    size_bytes = size_bytes1 + size_bytes2;
end