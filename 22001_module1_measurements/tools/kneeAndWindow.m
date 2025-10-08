function [choice, fitRange_dB, t_knee] = kneeAndWindow(h, fs)
% Minimal knee + window picker from an IR.
% Inputs:  h  (impulse response), fs (Hz)
% Outputs: choice ('T30'|'T20'|'T10'|'INSUFFICIENT_DR'), fitRange_dB, t_knee (s)

% --- 1) ETC in dB (relative to peak) ---
h   = h(:);
t   = (0:numel(h)-1).' / fs;
pwr = h.^2;
pwr = pwr ./ max(pwr + eps);
ETC = 10*log10(pwr + eps);

% --- 2) Noise floor (median of last 20% of ETC) ---
tailStart = floor(numel(ETC)*0.8);
Ln = median(ETC(tailStart:end));     % dB rel. to peak

% --- 3) Early-decay line fit (from -5 dB down to max(-25, Ln+10)) ---
L1 = -5;                                 % top of fit
L2fit = max(-25, Ln + 10);               % keep ≥10 dB above noise
mask = (ETC <= L1) & (ETC >= L2fit);
if ~any(mask)
    % fallback: use a narrow band just below -5 dB
    mask = (ETC <= -5) & (ETC >= -15);
end
p = polyfit(t(mask), ETC(mask), 1);      % L(t) = b + m t
m = p(1); b = p(2);

% --- 4) Knee: intersection of early fit with noise floor ---
t_knee = (Ln - b) / m;
t_knee = max(0, min(t_knee, t(end)));    % clamp to [0, end]

% --- 5) Choose T30 → T20 → T10 with 10 dB safety over noise & pre-knee ---
cands = {[-5 -35] 'T30'; [-5 -25] 'T20'; [-5 -15] 'T10'};
choice = 'INSUFFICIENT_DR'; fitRange_dB = [NaN NaN];
for k = 1:size(cands,1)
    L = cands{k,1}; label = cands{k,2};
    L1c = L(1); L2c = L(2);
    % Safety over noise: bottom must be ≥10 dB above noise
    hasHeadroom = (L2c <= Ln - 10);
    % Predicted time to reach bottom (from the fitted line) must be pre-knee
    t_at_L2 = (L2c - b)/m;
    preKnee = t_at_L2 <= t_knee;

    if hasHeadroom && preKnee
        choice = label; fitRange_dB = L;
        break
    end
end
end
