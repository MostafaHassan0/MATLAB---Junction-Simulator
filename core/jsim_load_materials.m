function M = jsim_load_materials(root)
% JSIM_LOAD_MATERIALS  Read every material file in <root>/materials.
% Each file is a MATLAB function that returns a struct (see Si.m). Drop a
% new file in the folder and it appears in the selectors next time.
mdir = fullfile(root, 'materials');
addpath(mdir); addpath(fullfile(mdir, 'pairs'));
d = dir(fullfile(mdir, '*.m'));
M = struct([]);
for k = 1:numel(d)
    [~, fn] = fileparts(d(k).name);
    m = feval(fn);
    m.file = fn;
    if isfield(m, 'ni_override') && ~isempty(m.ni_override)
        s = m.ni_override/m.ni;          % keep Ei where it is, scale both DOS
        m.Nc = m.Nc*s; m.Nv = m.Nv*s; m.ni = m.ni_override;
    end
    m = orderfields(m);
    if isempty(M), M = m; else, M(end+1) = m; end %#ok<AGROW>
end
[~, i] = sort(lower({M.name}));
M = M(i);
end
