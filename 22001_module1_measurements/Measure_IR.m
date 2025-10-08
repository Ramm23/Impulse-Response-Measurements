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
Tsweep = 8;         %s time for sweep
Tsilence = 6; %s silence following sweep
fstart = 5;         %Hz, Start frequency
fstop = fs/2;       %Hz,  Stop frequency
Tfadein = 0.1;   %s, Length of fade in 
Tfadeout = 4/fs;       %s, Length of fade out
Ttotal = Tsweep + Tsilence;       %s, total time for sweep + silence

channelsRec = [1 2]; %Which soundcard channels to record on
channelsPlay = 1; % Which soundcard channel to play on

%% Generate sweep signal
s_exp = genMeasSig(Tsweep,fs,fstart,fstop,Tsilence,Tfadein,Tfadeout);
s_exp = db2mag(-50) * s_exp;

%% Create the inverse filter
[hinv, Hinv] = getInverse(s_exp);

%% Reconvolve with measurement signal as sanity check
d = getIR(s_exp, Hinv);

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
h = getIR(y,Hinv);
h_norm = h ./ max(max(abs(h))); % Normalize IRs to the overall maximum
%% Plot the ETC

plotETC(h_norm, fs)
%% Plot the spectrograms
N = 2*round(fs*20e-3/2);
M = pow2(nextpow2(N));
w = hann(M);
R = M/2;

[X1,t,f] = stft(h_norm(:,1),fs,w,R,M);
[X2,t,f] = stft(y(:,1),fs,w,R,M);
% 

plotSTFT(t,f,X1,fs)


plotSTFT(t,f,X2,fs)
%% Save and add variables of importance
save(sprintf('meas_%d_%d_%d_%d_%d_%d.mat',fix(clock)),'s_exp','Hinv','y','h_norm','fs','Tsweep','Tsilence');
% audiowrite([sprintf('meas_%d_%d_%d_%d_%d_%d.mat',fix(clock)) '.wav'],h_norm,fs,'BitsPerSample',24);
