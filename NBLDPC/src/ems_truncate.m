function msg = ems_truncate(msg, nm)
%EMS_TRUNCATE Truncate a GF(64) message to its Top-M candidates.
% Keeps nm smallest-cost symbols; others get surrogate = nm-th smallest cost.
% Inputs: msg (Qx1 cost vector), nm (Top-M, 1<=nm<=Q). Output: msg (Qx1).
q = numel(msg);
if ~isscalar(nm) || nm < 1 || nm > q || nm ~= floor(nm)
    error('ems_truncate:invalidNm','nm must be an integer in [1,%d].', q);
end
if ~isvector(msg) || ~isreal(msg)
    error('ems_truncate:invalidMsg','msg must be a real Qx1 vector.');
end
if nm >= q
    return;
end
[sorted_costs, sorted_idx] = sort(msg, 'ascend');
surrogate = sorted_costs(nm);
if ~isfinite(surrogate)
    surrogate = min(sorted_costs(nm), realmax); % clip Inf surrogate
end
msg(sorted_idx(nm+1:end)) = surrogate;
end