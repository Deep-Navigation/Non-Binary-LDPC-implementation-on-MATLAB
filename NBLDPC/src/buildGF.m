function [gf_exp,gf_log,gf_mul,gf_div] = buildGF()
%BUILDGF Generate lookup tables for GF(64)
%
% Primitive polynomial:
%   x^6 + x + 1  (decimal 67)

N_GF = 64;

gf_exp = zeros(N_GF,1);
gf_log = zeros(N_GF,1);

gf_exp(1) = 1;
gf_log(1) = -1;

for i = 1:62

    value = gf_exp(i)*2;

    if value >= 64
        value = bitxor(value,67);
    end

    gf_exp(i+1) = value;

end

gf_exp(64) = 0;

for i = 1:63
    gf_log(gf_exp(i)+1) = i-1;
end

gf_log(1) = -1;

%% Multiplication table

gf_mul = zeros(64);

for i = 0:63
    for j = 0:63

        if i==0 || j==0
            gf_mul(i+1,j+1)=0;
        else

            idx = mod(gf_log(i+1)+gf_log(j+1),63);

            gf_mul(i+1,j+1)=gf_exp(idx+1);

        end

    end
end

%% Division table

gf_div = zeros(64);

for i = 0:63
    for j = 1:63

        if i==0
            gf_div(i+1,j+1)=0;
        else

            idx = mod(gf_log(i+1)-gf_log(j+1),63);

            gf_div(i+1,j+1)=gf_exp(idx+1);

        end

    end
end

end