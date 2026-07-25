function encodedBits = gf642bits(encodedSymbols)
%GF642BITS Convert GF(64) symbols to a binary vector.
%
% Syntax
%   encodedBits = gf642bits(encodedSymbols)
%
% Description
%   Converts each GF(64) symbol (0-63) into its 6-bit binary
%   representation using MSB-first ordering.
%
% Input
%   encodedSymbols - Nx1 vector of integers in the range [0,63]
%
% Output
%   encodedBits    - (6N)x1 binary vector
%
% Example
%   bits = gf642bits(encodedSymbols);

arguments
    encodedSymbols (:,1) double
end

% Validate input
if any(encodedSymbols < 0 | encodedSymbols > 63)
    error("All symbols must be integers between 0 and 63.");
end

numSymbols = numel(encodedSymbols);

encodedBits = zeros(numSymbols*6,1);

for i = 1:numSymbols

    value = encodedSymbols(i);

    idx = (i-1)*6 + 1;

    encodedBits(idx    ) = bitget(value,6);
    encodedBits(idx + 1) = bitget(value,5);
    encodedBits(idx + 2) = bitget(value,4);
    encodedBits(idx + 3) = bitget(value,3);
    encodedBits(idx + 4) = bitget(value,2);
    encodedBits(idx + 5) = bitget(value,1);

end

end