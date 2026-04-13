
% FIXME: put in Fern::common

function [result, bytes_out] = adler32(bytes)

s1 = uint32(1);
s2 = uint32(0);

for i = 1:numel(bytes)
    s1 = mod(sum_uint32(s1, bytes(i)), 65521);
    s2 = mod(sum_uint32(s1, s2), 65521);
end

s2 = mult_uint32(s2, uint32(2^16));
s2 = sum_uint32(s2, s1);

result = s2;
% bytes_out = flip(typecast([typecast(result, 'uint8')], 'uint8'));
bytes_out = flip(typecast(result, 'uint8'));
end

function result = sum_uint32(x, y)
result = uint32( mod( double(x) + double(y) , uint64(2)^32) );
end

function result = mult_uint32(x, y)
result = uint32( mod( double(x) * double(y) , uint64(2)^32) );
end




%% Other way
% data = uint8(char(String));
% adler = java.util.zip.Adler32();
% adler.update(data);
% adler32_val = adler.getValue()