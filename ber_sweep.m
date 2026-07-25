%% BER Simulation

clear;
clc;

params = loadLDPCParameters();

snrVec = -4:0.5:8;

targetErrors = 1000;
maxFrames    = 5000;

useEMS = true;
topM   = 8;

BER = zeros(size(snrVec));
FER = zeros(size(snrVec));

fprintf('\nRunning BER Simulation...\n\n');

for k = 1:length(snrVec)

    snr = snrVec(k);

    totalErrors = 0;
    totalBits   = 0;

    frameErrors = 0;
    frameCount  = 0;

    while totalErrors < targetErrors && frameCount < maxFrames

        results = runSimulation(params,snr,useEMS,topM);

        frameCount = frameCount + 1;

        totalErrors = totalErrors + results.BitErrors;
        totalBits   = totalBits + results.TotalBits;

        if results.BitErrors > 0
            frameErrors = frameErrors + 1;
        end

    end

    BER(k) = totalErrors / totalBits;
    FER(k) = frameErrors / frameCount;

    fprintf('SNR = %4.1f dB | BER = %.3e | FER = %.3e | Frames = %4d\n',...
        snr,BER(k),FER(k),frameCount);

end

%% Plot

figure;

semilogy(snrVec,BER,'-o',...
    'LineWidth',2,...
    'MarkerSize',7);

grid on;
grid minor;

xlabel('E_b/N_0 (dB)');
ylabel('Bit Error Rate');

title(sprintf('GF(64) NB-LDPC (%s, Top-M=%d)',...
    results.Decoder,topM));

xlim([snrVec(1) snrVec(end)]);
ylim([1e-6 1]);

set(gca,'FontSize',12);

save('BER_results.mat','BER','FER','snrVec');