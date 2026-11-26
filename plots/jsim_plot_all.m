function figs = jsim_plot_all(R, visible)
% JSIM_PLOT_ALL  Draw every plot in ordinary figure windows (for saving,
% printing or when no GUI is wanted).  Returns the three figure handles.
if nargin < 2, visible = 'on'; end
figs(1) = figure('Name', 'Junction plots', 'Position', [40 40 1800 1000], 'Visible', visible, 'Color', 'w');
ax = zeros(1,6); for k = 1:6, ax(k) = subplot(2, 3, k, 'Parent', figs(1)); end
jsim_plot_bands(ax(1), R); jsim_plot_field(ax(2), R); jsim_plot_potential(ax(3), R);
jsim_plot_charge(ax(4), R); jsim_plot_carriers(ax(5), R); jsim_plot_alignment(ax(6), R);
figs(2) = figure('Name', 'I-V', 'Position', [60 60 1100 450], 'Visible', visible, 'Color', 'w');
jsim_plot_iv(subplot(1,2,1,'Parent',figs(2)), subplot(1,2,2,'Parent',figs(2)), R);
figs(3) = figure('Name', 'C-V', 'Position', [80 80 1100 450], 'Visible', visible, 'Color', 'w');
jsim_plot_cv(subplot(1,2,1,'Parent',figs(3)), subplot(1,2,2,'Parent',figs(3)), R);
end
