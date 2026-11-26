function jsim_plot_iv(ax1, ax2, R)
% I-V: diode (log |J| and linear J) or transistor (Gummel plot and output curves).
iv = R.iv;
for a = [ax1 ax2], jsim_legend_off(a); cla(a); hold(a, 'on'); box(a, 'on'); grid(a, 'on'); set(a, 'YScale', 'linear'); end
switch iv.type
    case 'diode'
        set(ax1, 'YScale', 'log');
        plot(ax1, iv.V, abs(iv.J), 'k', 'LineWidth', 1.8, 'DisplayName', '|J| total');
        plot(ax1, iv.V, abs(iv.Jdiff), '--', 'Color', [0.1 0.35 0.85], 'LineWidth', 1.2, 'DisplayName', 'diffusion (Shockley)');
        plot(ax1, iv.V, abs(iv.Jgr), '-.', 'Color', [0.85 0.4 0.0], 'LineWidth', 1.2, 'DisplayName', 'SCR recomb./generation');
        if abs(iv.Jop) > 0
            plot(ax1, iv.Vop, abs(iv.Jop), 'ro', 'MarkerFaceColor', 'r', 'DisplayName', 'operating point');
        end
        xlabel(ax1, 'V (V, forward +)'); ylabel(ax1, '|J| (A/cm^2)');
        title(ax1, 'Diode I-V (log scale)'); legend(ax1, 'Location', 'southeast', 'FontSize', 7);
        k = iv.V > -0.2;
        plot(ax2, iv.V(k), iv.J(k), 'k', 'LineWidth', 1.8);
        plot(ax2, iv.Vop, iv.Jop, 'ro', 'MarkerFaceColor', 'r');
        xlabel(ax2, 'V (V, forward +)'); ylabel(ax2, 'J (A/cm^2)');
        title(ax2, 'Diode I-V (linear)');
    case 'bjt'
        set(ax1, 'YScale', 'log');
        plot(ax1, iv.VBE, abs(iv.IC), 'Color', [0.1 0.35 0.85], 'LineWidth', 1.8, 'DisplayName', '|J_C|');
        plot(ax1, iv.VBE, abs(iv.IB), 'Color', [0.85 0.15 0.15], 'LineWidth', 1.8, 'DisplayName', '|J_B|');
        o = iv.op;
        plot(ax1, o.VBE, abs(o.IC), 'bo', 'MarkerFaceColor', 'b', 'HandleVisibility', 'off');
        plot(ax1, o.VBE, abs(o.IB), 'ro', 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
        xlabel(ax1, 'V_{BE} (V, forward +)'); ylabel(ax1, '|J| (A/cm^2)');
        title(ax1, sprintf('Gummel plot (V_{BC} = %+.2f V), \\beta = %.3g', o.VBC, o.beta));
        legend(ax1, 'Location', 'southeast', 'FontSize', 7);
        for i = 1:numel(iv.VBEset)
            plot(ax2, iv.VCE, iv.ICout(i,:), 'LineWidth', 1.5, 'DisplayName', sprintf('V_{BE} = %.2f V', iv.VBEset(i)));
        end
        plot(ax2, iv.VCEop, o.IC, 'ko', 'MarkerFaceColor', 'k', 'DisplayName', 'operating point');
        top = max([iv.ICout(:, end); o.IC]);
        ylim(ax2, [-0.1*top, 1.25*top]);        % saturation (both junctions forward) drives J_C negative
        xlabel(ax2, '|V_{CE}| (V)'); ylabel(ax2, 'J_C (A/cm^2, active mode +)');
        title(ax2, 'Output characteristics: saturation | active (Early effect)');
        legend(ax2, 'Location', 'southeast', 'FontSize', 7);
    otherwise
        for a = [ax1 ax2]
            text(a, 0.5, 0.5, iv.msg, 'HorizontalAlignment', 'center', 'Units', 'normalized');
            set(a, 'XTick', [], 'YTick', []);
        end
end
end
