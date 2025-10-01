function [ rt60, t, y] = getReverbTime( EDCdB, fs, L1, L2, Ldir )
% Returns the reverberation time given the logarithmic normalized 
% EDC, by fitting a line between two points on the EDC at 
% levels L1 and L2.
%
%USAGE
%         [ rt60 ] = getReverbTime( edc, fs, L1, L2 )
%   [ rt60, t, y ] = getReverbTime( edc, fs, L1, L2, Ldir )
%  
%INPUT ARGUMENTS
%        edc : logarithmic EDC (N samples long) [N x 1]
%         fs : sampling rate in Hz
%         L1 : Starting level for line fitting. (default -5 dB)
%         L2 : End level for line fitting. (default -25 dB)
%       Ldir : Threshold level drop in EDC for finding 
%              the start of the IR. (default -1 dB)

%OUTPUT ARGUMENTS
%    rt60 : Estimated reverberation time.
%       t : Time vector for the linear fit (for plotting).
%       y : EDC values for the linear fit (for plotting).   

% Check input arguments
if nargin < 5 || isempty(Ldir), Ldir = -1; end
if nargin < 4 || isempty(L2), L2 = -25; end
if nargin < 3 || isempty(L1), L1 = -5; end

if ~isvector(EDCdB)
    error('Only one EDC is processed at a time.');
else
    EDCdB = EDCdB(:);
end
% Indices and actual levels
ind1  = find(EDCdB <= L1, 1, 'first');
ind2 = find(EDCdB <= L2, 1, 'first');
indmax = find(EDCdB <= Ldir, 1, 'first'); 
L1a = EDCdB(ind1);
L2a = EDCdB(ind2);

% Fitting line y = m*(t*fs)+b

m = (L2a - L1a) / (ind2 - ind1);
b = L1 - m*ind1;

% Calculate -60 dB intercept
%indrt = (-60 - b)/m;
indrt = (-60)/m;
%rt60 = (indrt - indmax)/fs;
rt60 = (indrt)/fs;

% Create time vector for plotting
t = (0:size(EDCdB,1)).' / fs;
y = m*t*fs+b;

% Plotting
if nargout == 0
    plot(t(1:size(EDCdB,1)),EDCdB,t,y); hold on;
    legend({'EDC','lin. fit'});
    plot(ind1/fs,L1a,'ko',ind2/fs,L2a,'ko');
    line([rt60 rt60],[0 -80],'LineStyle','--');
    ylim([-80 0]);
    xlabel('T [s]'); ylabel('EDC [dB]');
    title(sprintf('RT_{60} = %.2f s',rt60));
end
end

