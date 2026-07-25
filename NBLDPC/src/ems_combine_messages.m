function [out_sym, out_cost] = ems_combine_messages(in1_sym, in1_cost, in2_sym, in2_cost, nm)
% EMS_COMBINE_MESSAGES  Vectorized convolution of two GF(64) Top-M messages.
%
% Inputs:
%   in1_sym, in1_cost - Top-M symbols and costs
%   in2_sym, in2_cost - Top-M symbols and costs
%   nm                - Top-M parameter
%
% Outputs:
%   out_sym, out_cost - Top-M combined message

q = 64;

%% Force column vectors
S1 = in1_sym(:);
C1 = in1_cost(:);

S2 = in2_sym(:);
C2 = in2_cost(:);

%% -------- Vectorized pairwise combinations --------
% GF(64) addition = bitwise XOR
% Cost combination = ordinary addition

symMat  = bitxor(S1, S2.');
costMat = C1 + C2.';

%% Flatten matrices
new_sym  = symMat(:);
new_cost = costMat(:);

%% Keep minimum cost for each GF symbol
sym_idx = double(new_sym) + 1;

min_cost_per_sym = accumarray( ...
    sym_idx, ...
    new_cost, ...
    [q 1], ...
    @min, ...
    inf);

%% Keep Top-M symbols
[out_cost_col, out_sym_idx] = mink(min_cost_per_sym, nm);

out_sym  = (out_sym_idx - 1).';
out_cost = out_cost_col.';

end