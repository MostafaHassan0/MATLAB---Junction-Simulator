function m = Al0p3Ga0p7As()
% AL0P3GA0P7AS  Al0.3Ga0.7As material data at T = 300 K.
% Edit the numbers here to change the material everywhere in the app.
% Sources: Ioffe NSM AlGaAs composition formulas (x = 0.3): Eg = 1.424 + 1.247x, eps = 12.9 - 2.84x, me = 0.063 + 0.083x. chi set so that dEc = 0.65 dEg vs GaAs (0.24 eV), the commonly used split.
m.name  = 'Al0.3Ga0.7As';
m.Eg    = 1.798;   % band gap (eV)
m.chi   = 3.83;   % electron affinity (eV)
m.eps_r = 12.05;   % relative permittivity
m.Nc    = 6.5e17;   % conduction-band effective density of states (cm^-3)
m.Nv    = 1.1e19;   % valence-band effective density of states (cm^-3)
% Doping-dependent mobility (Caughey-Thomas form, cm^2/V s):
%   mu(N) = mu_min + (mu_max - mu_min) / (1 + (N/N_ref)^alpha)
m.mu_n  = struct('mu_max', 2300,  'mu_min', 300,  'N_ref', 1.0e17, 'alpha', 0.5);
m.mu_p  = struct('mu_max', 145, 'mu_min', 30, 'N_ref', 1.0e17, 'alpha', 0.5);
% SRH lifetime: tau(N) = tau0 / (1 + N/N_srh)   (s)
m.tau_n0 = 1e-8;  m.tau_p0 = 1e-8;  m.N_srh = 1e19;  % III-V: radiative/Auger dominate, weak SRH doping dependence
% Intrinsic density computed from Nc, Nv and Eg (cm^-3); set ni_override to
% a number to force a value (Nc and Nv are then scaled by the same factor).
m.ni = sqrt(m.Nc*m.Nv)*exp(-m.Eg/(2*0.025852));
m.ni_override = [];
end
