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
Tsweep = 2;         %s time for sweep           (I put 2 here)
Tsilence = 1; %s silence following sweep        (I put 1 here)
fstart = 5;         %Hz, Start frequency
fstop = fs/2;       %Hz,  Stop frequency
Tfadein = 0.1;   %s, Length of fade in 
Tfadeout = 4/fs;       %s, Length of fade out
Ttotal = Tsweep + Tsilence;       %s, total time for sweep + silence

channelsRec = [5 6]; %Which soundcard channels to record on
channelsPlay = 1; % Which soundcard channel to play on

%% Generate sweep signal
s_exp = genMeasSig(Tsweep,fs,fstart,fstop,Tsilence,Tfadein,Tfadeout);

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

%% Plot the spectrograms

%% Save and add variables of importance
save(sprintf('meas_%d_%d_%d_%d_%d_%d.mat',fix(clock)),'s_exp','Hinv','y','h_norm','fs');
% audiowrite(['irs\latest_measured_' int2str(Ttotal) '.wav'],h_norm,fs,'BitsPerSample',24);
