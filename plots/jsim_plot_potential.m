function jsim_plot_potential(ax, R)
% Electrostatic potential psi(x) (V), referenced to the left contact.
yl = jsim_ylim(R.psi, R.psidep);
jsim_prep_axes(ax, R, yl);
plot(ax, R.x, R.psi, 'Color', [0.45 0.1 0.65], 'LineWidth', 1.8, 'DisplayName', 'Poisson');
plot(ax, R.x, R.psidep, '--', 'Color', [0.65 0.33 0.05], 'LineWidth', 1.3, 'DisplayName', 'depletion approx.');
ylabel(ax, '\psi(x) - \psi(0)  (V)');
title(ax, 'Electrostatic potential \psi(x)   (E_{vac} = -q\psi)');
legend(ax, 'Location', 'best', 'FontSize', 7);
end
