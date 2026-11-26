function jsim_plot_field(ax, R)
% Electric field (numerical Poisson solution and depletion approximation).
E = R.E/1e3; Ed = R.Edep/1e3;              % kV/cm
yl = jsim_ylim(E, Ed, 0);
jsim_prep_axes(ax, R, yl);
plot(ax, R.xm, E, 'Color', [0.1 0.3 0.8], 'LineWidth', 1.8, 'DisplayName', 'Poisson');
plot(ax, R.xm, Ed, '--', 'Color', [0.65 0.33 0.05], 'LineWidth', 1.3, 'DisplayName', 'depletion approx.');
plot(ax, R.x([1 end]), [0 0], 'k-', 'LineWidth', 0.5, 'HandleVisibility', 'off');
if jsim_isoctave()
    ylabel(ax, 'Field E (kV/cm)'); title(ax, 'Electric field');
else
    ylabel(ax, '$\mathcal{E}$ (kV/cm)', 'Interpreter', 'latex');
    title(ax, 'Electric field $\mathcal{E}(x)$', 'Interpreter', 'latex');
end
legend(ax, 'Location', 'best', 'FontSize', 7);
end
