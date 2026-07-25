function crcBits = crc24(dataBits)
%CRC24 Compute CRC-24Q checksum.
%
% Syntax
%   crcBits = crc24(dataBits)
%
% Description
%   Computes the 24-bit CRC-24Q checksum used in GNSS and RTCM
%   navigation messages.
%
% Input
%   dataBits  - Binary column vector
%
% Output
%   crcBits   - 24×1 binary vector (MSB first)

arguments
    dataBits (:,1) double
end

% Validate binary input
if any(dataBits ~= 0 & dataBits ~= 1)
    error("Input must contain only binary values.");
end

% CRC-24Q polynomial (0x1864CFB)
poly = hex2dec('1864CFB');

crc = uint32(0);

for i = 1:length(dataBits)

    inputBit = uint32(dataBits(i));

    topBit = bitget(crc,24);

    crc = bitshift(crc,1);

    crc = bitand(crc,uint32(hex2dec('FFFFFF')));

    if xor(topBit,inputBit)

        crc = bitxor(crc,uint32(poly));

    end

end

crcBits = zeros(24,1);

for i = 1:24

    crcBits(i) = bitget(crc,25-i);

end

end