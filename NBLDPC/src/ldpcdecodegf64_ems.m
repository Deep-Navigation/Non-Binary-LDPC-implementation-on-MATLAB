function [decoded, info] = ldpcdecodegf64_ems( ...
    sym_llr, H_idx, H_val, gf_mul, gf_div, max_iter, nm)
%LDPCDECODEGF64_EMS Extended Min-Sum decoder for NB-LDPC over GF(64).
% Inputs : sym_llr(64xN costs), H_idx/H_val(numChecks x rowWeight),
%          gf_mul/gf_div(64x64 tables), max_iter, nm (Top-M, 1<=nm<=64).
% Output : decoded(Nx1 symbols 0..63), info.success/iterations/syndrome.
% Algorithm: check-node convolution done on Top-M lists via
% ems_combine_messages (cheap), expanded to dense 64-vectors with EMS
% surrogate for variable-node summation; var->edge map avoids linear scan.

q = 64;
if ndims(sym_llr) ~= 2 || size(sym_llr,1) ~= q
    error('ldpcdecodegf64_ems:invalidLLR','sym_llr must be %dxN.', q);
end
[numChecks, rowWeight] = size(H_idx);
if ~isequal(size(H_val), [numChecks, rowWeight])
    error('ldpcdecodegf64_ems:dimMismatch','H_idx/H_val size mismatch.');
end
numVars = size(sym_llr, 2);
if any(H_idx(:) < 1 | H_idx(:) > numVars | H_idx(:) ~= floor(H_idx(:)))
    error('ldpcdecodegf64_ems:invalidHidx','H_idx out of range.');
end
if any(H_val(:) < 0 | H_val(:) > q-1)
    error('ldpcdecodegf64_ems:invalidHval','H_val out of GF(64) range.');
end
if ~isequal(size(gf_mul), [q,q]) || ~isequal(size(gf_div), [q,q])
    error('ldpcdecodegf64_ems:invalidGFtables','gf_mul/gf_div must be 64x64.');
end
if ~isscalar(max_iter) || max_iter < 1 || max_iter ~= floor(max_iter)
    error('ldpcdecodegf64_ems:invalidMaxIter','max_iter must be positive integer.');
end
if ~isscalar(nm) || nm < 1 || nm > q || nm ~= floor(nm)
    error('ldpcdecodegf64_ems:invalidNm','nm must be integer in [1,%d].', q);
end

% --- Precompute var -> (check,edge) linear index map (no per-v scan) ------
linIdx    = reshape(1:numChecks*rowWeight, numChecks, rowWeight);
varEdges  = cell(numVars,1);
for v = 1:numVars
    varEdges{v} = linIdx(H_idx == v);
end

V2C = zeros(q, numChecks, rowWeight);
C2V = zeros(q, numChecks, rowWeight);
decoded = zeros(numVars,1);
info = struct('success', false, 'iterations', max_iter, 'syndrome', false);

for c = 1:numChecks
    for e = 1:rowWeight
        V2C(:,c,e) = sym_llr(:, H_idx(c,e));
    end
end
if nm < q
    for c = 1:numChecks
        for e = 1:rowWeight
            V2C(:,c,e) = ems_truncate(V2C(:,c,e), nm);
        end
    end
end

for iter = 1:max_iter


    % ===== Check-node update (Top-M convolution, expanded to dense) =====
    for c = 1:numChecks
        symTop = zeros(nm, rowWeight);
        costTop = zeros(nm, rowWeight);
        for e = 1:rowWeight
            [sc, si] = sort(V2C(:,c,e), 'ascend');
            si = si(1:nm) - 1;                      % symbols (0-based)
            h  = H_val(c,e);
            if h == 0
                error('ldpcdecodegf64_ems:zeroCoeff', ...
                    'H_val coefficient must be nonzero (row %d, edge %d).', c, e);
            end
            symTop(:,e)  = gf_mul(h+1, si+1);        % field element, no -1
            costTop(:,e) = sc(1:nm);
        end
        for e = 1:rowWeight
            others = [1:e-1, e+1:rowWeight];
            cs = symTop(:,others(1)); cc = costTop(:,others(1));
            for j = 2:numel(others)
                [cs, cc] = ems_combine_messages(cs, cc, ...
                    symTop(:,others(j)), costTop(:,others(j)), nm);
            end
            h = H_val(c,e);
            origSym = gf_div(cs+1, h+1);             % field element, no -1
            surrogate = max(cc);
            dense = repmat(surrogate, q, 1);
            dense(origSym+1) = cc;
            C2V(:,c,e) = dense;
        end
    end

    % ===== Variable-node update (vectorized gather via varEdges) =====
    C2Vflat = reshape(C2V, q, numChecks*rowWeight);
    V2Cflat = reshape(V2C, q, numChecks*rowWeight);
    for v = 1:numVars
        e_idx = varEdges{v};
        total = sym_llr(:,v) + sum(C2Vflat(:, e_idx), 2);
        offset = min(total);
        total = total - offset;
        [~, idx] = min(total);
        decoded(v) = idx - 1;
        outgoing = total - C2Vflat(:, e_idx) + offset;
        if nm < q
            for k = 1:numel(e_idx)
                outgoing(:,k) = ems_truncate(outgoing(:,k), nm);
            end
        end
        V2Cflat(:, e_idx) = outgoing;
    end
    V2C = reshape(V2Cflat, q, numChecks, rowWeight);

    % ===== Syndrome check =====
    success = true;
    for c = 1:numChecks
        sumGF = 0;
        for e = 1:rowWeight
            sumGF = bitxor(sumGF, gf_mul(H_val(c,e)+1, decoded(H_idx(c,e))+1));
        end
        if sumGF ~= 0, success = false; break; end
    end
    if success
        info.success = true; info.iterations = iter; info.syndrome = true;
        return;
    end
end
info.syndrome = success;
end