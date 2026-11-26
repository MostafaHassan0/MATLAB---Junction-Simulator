function jsim_plot_alignment(ax, R)
% Band line-up of the separate layers before contact (vacuum level = 0):
% shows dEc and dEv and each layer's Fermi level.
L = R.dev.L; nL = numel(L);
jsim_legend_off(ax); cla(ax); hold(ax, 'on'); box(ax, 'on'); set(ax, 'YScale', 'linear');
Ec = -[L.chi]; Ev = Ec - [L.Eg]; EF = -[L.Wf];
gap = 0.7; x0 = (0:nL-1)*(1 + gap);
for k = 1:nL
    xs = x0(k) + [0 1];
    hc = plot(ax, xs, Ec(k)*[1 1], 'Color', [0.10 0.35 0.85], 'LineWidth', 2.2);
    hv = plot(ax, xs, Ev(k)*[1 1], 'Color', [0.85 0.15 0.15], 'LineWidth', 2.2);
    hf = plot(ax, xs, EF(k)*[1 1], '--', 'Color', [0.0 0.6 0.25], 'LineWidth', 1.4);
    text(ax, mean(xs), 0.2 + 0.3*mod(k+1, 2), sprintf('%s-%s', L(k).type, L(k).name), 'HorizontalAlignment', 'center', ...
        'FontSize', 8, 'FontWeight', 'bold', 'Interpreter', 'none');
    text(ax, mean(xs), (Ec(k) + Ev(k))/2, sprintf('E_g = %.2f', L(k).Eg), 'HorizontalAlignment', 'center', 'FontSize', 7);
    text(ax, xs(1) + 0.03, Ec(k)/2, sprintf('\\chi = %.2f', L(k).chi), 'FontSize', 7);
    plot(ax, mean(xs)*[1 1], [0 Ec(k)], ':', 'Color', [0.5 0.5 0.5]);
end
for j = 1:nL-1
    xm = x0(j) + 1 + gap/2; J = R.dev.J(j);
    text(ax, xm, (Ec(j) + Ec(j+1))/2, sprintf('\\DeltaE_c\n%+.2f', J.dEc), 'HorizontalAlignment', 'center', 'FontSize', 7, 'Color', [0.10 0.35 0.85]);
    text(ax, xm, (Ev(j) + Ev(j+1))/2, sprintf('\\DeltaE_v\n%+.2f', J.dEv), 'HorizontalAlignment', 'center', 'FontSize', 7, 'Color', [0.85 0.15 0.15]);
end
hvac = plot(ax, [x0(1) x0(end) + 1], [0 0], 'k-', 'LineWidth', 1);
xlim(ax, [x0(1) - 0.1, x0(end) + 1.1]);
ylim(ax, [min(Ev) - 0.4, 0.75]);
set(ax, 'XTick', []);
ylabel(ax, 'Energy below vacuum (eV)');
title(ax, 'Band line-up before contact');
legend(ax, [hvac hc hv hf], {'E_{vac}', 'E_c', 'E_v', 'E_F (isolated)'}, 'Location', 'southoutside', 'Orientation', 'horizontal', 'FontSize', 7);
grid(ax, 'on');
end
