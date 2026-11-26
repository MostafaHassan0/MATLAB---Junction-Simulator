function m = Ge()
% GE  Ge material data at T = 300 K.
% Edit the numbers here to change the material everywhere in the app.
% Sources: Sze & Ng App. G; Ioffe NSM Ge (approximate mobility fit).
m.name  = 'Ge';
m.Eg    = 0.66;   % band gap (eV)
m.chi   = 4.00;   % electron affinity (eV)
m.eps_r = 16.2;   % relative permittivity
m.Nc    = 1.04e19;   % conduction-band effective density of states (cm^-3)
m.Nv    = 6.0e18;   % valence-band effective density of states (cm^-3)
% Doping-dependent mobility (Caughey-Thomas form, cm^2/V s):
%   mu(N) = mu_min + (mu_max - mu_min) / (1 + (N/N_ref)^alpha)
m.mu_n  = struct('mu_max', 3900,  'mu_min', 850,  'N_ref', 2.6e17, 'alpha', 0.56);
m.mu_p  = struct('mu_max', 1900, 'mu_min', 300, 'N_ref', 1.0e17, 'alpha', 0.5);
% SRH lifetime: tau(N) = tau0 / (1 + N/N_srh)   (s)
m.tau_n0 = 1e-6;  m.tau_p0 = 1e-6;  m.N_srh = 5e16;
% Intrinsic density computed from Nc, Nv and Eg (cm^-3); set ni_override to
% a number to force a value (Nc and Nv are then scaled by the same factor).
m.ni = sqrt(m.Nc*m.Nv)*exp(-m.Eg/(2*0.025852));
m.ni_override = [];
end
