function results = runSimulation(params,snr,useEMS,nm)

if nargin < 3
    useEMS = false;
end

if nargin < 4
   
end
%RUNSIMULATION Execute the complete Non-Binary LDPC transmission chain.

%% Configuration



%% Generate Message

dataBits = randi([0 1],234,1);

txBits = generateNavigationMessage( ...
    14,...
    10,...
    100000,...
    dataBits);

%% Convert to GF Symbols

symbols = bitsToGF64(txBits);

%% Encode

encodedSymbols = ldpcencodegf64( ...
    symbols,...
    params.B_inv_A_gf);

%% Convert to Bits

encodedBits = gf64ToBits(encodedSymbols);

%% Channel

[~,llr] = channel_awgn(encodedBits,snr);

%% Symbol Costs

symLLR = llr2gf64(llr);

%% Decode

if useEMS

    [decodedSymbols,info] = ldpcdecodegf64_ems( ...
        symLLR,...
        params.H_idx,...
        params.H_val,...
        params.gf_mul,...
        params.gf_div,...
        params.maxIter,...
        nm);

else

    [decodedSymbols,info] = ldpcdecodegf64( ...
        symLLR,...
        params.H_idx,...
        params.H_val,...
        params.gf_mul,...
        params.gf_div,...
        params.maxIter);

end

%% Convert Back

decodedBits = gf64ToBits(decodedSymbols);

decodedBits = decodedBits(1:length(txBits));



%% BER

decodedBits = decodedBits(1:length(txBits));

[ber, bitErrors] = calculateBER(txBits, decodedBits);

%% Store Results

results.BER = ber;
results.BitErrors = bitErrors;
results.TotalBits = length(txBits);

results.DecoderSuccess = info.success;
results.Iterations = info.iterations;
results.SNR = snr;

if useEMS
    results.Decoder = "EMS";
    results.TopM = nm;
else
    results.Decoder = "MinSum";
    results.TopM = 64;
end
results.TopM = nm;

end