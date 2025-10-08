%% Init audio object for sound recording and playback
fs = 48000;
ao = HeaAudioDSP;
ao.fs = fs;
% Play on one, record on two channels
ao.channelsPlay = [];
ao.channelsRec = [5 6];

%% Record
N = 10*fs;
y = ao.rec(N);
audiowrite('irs\claps.wav',y,fs,'BitsPerSample',24);