function h = jsim_region_legend(ax)
% invisible patches that put the region colours into a legend
c = jsim_region_colors(); h = zeros(1,3);
lab = {'quasi-neutral (QNR)', 'space charge: depleted', 'space charge: mobile (acc./inv.)'};
for k = 1:3
    h(k) = patch(ax, NaN(1,4), NaN(1,4), c(k,:), 'EdgeColor', 'none', 'FaceAlpha', 1, 'DisplayName', lab{k});
end
end
