clear
clc
close all

addpath(genpath("src"))

fprintf("\n");
fprintf("=======================================\n");
fprintf(" Non-Binary LDPC Demonstration\n");
fprintf("=======================================\n\n");

params = loadLDPCParameters();
useEMS = true;
nm = 16;

results = runSimulation(params,3,useEMS,nm);

fprintf("\n=============================\n");
fprintf("Simulation Results\n");
fprintf("=============================\n");

fprintf("Decoder : %s\n", results.Decoder);

if results.Decoder == "EMS"
    fprintf("Top-M   : %d\n", results.TopM);
end

fprintf("BER     : %.3e\n", results.BER);
fprintf("Success : %d\n", results.DecoderSuccess);
fprintf("Iterations : %d\n", results.Iterations);

disp(results)