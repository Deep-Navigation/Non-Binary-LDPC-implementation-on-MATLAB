function bits = decimalToBits(value,nBits)
%DECIMALTOBITS Convert integer to binary vector (MSB first)

bits = zeros(nBits,1);

for i = 1:nBits
    bits(i) = bitget(value,nBits-i+1);
end

end