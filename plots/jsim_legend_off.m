function jsim_legend_off(ax)
% remove an axes legend if there is one (works in MATLAB and Octave)
try, legend(ax, 'off'); catch, end
end
