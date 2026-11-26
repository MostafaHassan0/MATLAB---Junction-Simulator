function JunctionSimulatorApp()
% JUNCTIONSIMULATORAPP  Interactive 1-D junction simulator (ELEC 6221).
%
%   Run:  >> JunctionSimulatorApp
%
% Pick 2 materials (pn homo/heterojunction or isotype n-N / p-P junction) or
% 3 materials (npn / pnp BJT or HBT), set each layer's doping (donors or
% acceptors) and the bias of each junction (forward or reverse).  The app
% solves Poisson's equation numerically (Fermi-Dirac statistics, abrupt band
% offsets) and overlays the depletion approximation.  Every position plot is
% shaded:  green = quasi-neutral region (QNR), orange = depleted space-charge
% region, purple = space charge from mobile carriers (accumulation/inversion);
% dashed brown lines = depletion-approximation edges, black lines = interfaces.
%
% Materials live in ./materials (one file per material, 300 K).  Band offsets
% for measured pairs are in ./materials/pairs/band_offsets.m.
% Needs MATLAB R2020b or newer (uifigure + uigridlayout).

root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'core'), fullfile(root, 'plots'));
M     = jsim_load_materials(root);
names = {M.name};
typeItems = {'Donors (n-type)', 'Acceptors (p-type)'};
R = [];                                   % last simulation result

% ---------------------------------------------------------------- presets
% built-in presets + your own saved presets (one .json file each in ./presets)
presetDir = fullfile(root, 'presets');
if ~isfolder(presetDir), mkdir(presetDir); end
P = [presets(), loadCustomPresets(presetDir)];

% ---------------------------------------------------------------- window
fig = uifigure('Name', 'Junction Simulator - ELEC 6221', 'Position', [30 40 1580 900]);
gl  = uigridlayout(fig, [1 2]);
gl.ColumnWidth = {350, '1x'}; gl.Padding = [6 6 6 6];

% ---------------------------------------------------------------- controls
cp = uipanel(gl, 'Title', 'Device'); cp.Layout.Row = 1; cp.Layout.Column = 1;
g  = uigridlayout(cp, [28 4]);
g.RowHeight = [repmat({24}, 1, 21), {'1x'}, repmat({24}, 1, 6)];
g.ColumnWidth = {'1.25x', '1x', '1x', '0.85x'}; g.RowSpacing = 5; g.Padding = [8 8 8 8];

lbl(1, 1, 'Preset');
ddPreset = uidropdown(g, 'Items', [{'(custom)'}, {P.label}], 'Value', '(custom)', ...
    'ValueChangedFcn', @(~,~) applyPreset());
put(ddPreset, 1, [2 4]);

h = lbl(2, [1 4], 'Layers (left to right)'); h.FontWeight = 'bold';
lbl(3, [1 2], 'Material / dopant type');
lbl(3, 3, 'N (cm^-3)');
lbl(3, 4, 'W (um)');

ddMat = cell(1,3); ddType = cell(1,3); efN = cell(1,3); efW = cell(1,3);
layerTitles = {'Layer 1 (left)', 'Layer 2', 'Layer 3 (right)'};
for k = 1:3
    r = 4 + 2*(k-1);
    lbl(r, 1, layerTitles{k});
    items = names; if k == 3, items = [{'none'}, names]; end
    ddMat{k} = uidropdown(g, 'Items', items, 'ValueChangedFcn', @(~,~) changed());
    put(ddMat{k}, r, [2 4]);
    ddType{k} = uidropdown(g, 'Items', typeItems, 'ValueChangedFcn', @(~,~) changed());
    put(ddType{k}, r+1, [1 2]);
    efN{k} = uieditfield(g, 'text', 'Value', '1e17', 'HorizontalAlignment', 'right', ...
        'ValueChangedFcn', @(~,~) changed());
    put(efN{k}, r+1, 3);
    efW{k} = uieditfield(g, 'numeric', 'Value', 0.5, 'Limits', [0.005 1000], ...
        'ValueDisplayFormat', '%.3g', 'ValueChangedFcn', @(~,~) changed());
    put(efW{k}, r+1, 4);
end
cbAuto = uicheckbox(g, 'Text', 'Automatic layer widths', 'Value', true, 'ValueChangedFcn', @(~,~) changed());
put(cbAuto, 10, [1 4]);

h = lbl(11, [1 4], 'Junction bias (V)'); h.FontWeight = 'bold';
efV = cell(1,2); ddDir = cell(1,2);
jt = {'J1 (layers 1|2)', 'J2 (layers 2|3)'};
for j = 1:2
    lbl(11 + j, 1, jt{j});
    efV{j} = uieditfield(g, 'numeric', 'Value', 0, 'Limits', [0 100], 'ValueDisplayFormat', '%.3g', ...
        'ValueChangedFcn', @(~,~) changed());
    put(efV{j}, 11 + j, 2);
    ddDir{j} = uidropdown(g, 'Items', {'Forward', 'Reverse'}, 'ValueChangedFcn', @(~,~) changed());
    put(ddDir{j}, 11 + j, [3 4]);
end
lbl(14, [1 4], 'Forward = p side positive (isotype: right side positive).');

cbLive = uicheckbox(g, 'Text', 'Live update', 'Value', true); put(cbLive, 15, [1 2]);
b = uibutton(g, 'Text', 'Update', 'ButtonPushedFcn', @(~,~) runSim()); put(b, 15, [3 4]);
b = uibutton(g, 'Text', 'Open in figure windows', 'ButtonPushedFcn', @(~,~) popOut()); put(b, 16, [1 2]);
b = uibutton(g, 'Text', 'Save PNGs...', 'ButtonPushedFcn', @(~,~) savePNG()); put(b, 16, [3 4]);

b = uibutton(g, 'Text', 'Full screen (current tab)', 'ButtonPushedFcn', @(~,~) fullScreen('tab')); put(b, 17, [1 4]);
b = uibutton(g, 'Text', 'Save preset...', 'ButtonPushedFcn', @(~,~) savePreset()); put(b, 18, [1 2]);
b = uibutton(g, 'Text', 'Delete preset', 'ButtonPushedFcn', @(~,~) deletePreset()); put(b, 18, [3 4]);

lblKind = uilabel(g, 'Text', '', 'FontWeight', 'bold', 'WordWrap', 'on');
put(lblKind, [19 20], [1 4]);
h = lbl(21, [1 4], 'Notes'); h.FontWeight = 'bold';
taNotes = uitextarea(g, 'Editable', 'off', 'FontSize', 11);
put(taNotes, [22 28], [1 4]);

% ---------------------------------------------------------------- plots
tg = uitabgroup(gl); tg.Layout.Row = 1; tg.Layout.Column = 2;
t1 = uitab(tg, 'Title', 'Bands and electrostatics');
g1 = uigridlayout(t1, [2 3]); g1.Padding = [4 4 4 4];
ax = cell(1,6);
for k = 1:6, ax{k} = uiaxes(g1); end
t2 = uitab(tg, 'Title', 'I-V');
g2 = uigridlayout(t2, [1 2]); axI1 = uiaxes(g2); axI2 = uiaxes(g2);
t3 = uitab(tg, 'Title', 'C-V');
g3 = uigridlayout(t3, [1 2]); axC1 = uiaxes(g3); axC2 = uiaxes(g3);
t4 = uitab(tg, 'Title', 'Summary');
g4 = uigridlayout(t4, [1 1]);
taSum = uitextarea(g4, 'Editable', 'off', 'FontName', 'Consolas', 'FontSize', 12);

% right-click any plot -> Full screen (Esc leaves full screen)
plotAxes = [ax, {axI1, axI2, axC1, axC2}];
plotKind = {1, 2, 3, 4, 5, 6, 'iv', 'iv', 'cv', 'cv'};
for k = 1:numel(plotAxes)
    cm = uicontextmenu(fig);
    uimenu(cm, 'Text', 'Full screen', 'MenuSelectedFcn', @(~,~) fullScreen(plotKind{k}));
    plotAxes{k}.ContextMenu = cm;
end

% start with the first preset
ddPreset.Value = P(1).label;
applyPreset();

% ================================================================ nested
    function h = lbl(r, c, txt)
        h = uilabel(g, 'Text', txt); put(h, r, c);
    end

    function put(h, r, c)
        h.Layout.Row = r; h.Layout.Column = c;
    end

    function applyPreset()
        i = find(strcmp({P.label}, ddPreset.Value), 1);
        if isempty(i), return; end
        p = P(i);
        missing = setdiff(p.mat, names);
        if ~isempty(missing)
            uialert(fig, ['Material(s) not found in ./materials: ' strjoin(missing, ', ')], 'Preset error');
            return
        end
        for kk = 1:3
            if kk > numel(p.mat)
                ddMat{kk}.Value = 'none'; continue
            end
            ddMat{kk}.Value  = p.mat{kk};
            ddType{kk}.Value = typeItems{1 + (p.type(kk) == 'p')};
            efN{kk}.Value    = sprintf('%.6g', p.N(kk));
            if ~p.auto && kk <= numel(p.W), efW{kk}.Value = p.W(kk); end
        end
        for jj = 1:2
            efV{jj}.Value = abs(p.V(jj));
            if p.V(jj) < 0, ddDir{jj}.Value = 'Reverse'; else, ddDir{jj}.Value = 'Forward'; end
        end
        cbAuto.Value = p.auto;
        enableControls();
        runSim();
    end

    function savePreset()
        % store the current controls as one .json file in ./presets
        try
            nL = 2 + ~strcmp(ddMat{3}.Value, 'none');
            q = struct('name', '', 'mat', {cell(1, nL)}, 'type', repmat('n', 1, nL), ...
                'N', zeros(1, nL), 'W', zeros(1, nL), 'V', zeros(1, 2), 'auto', logical(cbAuto.Value));
            for kk = 1:nL
                q.mat{kk} = ddMat{kk}.Value;
                if strcmp(ddType{kk}.Value, typeItems{2}), q.type(kk) = 'p'; end
                q.N(kk) = str2double(efN{kk}.Value);
                if ~isfinite(q.N(kk)) || q.N(kk) <= 0
                    error('Doping of layer %d is not a valid number.', kk);
                end
                q.W(kk) = efW{kk}.Value;
            end
            for jj = 1:(nL - 1)
                q.V(jj) = efV{jj}.Value;
                if strcmp(ddDir{jj}.Value, 'Reverse'), q.V(jj) = -q.V(jj); end
            end
        catch err
            uialert(fig, err.message, 'Cannot save preset'); return
        end
        answer = inputdlg('Preset name:', 'Save preset', [1 50], {''});
        figure(fig);
        if isempty(answer) || isempty(strtrim(answer{1})), return; end
        q.name = strtrim(answer{1});
        file = fullfile(presetDir, [regexprep(q.name, '[^\w\- ]', '_') '.json']);
        if isfile(file)
            sel = uiconfirm(fig, sprintf('Preset "%s" already exists. Overwrite it?', q.name), ...
                'Overwrite preset', 'Options', {'Overwrite', 'Cancel'}, 'DefaultOption', 2, 'CancelOption', 2);
            if ~strcmp(sel, 'Overwrite'), return; end
        end
        fid = fopen(file, 'w');
        if fid < 0, uialert(fig, ['Cannot write ' file], 'Cannot save preset'); return; end
        try, txt = jsonencode(q, 'PrettyPrint', true); catch, txt = jsonencode(q); end   % PrettyPrint needs R2021a
        fprintf(fid, '%s', txt);
        fclose(fid);
        refreshPresets(q.name);
    end

    function deletePreset()
        i = find(strcmp({P.label}, ddPreset.Value), 1);
        if isempty(i) || ~P(i).custom
            uialert(fig, 'Select one of your saved presets (marked with *) to delete it.', 'Delete preset');
            return
        end
        sel = uiconfirm(fig, sprintf('Delete preset "%s"?', P(i).name), 'Delete preset', ...
            'Options', {'Delete', 'Cancel'}, 'DefaultOption', 2, 'CancelOption', 2);
        if ~strcmp(sel, 'Delete'), return; end
        delete(P(i).file);
        refreshPresets('');
    end

    function refreshPresets(select)
        P = [presets(), loadCustomPresets(presetDir)];
        ddPreset.Items = [{'(custom)'}, {P.label}];
        i = find(strcmp({P.name}, select) & [P.custom], 1);
        if isempty(i), ddPreset.Value = '(custom)'; else, ddPreset.Value = P(i).label; end
    end

    function fullScreen(kind)
        % kind: 1..6 one position plot, 'iv', 'cv', or 'tab' (whatever tab is showing)
        if isempty(R), return; end
        if strcmp(kind, 'tab')
            switch find(tg.SelectedTab == [t1 t2 t3 t4], 1)
                case 1, kind = 0;
                case 2, kind = 'iv';
                case 3, kind = 'cv';
                otherwise, return
            end
        end
        f = figure('Color', 'w', 'NumberTitle', 'off', 'Name', 'Junction plot - full screen', ...
            'Visible', 'off', 'MenuBar', 'none', 'ToolBar', 'figure');
        fcn = {@jsim_plot_bands, @jsim_plot_field, @jsim_plot_potential, ...
               @jsim_plot_charge, @jsim_plot_carriers, @jsim_plot_alignment};
        if isnumeric(kind) && kind == 0          % all six position plots
            for k = 1:6, fcn{k}(subplot(2, 3, k, 'Parent', f), R); end
        elseif isnumeric(kind)                   % one position plot
            fcn{kind}(axes('Parent', f), R);
        elseif strcmp(kind, 'iv')
            jsim_plot_iv(subplot(1, 2, 1, 'Parent', f), subplot(1, 2, 2, 'Parent', f), R);
        else
            jsim_plot_cv(subplot(1, 2, 1, 'Parent', f), subplot(1, 2, 2, 'Parent', f), R);
        end
        uicontrol(f, 'Style', 'pushbutton', 'String', 'Exit full screen (Esc)', 'Units', 'normalized', ...
            'Position', [0.85 0.968 0.14 0.028], 'Callback', @(~,~) close(f));
        f.KeyPressFcn = @(~, e) escClose(f, e);
        try, f.WindowState = 'fullscreen'; catch, f.WindowState = 'maximized'; end
        f.Visible = 'on';
    end

    function escClose(f, e)
        if strcmp(e.Key, 'escape'), close(f); end
    end

    function changed()
        ddPreset.Value = '(custom)';
        enableControls();
        if cbLive.Value, runSim(); end
    end

    function enableControls()
        on3 = ~strcmp(ddMat{3}.Value, 'none');
        st = {'off', 'on'};
        ddType{3}.Enable = st{1 + on3}; efN{3}.Enable = st{1 + on3}; efW{3}.Enable = st{1 + (on3 && ~cbAuto.Value)};
        efV{2}.Enable = st{1 + on3}; ddDir{2}.Enable = st{1 + on3};
        for kk = 1:2, efW{kk}.Enable = st{1 + ~cbAuto.Value}; end
    end

    function cfg = readUI()
        nL = 2 + ~strcmp(ddMat{3}.Value, 'none');
        for kk = 1:nL
            idx = find(strcmp(names, ddMat{kk}.Value), 1);
            Nv = str2double(efN{kk}.Value);
            if ~isfinite(Nv) || Nv <= 0
                error('Doping of layer %d must be a positive number such as 1e17.', kk);
            end
            if Nv < 1e12 || Nv > 1e21
                error('Doping of layer %d should be between 1e12 and 1e21 cm^-3.', kk);
            end
            cfg.layers(kk).mat  = M(idx);
            cfg.layers(kk).type = 'n';
            if strcmp(ddType{kk}.Value, typeItems{2}), cfg.layers(kk).type = 'p'; end
            cfg.layers(kk).N = Nv;
            if cbAuto.Value, cfg.layers(kk).W = NaN; else, cfg.layers(kk).W = efW{kk}.Value; end
        end
        cfg.V = zeros(1, 2);
        for jj = 1:2
            cfg.V(jj) = efV{jj}.Value;
            if strcmp(ddDir{jj}.Value, 'Reverse'), cfg.V(jj) = -cfg.V(jj); end
        end
    end

    function runSim()
        fig.Pointer = 'watch'; drawnow;
        try
            cfg = readUI();
            R = jsim_simulate(cfg);
            drawAll();
            if cbAuto.Value
                for kk = 1:R.dev.nL, efW{kk}.Value = R.dev.L(kk).Wum; end
            end
        catch err
            uialert(fig, err.message, 'Simulation error');
        end
        fig.Pointer = 'arrow';
    end

    function drawAll()
        jsim_plot_bands(ax{1}, R);
        jsim_plot_field(ax{2}, R);
        jsim_plot_potential(ax{3}, R);
        jsim_plot_charge(ax{4}, R);
        jsim_plot_carriers(ax{5}, R);
        jsim_plot_alignment(ax{6}, R);
        jsim_plot_iv(axI1, axI2, R);
        jsim_plot_cv(axC1, axC2, R);

        lblKind.Text = sprintf('%s:  %s', R.dev.kind, strjoin(arrayfun(@(L) sprintf('%s-%s', L.type, L.name), ...
            R.dev.L, 'UniformOutput', false), ' | '));
        notes = R.dev.warn;
        if any(R.dev.punch), notes = [{'A layer is fully depleted (punch-through).'}, notes]; end
        if strcmp(R.iv.type, 'bjt')
            notes = [{sprintf('beta = %.3g at the operating point', R.iv.op.beta)}, notes];
        end
        if isempty(notes), notes = {'No warnings.'}; end
        taNotes.Value = notes(:);
        taSum.Value = R.summary(:);
    end

    function popOut()
        if isempty(R), return; end
        jsim_plot_all(R, 'on');
    end

    function savePNG()  % Only works for desktop MATLAB, not MATLAB Online.
        if isempty(R), return; end
        d = uigetdir(root, 'Folder for the PNG files');
        figure(fig);
        if isequal(d, 0), return; end
        f = jsim_plot_all(R, 'off');
        tags = {'bands_electrostatics', 'IV', 'CV'};
        stamp = datestr(now, 'yyyymmdd_HHMMSS');
        for kk = 1:numel(f)
            print(f(kk), fullfile(d, sprintf('%s_%s.png', tags{kk}, stamp)), '-dpng', '-r150');
            close(f(kk));
        end
        uialert(fig, sprintf('Saved 3 PNG files in\n%s', d), 'Saved', 'Icon', 'success');
    end
end

function P = presets()
% name, materials, dopant types, doping (cm^-3), bias [J1 J2] (forward +)
S = {
 'Si pn diode, equilibrium (M&K style)',  {'Si','Si'},                                'pn',  [1e17 1e16],      [0 0]
 'Si pn diode, forward 0.5 V',            {'Si','Si'},                                'pn',  [1e17 1e16],      [0.5 0]
 'Si pn diode, reverse 5 V',              {'Si','Si'},                                'pn',  [1e17 1e16],      [-5 0]
 'N-AlGaAs / p-GaAs heterojunction',      {'Al0.3Ga0.7As','GaAs'},                    'np',  [1e17 1e18],      [0 0]
 'n-InP / n-InGaAs isotype (accumulation)', {'InP','In0.53Ga0.47As'},                 'nn',  [1e17 1e17],      [0 0]
 'Si npn BJT, active',                    {'Si','Si','Si'},                           'npn', [1e19 1e17 1e16], [0.7 -3]
 'InP/InGaAs SHBT (npn), active',         {'InP','In0.53Ga0.47As','In0.53Ga0.47As'},  'npn', [5e17 1e19 5e16], [0.7 -1.5]
 'InP/InGaAs/InP DHBT (npn), active',     {'InP','In0.53Ga0.47As','InP'},             'npn', [5e17 1e19 5e16], [0.7 -1.5]
 'GaInP/GaAs HBT (npn), active',          {'Ga0.51In0.49P','GaAs','GaAs'},            'npn', [5e17 4e19 2e16], [1.35 -2]
 'Si/SiGe/Si HBT (npn), active',          {'Si','Si0.8Ge0.2 (strained on Si)','Si'},  'npn', [1e19 5e18 1e17], [0.8 -2]
 'Si pnp BJT, active',                    {'Si','Si','Si'},                           'pnp', [1e19 1e17 1e16], [0.65 -3]
};
P = struct('name', S(:,1), 'mat', S(:,2), 'type', S(:,3), 'N', S(:,4), 'V', S(:,5));
P = P(:)';
for k = 1:numel(P)
    P(k).label = P(k).name; P(k).W = []; P(k).auto = true; P(k).custom = false; P(k).file = '';
end
end

function C = loadCustomPresets(dirName)
% Read every *.json preset in dirName (written by "Save preset...").
C = struct('name', {}, 'mat', {}, 'type', {}, 'N', {}, 'V', {}, 'label', {}, 'W', {}, 'auto', {}, 'custom', {}, 'file', {});
f = dir(fullfile(dirName, '*.json'));
for k = 1:numel(f)
    file = fullfile(f(k).folder, f(k).name);
    try
        q = jsondecode(fileread(file));
        c.name = char(q.name); c.mat = cellstr(q.mat)'; c.type = char(q.type);
        c.N = double(q.N(:))'; c.V = double(q.V(:))'; c.V(end+1:2) = 0;
        c.label = ['* ' c.name]; c.W = double(q.W(:))'; c.auto = logical(q.auto);
        c.custom = true; c.file = file;
        C(end+1) = c; %#ok<AGROW>
    catch err
        warning('Skipping preset %s: %s', f(k).name, err.message);
    end
end
if ~isempty(C), [~, o] = sort(lower({C.name})); C = C(o); end
end
