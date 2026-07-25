function symLLR = llr2gf64(llr)
%LLR2GF64 Convert bit LLRs into GF(64) symbol costs.

arguments
    llr (:,1) double
end

if numel(llr) ~= 576
    error("Input must contain exactly 576 LLR values.");
end

%% Clamp
llr = max(min(llr,1000),-1000);

%% Reshape into one column per GF symbol
% 6 x 96

llr = reshape(llr,6,96);

%% Precompute candidate bit patterns once
persistent candidateBits

if isempty(candidateBits)

    candidateBits = false(64,6);

    for c = 0:63
        candidateBits(c+1,:) = logical(bitget(c,6:-1:1));
    end

end

%% Allocate
symLLR = zeros(64,96);

%% Compute costs
for s = 1:96

    L = llr(:,s).';

    positivePenalty = max(L,0);
    negativePenalty = max(-L,0);

    symLLR(:,s) = ...
        candidateBits*positivePenalty.' + ...
        (~candidateBits)*negativePenalty.';

end

end