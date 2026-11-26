function jsim_plot_carriers(ax, R)
% Electron and hole densities on a log scale, with doping and ni.
n = max(R.n, 1e-5); p = max(R.p, 1e-5);
top = max([n; p; abs(R.Nnet)]);
bot = max(min([n; p; R.ni]), top*1e-30);
yl = [max(bot/10, 1), top*100];       % densities below 1 cm^-3 are not shown
jsim_prep_axes(ax, R, yl, true);
plot(ax, R.x, n, 'Color', [0.1 0.35 0.85], 'LineWidth', 1.8, 'DisplayName', 'n');
plot(ax, R.x, p, 'Color', [0.85 0.15 0.15], 'LineWidth', 1.8, 'DisplayName', 'p');
plot(ax, R.x, abs(R.Nnet), 'k--', 'LineWidth', 1.1, 'DisplayName', '|N_d - N_a|');
plot(ax, R.x, R.ni, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.1, 'DisplayName', 'n_i');
ylabel(ax, 'Density (cm^{-3})');
title(ax, 'Carrier densities (log scale)');
legend(ax, 'Location', 'best', 'FontSize', 7);
end
