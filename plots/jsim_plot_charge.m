function jsim_plot_charge(ax, R)
% Space-charge density rho/q = p - n + Nd - Na (cm^-3).
r = R.rho; rd = R.rhodep;
yl = jsim_ylim(r, rd, 0);
jsim_prep_axes(ax, R, yl);
plot(ax, R.x, r, 'Color', [0.15 0.15 0.15], 'LineWidth', 1.6, 'DisplayName', 'Poisson');
plot(ax, R.x, rd, '--', 'Color', [0.65 0.33 0.05], 'LineWidth', 1.3, 'DisplayName', 'depletion approx.');
plot(ax, R.x([1 end]), [0 0], 'k-', 'LineWidth', 0.5, 'HandleVisibility', 'off');
ylabel(ax, '\rho/q  (cm^{-3})');
title(ax, 'Charge density \rho(x)/q = p - n + N_d^+ - N_a^-');
legend(ax, 'Location', 'best', 'FontSize', 7);
end
