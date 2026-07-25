function params = loadLDPCParameters()

[gf_exp,gf_log,gf_mul,gf_div] = buildGF();

params = buildParityCheckMatrix();

params.gf_exp = gf_exp;
params.gf_log = gf_log;
params.gf_mul = gf_mul;
params.gf_div = gf_div;

params.fieldOrder = 64;
params.bitsPerSymbol = 6;
params.messageLength = 48;
params.codewordLength = 96;
params.maxIter = 20;

end