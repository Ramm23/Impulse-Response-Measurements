%% Clear stuff
clear
close all
clc

%% Install subfolders
%addpath irs
addpath signals
addpath tools

%%Formatting stuff
set(groot, 'defaultAxesFontName', 'Times New Roman');
set(groot, 'defaultTextFontName', 'Times New Roman');
set(groot, 'defaultAxesFontSize', 16);
set(groot, 'defaultTextFontSize', 16);
set(groot, 'defaultAxesLineWidth', 1);
set(groot, 'defaultLineLineWidth', 2);
set(groot, 'defaultFigurePaperUnits', 'centimeters');
set(groot, 'defaultFigurePaperPosition', [0 0 14 9]); %base x height of figure


%% user parameters
% Sampling frequency
fsHz = 48E3;

% Impulse response
load 22001_module1_measurements\meas_2025_10_8_13_7_24.mat

%% LOAD RESPONSE
%
% Load impulse response
%h = readIR(roomName,fsHz);
h = h_norm;
%% Plot the ETC

plotETC(h_norm, fs)
%% Plot the spectrograms
N = 2*round(fs*20e-3/2);
M = pow2(nextpow2(N));
w = hann(N);
R = M/2;

[X1,t,f] = stft(h_norm(:,1),fs,w,R,M);
[X2,t,f] = stft(y(:,1),fs,w,R,M);

% 
plotSTFT(t,f,X1,fs)
plotSTFT(t,f,X2,fs)
%% Trunacte and select which IRs to process
% Truncate the IR (if needed) to remove most of the part that is just noise,
% keeping a short part to allow estimating the noise floor.

% h =

%% Calculate the EDC and reverberation time
% Choose an appropriate truncation time for the EDC calculation
trunctime = 3.5;

% Calculate the EDC
%[ EDC_log_true, t_true ] = calcEDC( h, fsHz, 12);
[ EDC_log, t ] = calcEDC( h, fsHz, trunctime );
%PLOYFIT THESE CURVES!!!!

% Choose appropriate fitting points for the RT60 calculation
L1 = -5;   % e.g., -5
L2 = -35;   % e.g., -25

% Select which EDC to process
% Calculate  the reverberation time
[reverbTime1, t1, y1] = getReverbTime( EDC_log(:,1), fsHz, L1, L2);
[reverbTime2, t2, y2] = getReverbTime( EDC_log(:,2), fsHz, L1, L2);


% Plot the EDC
figure;
hold on;
plot(t, EDC_log(:,1), 'LineWidth', 1.5);
plot(t1, y1, '--', 'LineWidth', 1.5)
grid on;

% Reference lines
yline(-5,  '--k', 'LineWidth', 1.2, 'Label','-5 dB','LabelHorizontalAlignment','left');
yline(-35, '--k', 'LineWidth', 1.2, 'Label','-35 dB','LabelHorizontalAlignment','left');
yline(-60, '--k', 'LineWidth', 1.2, 'Label','-60 dB','LabelHorizontalAlignment','left');

xlabel('Time (s)');
ylabel('Energy Decay [dB]');
title('Energy Decay Curve (EDC) - Channel 1');
ylim([-70 5]);   % adjust as needed
xlim([0 t(end)]);
legend("EDC","lin. fit",'','','','Location','southwest')
text(0.98, 0.98, sprintf('T_{30} = %.2f s', reverbTime1),'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'Units','normalized');
hold off;

figure;
hold on;
plot(t, EDC_log(:,2), 'LineWidth', 1.5);
plot(t2, y2, '--', 'LineWidth', 1.5)
grid on;

% Reference lines
yline(-5,  '--k', 'LineWidth', 1.2, 'Label','-5 dB','LabelHorizontalAlignment','left');
yline(-35, '--k', 'LineWidth', 1.2, 'Label','-35 dB','LabelHorizontalAlignment','left');
yline(-60, '--k', 'LineWidth', 1.2, 'Label','-60 dB','LabelHorizontalAlignment','left');

xlabel('Time (s)');
ylabel('Energy Decay [dB]');
title('Energy Decay Curve (EDC) - Channel 2');
ylim([-70 5]);   % adjust as needed
xlim([0 t(end)]);
legend("EDC","lin. fit",'','','','Location','southwest')
text(0.98, 0.98, sprintf('T_{30} = %.2f s', reverbTime2),'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'Units','normalized');
hold off



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
