function jsim_plot_bands(ax, R)
% Energy-band diagram: Ec, Ev, Ei and the quasi-Fermi levels EFn, EFp (eV).
yl = jsim_ylim(R.Ec, R.Ev, R.EFn, R.EFp);
yl(1) = yl(1) - 0.14*diff(yl);                 % room for the layer labels
jsim_prep_axes(ax, R, yl);
h1 = plot(ax, R.x, R.Ec, 'Color', [0.10 0.35 0.85], 'LineWidth', 1.8, 'DisplayName', 'E_c');
h2 = plot(ax, R.x, R.Ev, 'Color', [0.85 0.15 0.15], 'LineWidth', 1.8, 'DisplayName', 'E_v');
h3 = plot(ax, R.x, R.Ei, ':', 'Color', [0.35 0.35 0.35], 'LineWidth', 1.2, 'DisplayName', 'E_i');
h4 = plot(ax, R.x, R.EFn, '--', 'Color', [0.0 0.6 0.25], 'LineWidth', 1.5, 'DisplayName', 'E_{Fn}');
h5 = plot(ax, R.x, R.EFp, '-.', 'Color', [0.75 0.1 0.7], 'LineWidth', 1.5, 'DisplayName', 'E_{Fp}');
hr = jsim_region_legend(ax);
% layer labels along the bottom
L = R.dev.L; edges = [0 R.xi R.x(end)];
for k = 1:numel(L)
    yt = yl(1) + (0.035 + 0.06*mod(k+1, 2))*diff(yl);   % staggered so thin layers do not collide
    text(ax, (edges(k) + edges(k+1))/2, yt, ...
        sprintf('%s-%s %.0e', L(k).type, L(k).name, L(k).N), 'HorizontalAlignment', 'center', ...
        'FontSize', 8, 'FontWeight', 'bold', 'Interpreter', 'none', 'HandleVisibility', 'off');
end
ylabel(ax, 'Energy (eV)');
title(ax, 'Energy-band diagram');
legend(ax, [h1 h2 h3 h4 h5 hr], 'Location', 'eastoutside', 'FontSize', 7);
end
