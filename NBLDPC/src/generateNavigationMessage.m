function txBits = generateNavigationMessage(prn, msgType, sow, dataBits)
%GENERATENAVIGATIONMESSAGE Generate a 288-bit navigation message.
%
% Syntax
%   txBits = generateNavigationMessage(prn,msgType,sow,dataBits)
%
% Description
%   Creates a navigation message consisting of:
%
%       PRN      : 6 bits
%       Type     : 6 bits
%       SOW      : 18 bits
%       Data     : 234 bits
%       CRC-24   : 24 bits
%
% Inputs
%   prn       Satellite PRN (0-63)
%   msgType   Navigation message type (0-63)
%   sow       Seconds Of Week (0-262143)
%   dataBits  234×1 binary vector
%
% Output
%   txBits    288×1 binary vector

arguments
    prn (1,1) double {mustBeInteger,mustBeGreaterThanOrEqual(prn,0),mustBeLessThanOrEqual(prn,63)}
    msgType (1,1) double {mustBeInteger,mustBeGreaterThanOrEqual(msgType,0),mustBeLessThanOrEqual(msgType,63)}
    sow (1,1) double {mustBeInteger,mustBeGreaterThanOrEqual(sow,0),mustBeLessThanOrEqual(sow,262143)}
    dataBits (234,1) double
end

%% Convert header fields to bits

prnBits  = decimalToBits(prn,6);
typeBits = decimalToBits(msgType,6);
sowBits  = decimalToBits(sow,18);

%% Compute CRC

payload = [prnBits;
    typeBits;
    sowBits;
    dataBits];

crcBits = crc24(payload);

%% Final message

txBits = [payload;
    crcBits];

end