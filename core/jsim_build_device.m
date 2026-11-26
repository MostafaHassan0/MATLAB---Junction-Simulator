function dev = jsim_build_device(cfg, C)
% JSIM_BUILD_DEVICE  Turn the user's choices into a device description.
%   cfg.layers(k).mat  : material struct (from jsim_load_materials)
%   cfg.layers(k).type : 'n' (donors) or 'p' (acceptors)
%   cfg.layers(k).N    : doping (cm^-3)
%   cfg.layers(k).W    : width (um), NaN = automatic
%   cfg.V(j)           : bias on junction j, forward positive (V)
kT = C.kT;
nL = numel(cfg.layers);
offs = band_offsets();
dev.nL = nL; dev.warn = {};
for k = 1:nL
    c = cfg.layers(k); m = c.mat;
    L.name = m.name; L.type = lower(c.type(1)); L.N = c.N;
    L.Nd = c.N*(L.type == 'n'); L.Na = c.N*(L.type == 'p');
    L.Eg = m.Eg; L.eps_r = m.eps_r; L.eps = m.eps_r*C.eps0;
    L.Nc = m.Nc; L.Nv = m.Nv; L.ni = sqrt(m.Nc*m.Nv)*exp(-m.Eg/(2*kT));
    % electron affinity: Anderson rule unless a measured pair ratio exists
    L.offsetRule = 'Anderson (electron affinity)';
    if k == 1
        L.chi = m.chi;
    else
        P = dev.L(k-1); r = pair_ratio(offs, P.name, m.name);
        if isnan(r)
            L.chi = P.chi + (m.chi - cfg.layers(k-1).mat.chi);
        else
            L.chi = P.chi - r*(m.Eg - P.Eg);
            L.offsetRule = sprintf('measured dEc/dEg = %.2f', r);
        end
    end
    L.eta = jsim_eta_neutral(L, kT);              % (EF - Ec)/kT in the neutral layer
    L.Wf  = L.chi - L.eta*kT;                     % work function (eV)
    L.n0  = L.Nc*jsim_fd12(L.eta);
    L.p0  = L.Nv*jsim_fd12(-L.eta - L.Eg/kT);
    L.mun = jsim_mobility(m.mu_n, L.N);  L.mup = jsim_mobility(m.mu_p, L.N);
    L.taun = m.tau_n0/(1 + L.N/m.N_srh);  L.taup = m.tau_p0/(1 + L.N/m.N_srh);
    L.Dn = kT*L.mun; L.Dp = kT*L.mup;              % Einstein relation (cm^2/s)
    L.Ln = sqrt(L.Dn*L.taun); L.Lp = sqrt(L.Dp*L.taup);
    if L.type == 'p'                               % minority-carrier set
        L.m0 = L.n0; L.Dm = L.Dn; L.Lm = L.Ln; L.taum = L.taun;
    else
        L.m0 = L.p0; L.Dm = L.Dp; L.Lm = L.Lp; L.taum = L.taup;
    end
    L.tau_gr = sqrt(L.taun*L.taup);
    L.Wum = c.W; L.EF = 0; L.width = NaN;
    if k == 1, dev.L = L; else, dev.L(k) = L; end
    if L.eta > 0
        dev.warn{end+1} = sprintf('layer %d (%s) is degenerate: EF is %.0f meV inside the %s band', ...
            k, L.name, 1000*abs(L.eta*kT), 'conduction');
    elseif -L.eta - L.Eg/kT > 0
        dev.warn{end+1} = sprintf('layer %d (%s) is degenerate: EF is inside the valence band', k, L.name);
    end
end
% Fermi level of each neutral layer: forward bias lowers the p side by qV
dev.V = cfg.V(1:nL-1);
for j = 1:nL-1
    a = dev.L(j).type; b = dev.L(j+1).type; V = dev.V(j);
    if a == 'n' && b == 'p',     dev.L(j+1).EF = dev.L(j).EF - V;
    elseif a == 'p' && b == 'n', dev.L(j+1).EF = dev.L(j).EF + V;
    else,                        dev.L(j+1).EF = dev.L(j).EF - V;  % isotype: right side positive = forward
    end
end
% junctions at the actual bias and at equilibrium
for j = 1:nL-1
    Jb = jsim_junction(dev.L(j), dev.L(j+1), dev.L(j).EF, dev.L(j+1).EF, C);
    J0 = jsim_junction(dev.L(j), dev.L(j+1), 0, 0, C);
    if j == 1, dev.J = Jb; dev.J0 = J0; else, dev.J(j) = Jb; dev.J0(j) = J0; end
    if ~isempty(Jb.warn), dev.warn{end+1} = sprintf('junction %d: %s', j, Jb.warn); end
end
% layer widths (um): automatic choice keeps several depletion widths of room
for k = 1:nL
    W = dev.L(k).Wum;
    if isnan(W) || W <= 0
        dl = 0; dr = 0; dl0 = 0; dr0 = 0;
        if k > 1,  dl = max(dev.J(k-1).x2, dev.J0(k-1).x2); dl0 = dev.J0(k-1).x2; end
        if k < nL, dr = max(dev.J(k).x1, dev.J0(k).x1);     dr0 = dev.J0(k).x1;   end
        if k > 1 && k < nL            % transistor base: equilibrium depletion + 100 nm
            W = (dl0 + dr0)*1e4 + 0.1;
        else
            W = max(0.3, 3*(dl + dr)*1e4);
        end
        W = ceil(W*100)/100;
    end
    dev.L(k).width = W*1e-4;  % cm
    dev.L(k).Wum = W;
end
dev.xi = cumsum([dev.L.width]); dev.xi = dev.xi(1:end-1);   % interfaces (cm)
dev.Ltot = sum([dev.L.width]);
% device classification
t = [dev.L.type];
if nL == 2
    if t(1) ~= t(2), kind = 'pn junction'; else, kind = 'isotype junction'; end
    if strcmp(dev.L(1).name, dev.L(2).name), kind = ['homo ' kind]; else, kind = ['hetero ' kind]; end
else
    if strcmp(t, 'npn') || strcmp(t, 'pnp')
        nm = {dev.L.name};
        if strcmp(nm{1}, nm{2}) && strcmp(nm{2}, nm{3}), h = 'BJT';
        elseif ~strcmp(nm{2}, nm{3}) && ~strcmp(nm{1}, nm{2}), h = 'double-heterojunction HBT (DHBT)';
        elseif ~strcmp(nm{1}, nm{2}), h = 'single-heterojunction HBT (SHBT)';
        else, h = 'HBT (heterojunction at base-collector only)';
        end
        kind = [t ' ' h];
    else
        kind = sprintf('%s three-layer stack (not a bipolar transistor)', t);
    end
end
dev.kind = kind;
dev.isBJT = nL == 3 && (strcmp(t, 'npn') || strcmp(t, 'pnp'));
end

function r = pair_ratio(T, a, b)
r = NaN;
for i = 1:size(T, 1)
    if (strcmp(T{i,1}, a) && strcmp(T{i,2}, b)) || (strcmp(T{i,1}, b) && strcmp(T{i,2}, a))
        r = T{i,3}; return
    end
end
end
