function [rxSignal,llr,noiseVariance] = channel_awgn(txBits,snrDB)
%CHANNEL_AWGN Transmit a binary codeword through a BPSK AWGN channel.
%
% Syntax
%   [rxSignal,llr,noiseVariance] = channel_awgn(txBits,snrDB)
%
% Inputs
%   txBits   - Binary column vector
%   snrDB    - Signal-to-noise ratio (dB)
%
% Outputs
%   rxSignal      - Received noisy BPSK symbols
%   llr           - Bit log-likelihood ratios
%   noiseVariance - AWGN variance
%
% Example
%   [rx,llr,n0] = channel_awgn(bits,3);

arguments
    txBits (:,1) double
    snrDB (1,1) double
end

%% Validate input

if any(txBits~=0 & txBits~=1)
    error("Input must contain only binary values.");
end

%% BPSK modulation
%
% 0 -> +1
% 1 -> -1

txSignal = 1 - 2*txBits;

%% Noise variance

snrLinear = 10^(snrDB/10);

% Match the original Simulink AWGN block
noiseVariance = 1/snrLinear;

%% AWGN

noise = sqrt(noiseVariance)*randn(size(txSignal));

rxSignal = txSignal + noise;

%% Bit LLR

llr = 2*rxSignal/noiseVariance;

end