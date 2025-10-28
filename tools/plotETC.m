function plotETC(h, fs)

Nchannels = size(h,2);

% Compute Energy Time Curve (ETC)
etcLog = 10*log10(h.^2);
%etcLog = etcLog - max(etcLog, [], 1);   % normalize to 0 dB for each channel

% Create time vector
t = (0:size(h, 1)-1) / fs; 

% Plot each channel in separate subplot
figure;
hold on
for i = 1:Nchannels
    plot(t, etcLog(:, i));
    grid on
end
xlabel('Time (s)');
ylabel('Energy (dB)');
title('Energy Time Curve');
yline(-60, '--k', 'LineWidth', 1.2, 'Label','-60 dB','LabelHorizontalAlignment','left');
legend("Channel 1", "Channel 2", '')
xlim([0,8]);
hold off

% Link x-axes for easier comparison
linkaxes(findall(gcf,'type','axes'), 'x');


