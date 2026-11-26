% RUN_EXAMPLES  Simulate a few devices without the GUI and save the plots
% as PNG files in ./figs.  Edit the list to try your own stacks.
% Works in MATLAB and in GNU Octave.
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'core'), fullfile(root, 'plots'));
M = jsim_load_materials(root);
out = fullfile(root, 'figs'); if ~exist(out, 'dir'), mkdir(out); end

%        file tag      materials (left to right)                    types  doping (cm^-3)      bias [J1 J2], forward +
ex = { 'si_pn_fwd',  {'Si','Si'},                                  'pn',  [1e17 1e16],        [0.5 0]
       'si_pn_rev',  {'Si','Si'},                                  'pn',  [1e17 1e16],        [-5 0]
       'shbt',       {'InP','In0.53Ga0.47As','In0.53Ga0.47As'},    'npn', [5e17 1e19 5e16],   [0.7 -1.5]
       'dhbt',       {'InP','In0.53Ga0.47As','InP'},               'npn', [5e17 1e19 5e16],   [0.7 -1.5] };
for k = 1:size(ex, 1)
    cfg = jsim_config(M, ex{k,2}, ex{k,3}, ex{k,4}, ex{k,5});
    R = jsim_simulate(cfg);
    fprintf('\n===== %s =====\n', ex{k,1}); fprintf('%s\n', R.summary{:});
    f = jsim_plot_all(R, 'off');
    tags = {'bands', 'IV', 'CV'};
    for i = 1:3
        print(f(i), fullfile(out, sprintf('%s_%s.png', ex{k,1}, tags{i})), '-dpng', '-r110');
    end
    close(f);
end
