function plotETC(h, fs)

Nchannels = size(h,2);

% Compute Energy Time Curve (ETC)
etcLog = 10*log10(h.^2);
% etcLog = etcLog - max(etcLog, [], 1);   % normalize to 0 dB for each channel

% Create time vector
t = (0:size(h, 1)-1) / fs; 

% Plot each channel in separate subplot
figure;
for i = 1:Nchannels
    subplot(Nchannels, 1, i)
    plot(t, etcLog(:, i));
    xlabel('Time (s)');
    ylabel('Energy (dB)');
    title(['Energy Time Curve - Channel ' num2str(i)]);
    grid on
end

% Link x-axes for easier comparison
linkaxes(findall(gcf,'type','axes'), 'x');


