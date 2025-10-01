%% Clear stuff
clear variables
clear mex
close all
clc
%% Add paths
addpath audio-playback tools
startupHeaAudio
%setpref('dsp','portaudioHostApi',3)  % Sets audio output API to ASIO

%% User parameters
fs = 48000;         %Hz, sampling frequency
Tsweep = 2;         %s, time for sweep          (choose appropriate length)
Tsilence = 1;       %s, silence following sweep (choose appropriate length)
fstart = 5;         %Hz, Start frequency
fstop = fs/2;       %Hz,  Stop frequency
Tfadein = 0.1;      %s, Length of fade in 
Tfadeout = 4/fs;    %s, Length of fade out
Ttotal = Tsweep + Tsilence;       %s, total time for sweep + silence

channelsRec = [5 6];    % Which soundcard channels to record on
channelsPlay = 1;       % Which soundcard channel to play on

%% Generate sweep signal
s_exp = genMeasSig(Tsweep,fs,fstart,fstop,Tsilence,Tfadein,Tfadeout);

%% Create the inverse filter
[hinv, Hinv] = getInverse(s_exp);

%% Reconvolve with measurement signal as sanity check
d = getIR(s_exp, Hinv);         % Should generate a delta signal

%% Init audio object for sound recording and playback
ao = HeaAudioDSP;
ao.fs = fs;
% Select recording and playback channels
ao.channelsPlay = channelsPlay;
ao.channelsRec = channelsRec;

%% Play stimulus and record
disp('Measurement start.');
y = ao.playrec(s_exp);
disp('Measurement completed.');
%% Recover IR
h = getIR(y, Hinv);      % IR [Nlength x Mchannel]

h_norm = h ./ max(max(abs(h))); % Normalize IRs to the overall maximum
%% Plot the ETC


% Check dynamic range using plotETC
plotETC(h_norm, fs);




%% Plot the spectrograms


% 1. Create a window for STFT
M = 1024;                           % FFT size
win = hann(M);                      % Create window for STFT
R = 512;                            % Overlapping size


% 2. Compute STFT of recorded sweep (y)
[Y1, F1, T1] = stft(y(:,1), fs, win, R, M);     % STFT of channel 1
[Y2, F2, T2] = stft(y(:,2), fs, win, R, M);     % STFT of channel 2

% 3. Plot spectograms of recorded sweep signals (y)
plotSTFT(T1, F1, Y1, fs, false, 100)
plotSTFT(T2, F2, Y2, fs, false, 100)



% 4. Compute STFT of estimated system IR (h)
[H1, F1, T1] = stft(h(:,1), fs, win, R, M);     % STFT of channel 1
[H2, F2, T2] = stft(h(:,2), fs, win, R, M);     % STFT of channel 2

% 5. Plot spectograms of system IRs
plotSTFT(T1, F1, H1, fs, false, 100)
plotSTFT(T2, F2, H2, fs, false, 100)




%% Save and add variables of importance
save(sprintf('meas_%d_%d_%d_%d_%d_%d.mat',fix(clock)),'s_exp','Hinv','y','h_norm','fs');
% audiowrite(['irs\latest_measured_' int2str(Ttotal) '.wav'],h_norm,fs,'BitsPerSample',24);
