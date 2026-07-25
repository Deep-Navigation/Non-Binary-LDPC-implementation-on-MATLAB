function [decoded,info] = ldpcdecodegf64( ...
    sym_llr,H_idx,H_val,gf_mul,gf_div,max_iter)
%LDPCDECODEGF64 Decode a GF(64) LDPC codeword using the Min-Sum algorithm.
%
% Inputs
%   sym_llr   : 64×N symbol cost matrix
%   H_idx     : Check-node connectivity
%   H_val     : GF coefficients
%   gf_mul    : GF multiplication lookup table
%   gf_div    : GF division lookup table
%   max_iter  : Maximum decoding iterations
%
% Outputs
%   decoded   : Decoded GF(64) symbols
%   info      : Structure containing convergence information

if nargin < 6
    max_iter = 10;
end

numChecks = size(H_idx,1);
rowWeight = size(H_idx,2);
numVars   = size(sym_llr,2);

V2C = zeros(64,numChecks,rowWeight);
C2V = zeros(64,numChecks,rowWeight);

decoded = zeros(numVars,1);

info.success = false;
info.iterations = max_iter;
info.syndrome = false;

%% Initialize Variable→Check messages
for c = 1:numChecks
    for e = 1:rowWeight
        V2C(:,c,e) = sym_llr(:,H_idx(c,e));
    end
end

%% Iterative decoding
for iter = 1:max_iter

    %% Check node update
    for c = 1:numChecks

        V2C_perm = zeros(64,rowWeight);

        for e = 1:rowWeight
            h = H_val(c,e);

            for val = 0:63
                p = gf_mul(h+1,val+1);
                V2C_perm(p+1,e) = V2C(val+1,c,e);
            end
        end

        C2V_perm = Inf(64,rowWeight);

        for e = 1:rowWeight

            others = setdiff(1:rowWeight,e);

            e1 = others(1);
            e2 = others(2);
            e3 = others(3);

            temp = Inf(64,1);

            for a = 0:63
                for b = 0:63
                    s = bitxor(a,b);

                    cost = V2C_perm(a+1,e1) + V2C_perm(b+1,e2);

                    if cost < temp(s+1)
                        temp(s+1) = cost;
                    end
                end
            end

            for ab = 0:63
                for c3 = 0:63

                    s = bitxor(ab,c3);

                    cost = temp(ab+1) + V2C_perm(c3+1,e3);

                    if cost < C2V_perm(s+1,e)
                        C2V_perm(s+1,e) = cost;
                    end
                end
            end
        end

        for e = 1:rowWeight

            h = H_val(c,e);

            for val = 0:63

                original = gf_div(val+1,h+1);

                C2V(original+1,c,e) = C2V_perm(val+1,e);

            end
        end
    end

    %% Variable node update
    for v = 1:numVars

        total = sym_llr(:,v);

        for c = 1:numChecks
            for e = 1:rowWeight

                if H_idx(c,e)==v
                    total = total + C2V(:,c,e);
                end

            end
        end

        offset = min(total);
        total = total-offset;

        [~,idx] = min(total);

        decoded(v) = idx-1;

        for c = 1:numChecks
            for e = 1:rowWeight

                if H_idx(c,e)==v
                    V2C(:,c,e) = total - C2V(:,c,e) + offset;
                end

            end
        end
    end

    %% Syndrome check

    success = true;

    for c = 1:numChecks

        sumGF = 0;

        for e = 1:rowWeight

            v = H_idx(c,e);

            sumGF = bitxor(sumGF,...
                gf_mul(H_val(c,e)+1,decoded(v)+1));

        end

        if sumGF~=0
            success = false;
            break;
        end
    end

    if success

        info.success = true;
        info.iterations = iter;
        info.syndrome = true;
        return

    end

end