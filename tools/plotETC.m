function plotETC(h, fs)

Nchannels = size(h,2);

% Compute Energy Time Curve (ETC)
etcLog = 10*log10(h.^2);
% etcLog = etcLog - max(etcLog, [], 1);   % normalize to 0 dB for each channel

% Create time vector
t = (0:size(h, 1)-1) / fs; 

% Plot each channel in separate subplot
figure;
hold on;
legends = cell(1, Nchannels);  % preallocate cell array for legend labels

for i = 1:Nchannels
    plot(t, etcLog(:, i));
    xlabel('Time (s)');
    ylabel('Energy (dB)');
    title('Energy Time Curve for both channels');
    legends{i} = sprintf('Channel %d', i);  % store legend text
    grid on;
end

legend(legends)
hold off;


% Link x-axes for easier comparison
linkaxes(findall(gcf,'type','axes'), 'x');


