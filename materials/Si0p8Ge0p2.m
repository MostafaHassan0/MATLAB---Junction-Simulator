function m = Si0p8Ge0p2()
% SI0P8GE0P2  Si0.8Ge0.2 (strained on Si) material data at T = 300 K.
% Edit the numbers here to change the material everywhere in the app.
% Approximate SiGe HBT base (pseudomorphic on Si): most of dEg (~0.17 eV) is in the valence band (People & Bean; Cressler & Niu). Treat as illustrative.
m.name  = 'Si0.8Ge0.2 (strained on Si)';
m.Eg    = 0.95;   % band gap (eV)
m.chi   = 4.07;   % electron affinity (eV)
m.eps_r = 12.6;   % relative permittivity
m.Nc    = 2.5e19;   % conduction-band effective density of states (cm^-3)
m.Nv    = 1.5e19;   % valence-band effective density of states (cm^-3)
% Doping-dependent mobility (Caughey-Thomas form, cm^2/V s):
%   mu(N) = mu_min + (mu_max - mu_min) / (1 + (N/N_ref)^alpha)
m.mu_n  = struct('mu_max', 1200,  'mu_min', 60,  'N_ref', 8.5e16, 'alpha', 0.72);
m.mu_p  = struct('mu_max', 400, 'mu_min', 45, 'N_ref', 6.3e16, 'alpha', 0.76);
% SRH lifetime: tau(N) = tau0 / (1 + N/N_srh)   (s)
m.tau_n0 = 1e-7;  m.tau_p0 = 1e-7;  m.N_srh = 5e16;
% Intrinsic density computed from Nc, Nv and Eg (cm^-3); set ni_override to
% a number to force a value (Nc and Nv are then scaled by the same factor).
m.ni = sqrt(m.Nc*m.Nv)*exp(-m.Eg/(2*0.025852));
m.ni_override = [];
end
