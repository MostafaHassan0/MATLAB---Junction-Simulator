% RUN_TESTS  Check the physics core against textbook (M&K Ch. 4) formulas.
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'core'), fullfile(root, 'plots'));
M = jsim_load_materials(root); C = jsim_const(); q = C.q; kT = C.kT;
ok = true;
check = @(name, got, want, tol) fprintf('%-46s got %-11.4g want %-11.4g %s\n', name, got, want, ...
    char('FAIL' * (abs(got - want) > tol*abs(want)) + 'ok  ' * (abs(got - want) <= tol*abs(want))));

% 1) Si step junction, Na = 1e17, Nd = 1e16, equilibrium (Boltzmann regime)
R = jsim_simulate(jsim_config(M, {'Si','Si'}, 'pn', [1e17 1e16], 0));
L = R.dev.L; ni = L(1).ni; Na = 1e17; Nd = 1e16; es = L(1).eps;
Vbi = kT*log(Na*Nd/ni^2);
W   = sqrt(2*es*Vbi/q*(1/Na + 1/Nd));
Em  = q*Nd*(W*Na/(Na + Nd))/es;
check('Vbi = kT/q ln(NaNd/ni^2) (V)', R.dev.J0(1).Vbi, Vbi, 0.005);
check('W = sqrt(2 eps Vbi/q (1/Na+1/Nd)) (um)', R.dev.J(1).W*1e4, W*1e4, 0.005);
check('peak field, depletion approx (V/cm)', R.dev.J(1).Emax, Em, 0.005);
check('peak field, Poisson vs approx (V/cm)', max(abs(R.E)), Em, 0.06);
check('potential drop from Poisson (V)', R.psi(end) - R.psi(1), Vbi, 0.01);
check('Cj = eps/W (F/cm^2)', R.dev.J(1).Cj, es/W, 0.005);
% 2) reverse bias: W grows as sqrt(Vbi - V)
R2 = jsim_simulate(jsim_config(M, {'Si','Si'}, 'pn', [1e17 1e16], -5));
check('W(-5 V)/W(0) = sqrt((Vbi+5)/Vbi)', R2.dev.J(1).W/R.dev.J(1).W, sqrt((Vbi + 5)/Vbi), 0.005);
check('Poisson drop at -5 V (V)', R2.psi(end) - R2.psi(1), Vbi + 5, 0.01);
% 3) heterojunction: InP/InGaAs offset rule
R3 = jsim_simulate(jsim_config(M, {'InP','In0.53Ga0.47As'}, 'np', [1e17 1e17], 0));
check('InP/InGaAs dEc = 0.39 dEg (eV)', abs(R3.dev.J(1).dEc), 0.39*(1.344 - 0.75), 0.001);
% 4) forward bias: minority QFL split equals qV at the depletion edge
R4 = jsim_simulate(jsim_config(M, {'Si','Si'}, 'pn', [1e17 1e16], 0.5));
i = find(R4.x > R4.xi(1), 1);
check('EFn - EFp at junction = qV (eV)', R4.EFn(i) - R4.EFp(i), 0.5, 0.001);
