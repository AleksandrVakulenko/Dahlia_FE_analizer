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
    case "Pulse_waveform_init"
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