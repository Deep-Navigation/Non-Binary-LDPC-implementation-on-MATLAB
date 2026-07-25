function symbols = bits2gf64(txBits)
%BITS2GF64 Convert a binary vector into GF(64) symbols.
%
% Syntax
%   symbols = bits2gf64(txBits)
%
% Description
%   Groups every 6 bits (MSB first) into one GF(64) symbol.
%
% Input
%   txBits  - 288×1 or 1×288 binary vector
%
% Output
%   symbols - 48×1 vector containing integers in the range [0,63]
%
% Example
%   symbols = bits2gf64(txBits);

arguments
    txBits (:,1) double
end

% Ensure binary input
if any(txBits ~= 0 & txBits ~= 1)
    error("Input must contain only 0s and 1s.");
end

if mod(numel(txBits),6) ~= 0
    error("Number of bits must be a multiple of 6.");
end

numSymbols = numel(txBits)/6;
symbols = zeros(numSymbols,1);

for i = 1:numSymbols

    idx = (i-1)*6 + (1:6);

    bits = txBits(idx);

    symbols(i) = ...
        bits(1)*32 ...
        + bits(2)*16 ...
        + bits(3)*8 ...
        + bits(4)*4 ...
        + bits(5)*2 ...
        + bits(6);

end

end