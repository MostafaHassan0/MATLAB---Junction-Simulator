function jsim_prep_axes(ax, R, yl, logy)
% JSIM_PREP_AXES  Clear an axes and paint the region shading behind the data:
%   green  = quasi-neutral region (QNR)
%   orange = space-charge region, depleted (ionised dopants)
%   purple = space-charge region, mobile charge (accumulation/inversion)
% plus black lines at the metallurgical interfaces and dashed brown lines at
% the depletion-approximation edges.
if nargin < 4, logy = false; end
jsim_legend_off(ax); cla(ax); hold(ax, 'on'); box(ax, 'on');
if logy, set(ax, 'YScale', 'log'); else, set(ax, 'YScale', 'linear'); end
cols = jsim_region_colors();
for s = 1:size(R.seg, 1)
    a = R.seg(s,1); b = R.seg(s,2);
    patch(ax, [a b b a], [yl(1) yl(1) yl(2) yl(2)], cols(R.seg(s,3)+1,:), ...
        'EdgeColor', 'none', 'FaceAlpha', 1, 'HandleVisibility', 'off');
end
for k = 1:numel(R.xi)
    plot(ax, [R.xi(k) R.xi(k)], yl, '-', 'Color', [0.2 0.2 0.2], 'LineWidth', 1, 'HandleVisibility', 'off');
end
for e = R.depEdges
    plot(ax, [e e], yl, '--', 'Color', [0.65 0.33 0.05], 'LineWidth', 0.9, 'HandleVisibility', 'off');
end
% region names along the top edge
names = {'QNR', 'SCR', 'acc.'};
span = R.x(end) - R.x(1);
for s = 1:size(R.seg, 1)
    w = R.seg(s,2) - R.seg(s,1);
    if w > 0.045*span
        if logy, yt = 10^(log10(yl(2)) - 0.05*diff(log10(yl))); else, yt = yl(2) - 0.05*diff(yl); end
        text(ax, mean(R.seg(s,1:2)), yt, names{R.seg(s,3)+1}, 'HorizontalAlignment', 'center', ...
            'FontSize', 8, 'Color', [0.25 0.25 0.25], 'HandleVisibility', 'off');
    end
end
xlim(ax, [R.x(1) R.x(end)]); ylim(ax, yl);
xlabel(ax, 'x (\mum)');
grid(ax, 'on');
end
