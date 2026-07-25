function [ber, bitErrors] = calculateBER(txBits, rxBits)
%CALCULATEBER Calculate Bit Error Rate.

arguments
    txBits (:,1) double
    rxBits (:,1) double
end

if numel(txBits) ~= numel(rxBits)
    error("Input vectors must have the same length.");
end

bitErrors = nnz(txBits ~= rxBits);

ber = bitErrors / numel(txBits);

end