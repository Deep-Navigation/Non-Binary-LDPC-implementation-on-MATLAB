function test_ldpcdecodegf64_ems()
%TEST_LDPCDECODEGF64_EMS Deterministic correctness tests for EMS decoder.
% Builds tiny GF(64) tables + toy H, verifies: all-zero codeword decodes
% correctly, syndrome satisfied, ems_truncate correctness, no errors thrown.

q = 64;
[gf_mul, gf_div] = build_gf64_tables(67); % primitive poly x^6+x+1 = 67

% --- Toy H: 2 checks, rowWeight 2, numVars 3 (var3 unused by check2) ------
H_idx = [1 2; 2 3];
H_val = [1 1; 1 1];
numVars = 3;

% --- Zero codeword: all symbols = 0, strong confidence at symbol 0 -------
sym_llr = 5*ones(q, numVars);
sym_llr(1, :) = 0;   % cost 0 at symbol 0 (1-based index 1)

max_iter = 5; nm = 8;
[decoded, info] = ldpcdecodegf64_ems(sym_llr, H_idx, H_val, gf_mul, gf_div, max_iter, nm);

assert(isequal(decoded, zeros(numVars,1)), 'Decoded symbols must be all-zero.');
assert(info.syndrome, 'Syndrome must be satisfied.');
assert(info.success, 'Decoder must report success.');

% --- ems_truncate correctness ---------------------------------------------
msg = (1:q)'; % costs 1..64, symbol k-1 has cost k
tmsg = ems_truncate(msg, 5);
assert(isequal(tmsg(1:5), (1:5)'), 'Top-5 entries must remain unchanged.');
assert(all(tmsg(6:end) == 5), 'Non-Top-M entries must equal surrogate=5.');

% --- Error handling ---------------------------------------------------------
try
    ldpcdecodegf64_ems(sym_llr, H_idx, H_val, gf_mul, gf_div, 0, nm);
    error('Expected error for max_iter=0 not thrown.');
catch ME
    assert(strcmp(ME.identifier,'ldpcdecodegf64_ems:invalidMaxIter'));
end

try
    ldpcdecodegf64_ems(sym_llr, H_idx, H_val, gf_mul, gf_div, max_iter, 100);
    error('Expected error for nm>64 not thrown.');
catch ME
    assert(strcmp(ME.identifier,'ldpcdecodegf64_ems:invalidNm'));
end

disp('All ldpcdecodegf64_ems tests passed.');
end

function [gf_mul, gf_div] = build_gf64_tables(primPoly)
% Builds GF(64) multiplication/division tables via primitive polynomial.
q = 64;
exp_table = zeros(2*q,1);
log_table = zeros(q,1);
x = 1;
for i = 0:q-2
    exp_table(i+1) = x;
    log_table(x+1) = i;
    x = bitshift(x,1);
    if bitand(x, q) ~= 0
        x = bitxor(x, primPoly);
    end
end
exp_table(q:2*q-2) = exp_table(1:q-1);
gf_mul = zeros(q,q); gf_div = zeros(q,q);
for a = 0:q-1
    for b = 0:q-1
        if a==0 || b==0
            gf_mul(a+1,b+1) = 0;
        else
            gf_mul(a+1,b+1) = exp_table(mod(log_table(a+1)+log_table(b+1), q-1)+1);
        end
        if b==0
            gf_div(a+1,b+1) = 0; % undefined, guarded by caller
        elseif a==0
            gf_div(a+1,b+1) = 0;
        else
            gf_div(a+1,b+1) = exp_table(mod(log_table(a+1)-log_table(b+1), q-1)+1);
        end
    end
end
end