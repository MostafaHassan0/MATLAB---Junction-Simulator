function jsim_plot_cv(ax1, ax2, R)
% C-V of each pn junction: Cj (nF/cm^2) and 1/Cj^2 (linear in V, intercept Vbi).
for a = [ax1 ax2], jsim_legend_off(a); cla(a); hold(a, 'on'); box(a, 'on'); grid(a, 'on'); set(a, 'YScale', 'linear'); end
cv = R.cv.j;
if isempty(cv)
    for a = [ax1 ax2], text(a, 0.5, 0.5, 'no pn junction', 'Units', 'normalized', 'HorizontalAlignment', 'center'); end
    return
end
cols = [0.1 0.35 0.85; 0.85 0.15 0.15];
for j = 1:numel(cv)
    s = cv{j}; c = cols(j,:);
    plot(ax1, s.V, s.C*1e9, 'Color', c, 'LineWidth', 1.8, 'DisplayName', s.name);
    plot(ax1, s.Vop, s.Cop*1e9, 'o', 'Color', c, 'MarkerFaceColor', c, 'HandleVisibility', 'off');
    y = 1./(s.C*1e9).^2;
    plot(ax2, s.V, y, 'Color', c, 'LineWidth', 1.8, 'DisplayName', sprintf('%s, V_{bi} = %.2f V', s.name, s.Vbi));
    plot(ax2, s.Vop, 1/(s.Cop*1e9)^2, 'o', 'Color', c, 'MarkerFaceColor', c, 'HandleVisibility', 'off');
end
xlabel(ax1, 'V (V, forward +)'); ylabel(ax1, 'C_j (nF/cm^2)'); title(ax1, 'Depletion capacitance');
xlabel(ax2, 'V (V, forward +)'); ylabel(ax2, '1/C_j^2 (cm^4/nF^2)'); title(ax2, '1/C_j^2: slope gives N, intercept gives V_{bi}');
legend(ax1, 'Location', 'northwest', 'FontSize', 7); legend(ax2, 'Location', 'northeast', 'FontSize', 7);
end
