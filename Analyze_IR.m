%% Clear stuff
clear
close all
clc

%% Install subfolders
%addpath irs
addpath signals
addpath tools

%% user parameters
% Sampling frequency
fsHz = 48E3;

% Impulse response
load 22001_module1_measurements\meas_2025_10_8_12_29_20.mat

%% LOAD RESPONSE
%
% Load impulse response
%h = readIR(roomName,fsHz);
h = h_norm;
%% Trunacte and select which IRs to process
% Truncate the IR (if needed) to remove most of the part that is just noise,
% keeping a short part to allow estimating the noise floor.

% h =

%% Calculate the EDC and reverberation time
% Choose an appropriate truncation time for the EDC calculation
trunctime = 4;

% Calculate the EDC
[ EDC_log, t ] = calcEDC( h, fsHz, trunctime );

% Plot the EDC
figure;
plot(t, EDC_log, 'LineWidth', 1.5);
hold on; grid on;

% Reference lines
yline(-5,  '--k', 'LineWidth', 1.2, 'Label','-5 dB','LabelHorizontalAlignment','left');
yline(-25, '--k', 'LineWidth', 1.2, 'Label','-25 dB','LabelHorizontalAlignment','left');
yline(-60, '--k', 'LineWidth', 1.2, 'Label','-60 dB','LabelHorizontalAlignment','left');

xlabel('Time (s)');
ylabel('Energy Decay [dB]');
title('Energy Decay Curve (EDC)');
ylim([-70 5]);   % adjust as needed
xlim([0 t(end)]);
legend("Channel " + string(1:size(EDC_log,1)));

% Choose appropriate fitting points for the RT60 calculation
%[choice, fitRange_dB, t_knee] = simpleKneeAndWindow(h, fs);

L1 = -5;   % e.g., -5
L2 = -25;   % e.g., -25

% Select which EDC to process
% Calculate  the reverberation time
reverbTime1 = getReverbTime( EDC_log(:,1), fsHz, L1, L2)
reverbTime2 = getReverbTime( EDC_log(:,2), fsHz, L1, L2)

%% Direct-to-reverberant energy ratio
% Select IRs with different source to receiver distances

% Split the direct path and the reverberant tail
timeDirect = 1e-3;
[d,r] = splitIR(h(:,1:2),fsHz,timeDirect);

% Calculate the DRR
dLength = height(d);
rLength = height(r);

t_d = 0:1:dLength-1;
t_d = t_d/fs;
t_r = 0:1:rLength-1/fs;
t_r = t_r/fs;

drr = trapz(t_d, d.^2)./trapz(t_r, r.^2)

%% ENERGY DECAY RELIEF (STFT)
%
% Minimum EDR in dB
floordB = -60;
% Window size
winSec = 32*1e-3;

% Block size and step size
N = 2 * round(winSec * fsHz / 2);
R = round(N / 4);


% Create analysis and synthesis window function
w = cola(N,R,'hamming','ola');

% DFT size
M = pow2(nextpow2(N));

% STFT
[X1,t,f] = stft(h(:,1),fsHz,w,R,M);
[X2,t,f] = stft(h(:,2),fsHz,w,R,M);
% Energy decay relief in dB
P1 = abs(X1).^2;
P2 = abs(X2).^2;

EDR1 = fliplr(cumsum(fliplr(P1),2));
EDR2 = fliplr(cumsum(fliplr(P2),2));

% Normalize to 0 dB
EDR1 = EDR1 ./ max(EDR1,[],2); %normalization of each frequency bin to max 1 = 0DB
EDR2 = EDR2 ./ max(EDR2,[],2); %normalization of each frequency bin to max 1 = 0DB

EDRdB1 = 10*log10(EDR1); %convert to dB
EDRdB2 = 10*log10(EDR2); %convert to dB

% Truncate to floordB
EDRdB1(EDRdB1 < floordB) = floordB; % Truncate to floordB
EDRdB2(EDRdB2 < floordB) = floordB; % Truncate to floordB

% Plot the EDRdB
figure
imagesc(t, f*1e-3, EDRdB1, [floordB 0]);  % dB scale
ylim([0 fs/2*1e-3])
axis xy;
xlabel('Time (s)');
ylabel('Frequency (kHz)');
title('STFT-based Energy Decay Relief Curves - Channel 1');
colormap(colormapVoicebox);
colorbar;

% figure;
% mesh(t, f*1e-3, EDRdB1);  % dB scale
% ylim([0 fs/2*1e-3])
% xlabel('Time (s)');
% ylabel('Frequency (kHz)');
% zlabel('Energy(dB)')
% title('Mesh STFT-based Energy Decay Relief Curves - Channel 1');
