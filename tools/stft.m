function [X,t,f] = stft(x,fs,w,R,M)


Nx = length(x);         % Signal duration
N = numel(w);           % Window size
O = N-R; % Overlap between adjacent windows R = shifts between adjacent windows (step size of frames)
L = ceil((Nx - O) / R); % Number of frames


% Zero-pad signal so last frame is complete
pad_size = max(0, (O + L*R) - Nx); % max makes sure pad size is >= 0
zero_pad = zeros(pad_size, 1);
x_padded = [x; zero_pad];

X = zeros(N, L);                    % N=length of 1 FFT, L=number of fft's


f = (0:M-1)' * (fs / M);
t = (N/2 + (0:L-1)*R) / fs;         % Uses the center of each window

% Run through time signal and do DFT frame by frame
for i = 0:L - 1
    idx = (1:N) + i * R; % indices for sampling
    frame = x_padded(idx) .* w; % Apply window to the current frame
    X(:, i+1) = fft(frame, M); % Compute the M-point FFT so it zero-pads automatically
end



