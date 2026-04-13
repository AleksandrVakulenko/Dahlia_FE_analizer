
% SOME OLD TEST FOR LONG PACKET


clc

N = 250;
data = uint32(1:N);

cmd = 200;


[d_bytes, size_bytes] = data_uint32_to_bytes(data);
[checksum, checksum_bytes] = adler32(d_bytes);
CMD_packet = [uint8(cmd) size_bytes checksum_bytes d_bytes];




%%

clc
Ammeter = Ammeter2('COM3');

N = 2;
Data = uint32(1:N);

Ammeter.send_long_cmd(200, Data);


Ammeter.delete















%%

clc
b = 4
typecast(single(b), 'uint8')
typecast(uint16(b), 'uint8')


arg_a = 128
arg_a_bytes = flip(typecast(uint32(arg_a), 'uint8'))




