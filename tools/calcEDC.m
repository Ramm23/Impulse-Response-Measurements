function [ EDCdB, t ] = calcEDC( h, fs, trunctime )
% Returns the logarithmic energy decay curve for a given impulse response.
%
%USAGE
%   [EDC_log, t] = calcEDC(h, fs)
%  
%INPUT ARGUMENTS
%          h : M channel impulse response (N samples long) [N x M]
%         fs : sampling rate in Hz
%    tructime: Time in [s] at which IR is truncated before calculating the
%              EDC.

%OUTPUT ARGUMENTS
%    EDC_log : logarithmic energy decay curve [tSamples x M]
%          t : time vector [tSamples x 1]

if nargin < 3 || isempty(trunctime) || (trunctime * fs) > size(h,1)
    tSample = size(h,1);
else 
    tSample = floor(trunctime * fs);
end

% Truncate
h = 

%% Calculate EDC


% Return time vector
t = 
end

