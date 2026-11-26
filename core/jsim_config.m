function cfg = jsim_config(M, names, types, N, V, W)
% JSIM_CONFIG  Build a configuration from material names (scripts/tests).
%   cfg = jsim_config(M, {'Si','Si'}, 'np', [1e17 1e16], 0.0)
if nargin < 6, W = nan(1, numel(names)); end
for k = 1:numel(names)
    i = find(strcmp({M.name}, names{k}), 1);
    if isempty(i), error('jsim:material', 'material "%s" not found', names{k}); end
    cfg.layers(k).mat = M(i); cfg.layers(k).type = types(k);
    cfg.layers(k).N = N(k);  cfg.layers(k).W = W(k);
end
cfg.V = [V(:)' zeros(1, 2)];
end
