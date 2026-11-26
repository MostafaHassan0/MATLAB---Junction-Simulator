function R = jsim_solve_poisson(dev, C)
% JSIM_SOLVE_POISSON  Numerical band diagram of the 1-D layer stack.
% Solves Poisson's equation  d/dx( eps dpsi/dx ) = -q (p - n + Nd - Na)
% with n = Nc F1/2((EFn - Ec)/kT), p = Nv F1/2((Ev - EFp)/kT),
% Ec = -psi - chi (vacuum level = -q psi), on a non-uniform grid (Newton).
% Quasi-Fermi levels follow the Shockley picture:
%   * majority QFL flat in each layer at that layer's contact Fermi level,
%   * both QFLs flat across a pn depletion region,
%   * minority QFL in a neutral region from the diffusion solution
%     dm(x) = [dm_L sinh((Wq-s)/L) + dm_R sinh(s/L)] / sinh(Wq/L),
%     dm at a depletion edge = m0 (exp(qV/kT) - 1), dm = 0 at an ohmic contact.
kT = C.kT; q = C.q;
L = dev.L; nL = dev.nL; xi = dev.xi; Lt = dev.Ltot;

% ---------------- grid (cm): coarse + geometric refinement at interfaces
x = linspace(0, Lt, 1500);
for k = 1:numel(xi)
    wmin = min(L(k).width, L(k+1).width);
    d = logspace(log10(1e-8), log10(min(3e-5, 0.45*wmin)), 90);
    x = [x, xi(k) - d, xi(k) + d]; %#ok<AGROW>
end
x = unique(x); x = x(x >= 0 & x <= Lt);
for k = 1:numel(xi), x(abs(x - xi(k)) < 0.4e-8) = []; end   % no node on an interface
x = x([true, diff(x) > 2e-9]);  x(end) = Lt;
x = x(:); N = numel(x);
lay  = ones(N,1);  for k = 1:numel(xi), lay = lay + (x > xi(k)); end
xm   = (x(1:end-1) + x(2:end))/2;
laym = ones(N-1,1); for k = 1:numel(xi), laym = laym + (xm > xi(k)); end

f = @(name) reshape([L(lay).(name)], [], 1);
chi = f('chi'); Eg = f('Eg'); Nc = f('Nc'); Nv = f('Nv'); Nd = f('Nd'); Na = f('Na');
epsI = reshape([L(laym).eps], [], 1);
typ = [L(lay).type]'; isn = typ == 'n';

% ---------------- quasi-Fermi levels
EFl = [L.EF];
EFn = EFl(lay)'; EFp = EFn;
st = [0, xi]; en = [xi, Lt];
dL = zeros(1, nL); dR = zeros(1, nL);         % depletion depth into each layer
for j = 1:nL-1, dR(j) = dev.J(j).x1; dL(j+1) = dev.J(j).x2; end
dev.punch = false(1, nL);
for k = 1:nL
    in = lay == k; s0 = st(k) + dL(k); s1 = en(k) - dR(k);
    if s1 - s0 < 1e-7
        dev.punch(k) = true; mid = (s0 + s1)/2; s0 = mid - 0.5e-7; s1 = mid + 0.5e-7;
    end
    Lk = L(k); sg = 1; if Lk.type == 'n', sg = -1; end   % minority: electrons in p, holes in n
    dmL = 0; dmR = 0; pnL = false; pnR = false;
    if k > 1 && L(k-1).type ~= Lk.type
        pnL = true; dmL = Lk.m0*(exp(min(sg*(EFl(k-1) - EFl(k))/kT, 200)) - 1);
    end
    if k < nL && L(k+1).type ~= Lk.type
        pnR = true; dmR = Lk.m0*(exp(min(sg*(EFl(k+1) - EFl(k))/kT, 200)) - 1);
    end
    Wq = s1 - s0; s = min(max(x(in) - s0, 0), Wq);
    dm = dmL*sinhratio(Wq - s, Wq, Lk.Lm) + dmR*sinhratio(s, Wq, Lk.Lm);
    m  = max(Lk.m0 + dm, Lk.m0*exp(-200));
    QFLmin = EFl(k) + sg*kT*log(m/Lk.m0);     % p: EFn = EF + kT ln(n/n0); n: EFp = EF - kT ln(p/p0)
    xx = x(in);
    if pnL, QFLmin(xx < s0) = EFl(k-1); end    % flat across the depletion region
    if pnR, QFLmin(xx > s1) = EFl(k+1); end
    if Lk.type == 'p', EFn(in) = QFLmin; else, EFp(in) = QFLmin; end
end

% ---------------- carriers as a function of psi
etan = @(ps) (EFn + ps + chi)/kT;
etap = @(ps) (-ps - chi - Eg - EFp)/kT;
% neutral-contact potential: psi = eta*kT - EF - chi
psiN = zeros(N,1);
for k = 1:nL, psiN(lay == k) = L(k).eta*kT - EFl(k) - L(k).chi; end
psi = psiN;                                   % initial guess: local neutrality

h  = diff(x); hav = zeros(N,1); hav(2:N-1) = (h(1:end-1) + h(2:end))/2;
cP = zeros(N,1); cM = zeros(N,1);
cP(2:N-1) = epsI(2:end)./h(2:end)./hav(2:N-1);
cM(2:N-1) = epsI(1:end-1)./h(1:end-1)./hav(2:N-1);
conv = false;
for it = 1:400
    en_ = etan(psi); ep_ = etap(psi);
    n = Nc.*jsim_fd12(en_);  p = Nv.*jsim_fd12(ep_);
    dn = Nc.*jsim_dfd12(en_)/kT;  dp = -Nv.*jsim_dfd12(ep_)/kT;
    rho = p - n + Nd - Na;
    Rr = zeros(N,1);
    Rr(2:N-1) = cP(2:N-1).*(psi(3:N) - psi(2:N-1)) - cM(2:N-1).*(psi(2:N-1) - psi(1:N-2)) + q*rho(2:N-1);
    Rr = Rr/q;                                % scale to ~ cm^-3
    dg = ones(N,1); up = zeros(N,1); lo = zeros(N,1);
    dg(2:N-1) = (-(cP(2:N-1) + cM(2:N-1)) + q*(dp(2:N-1) - dn(2:N-1)))/q;
    up(3:N)   = cP(2:N-1)/q;                  % J(i,i+1)
    lo(1:N-2) = cM(2:N-1)/q;                  % J(i,i-1)
    Jm = spdiags([lo dg up], -1:1, N, N);
    d = zeros(N,1); I = 2:N-1;                % contacts are fixed (Dirichlet)
    d(I) = -(Jm(I,I)\Rr(I));
    d = sign(d).*kT.*log(1 + abs(d)/kT);      % logarithmic damping
    psi = psi + d;
    if max(abs(d)) < 1e-10, conv = true; break; end
end
en_ = etan(psi); ep_ = etap(psi);
n = Nc.*jsim_fd12(en_);  p = Nv.*jsim_fd12(ep_);
rho = p - n + Nd - Na;
if ~conv, dev.warn{end+1} = 'Poisson solver did not fully converge'; end

% ---------------- outputs (x in um)
R.dev = dev; R.x = x*1e4; R.xm = xm*1e4; R.xi = xi*1e4; R.lay = lay;
R.psi = psi - psi(1);                         % potential relative to the left contact (V)
R.Ec = -psi - chi; R.Ev = R.Ec - Eg;
R.Ei = (R.Ec + R.Ev)/2 + kT/2*log(Nv./Nc);
R.EFn = EFn; R.EFp = EFp;
R.E  = -diff(psi)./h;                         % field at mid-cells (V/cm)
R.rho = rho;                                  % rho/q (cm^-3)
R.n = n; R.p = p; R.Nnet = Nd - Na; R.iter = it;
R.ni = reshape([L(lay).ni], [], 1);

% ---------------- depletion-approximation overlays
Edep = zeros(N-1,1); rdep = zeros(N,1); edges = [];
for j = 1:nL-1
    J = dev.J(j); a = xi(j) - J.x1; b = xi(j) + J.x2;
    iL = xm >= a & xm < xi(j); iR = xm >= xi(j) & xm <= b;
    Edep(iL) = Edep(iL) + J.sgn*q*L(j).N*(xm(iL) - a)/L(j).eps;
    Edep(iR) = Edep(iR) + J.sgn*q*L(j+1).N*(b - xm(iR))/L(j+1).eps;
    nL_ = x >= a & x < xi(j); nR_ = x >= xi(j) & x <= b;
    rdep(nL_) = rdep(nL_) + J.sgn*L(j).N;  rdep(nR_) = rdep(nR_) - J.sgn*L(j+1).N;
    edges = [edges, [a b]*1e4]; %#ok<AGROW>
end
R.Edep = Edep; R.rhodep = rdep;
R.psidep = [0; -cumsum(Edep.*h)];
R.depEdges = edges(edges > 0 & edges < Lt*1e4);

% ---------------- region classification (QNR / depletion / accumulation)
Nabs = abs(R.Nnet); rel = rho./Nabs;
maj = n.*isn + p.*(~isn);  mnr = p.*isn + n.*(~isn);
cls = zeros(N,1);                              % 0 = quasi-neutral
sc  = abs(rel) > 0.1;
cls(sc) = 1;                                   % depleted space charge (ionised dopants)
cls(sc & (maj > 1.1*Nabs | mnr > Nabs)) = 2;   % mobile charge: accumulation / inversion
R.cls = cls;
R.seg = segments(R.x, cls);
R.dev = dev;
end

function r = sinhratio(a, b, L)
% sinh(a/L)/sinh(b/L) evaluated without overflow (0 <= a <= b)
A = a/L; B = b/L;
if B < 1e-6
    r = a/b;
else
    r = (exp(A - B) - exp(-A - B))./(1 - exp(-2*B));
end
end

function S = segments(x, c)
% contiguous runs of one class -> [x0 x1 class] rows (edges at midpoints)
N = numel(x); S = zeros(0,3); i0 = 1;
for i = 2:N+1
    if i > N || c(i) ~= c(i0)
        if i0 == 1, a = x(1); else, a = (x(i0-1) + x(i0))/2; end
        if i > N,  b = x(N);  else, b = (x(i-1) + x(i))/2;    end
        S(end+1,:) = [a b c(i0)]; %#ok<AGROW>
        i0 = i;
    end
end
end
