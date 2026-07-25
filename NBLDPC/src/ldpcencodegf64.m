function encoded = ldpcencodegf64(symbols, B_inv_A_gf)
%LDPCENCODEGF64 Encode a GF(64) message using the LDPC generator matrix.
%
% Syntax
%   encoded = ldpcencodegf64(symbols, B_inv_A_gf)
%
% Description
%   Encodes a 48-symbol GF(64) message into a 96-symbol LDPC codeword.
%
% Inputs
%   symbols     - 48×1 message symbols (integers 0–63)
%   B_inv_A_gf  - Generator submatrix over GF(64)
%
% Output
%   encoded     - 96×1 encoded GF(64) symbols
%
% Example
%   encoded = ldpcencodegf64(symbols, B_inv_A_gf);

%% Input validation

arguments
    symbols (:,1) double
    B_inv_A_gf gf
end

if any(symbols < 0 | symbols > 63)
    error("Input symbols must be integers between 0 and 63.");
end

%% Convert message to GF(64)

symbols_gf = gf(symbols,6,67);

%% Compute parity symbols

parity_gf = B_inv_A_gf * symbols_gf;

%% Assemble codeword

encoded_gf = [symbols_gf;
    parity_gf];

%% Convert back to MATLAB doubles

encoded = double(encoded_gf.x);

end