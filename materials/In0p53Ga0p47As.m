function m = In0p53Ga0p47As()
% IN0P53GA0P47AS  In0.53Ga0.47As material data at T = 300 K.
% Edit the numbers here to change the material everywhere in the app.
% Lattice matched to InP. Sources: Ioffe NSM GaInAs; same values as the project report (hbt_params.m).
m.name  = 'In0.53Ga0.47As';
m.Eg    = 0.75;   % band gap (eV)
m.chi   = 4.50;   % electron affinity (eV)
m.eps_r = 13.9;   % relative permittivity
m.Nc    = 2.1e17;   % conduction-band effective density of states (cm^-3)
m.Nv    = 7.7e18;   % valence-band effective density of states (cm^-3)
% Doping-dependent mobility (Caughey-Thomas form, cm^2/V s):
%   mu(N) = mu_min + (mu_max - mu_min) / (1 + (N/N_ref)^alpha)
m.mu_n  = struct('mu_max', 12000,  'mu_min', 1000,  'N_ref', 1.0e17, 'alpha', 0.5);
m.mu_p  = struct('mu_max', 300, 'mu_min', 50, 'N_ref', 1.0e17, 'alpha', 0.5);
% SRH lifetime: tau(N) = tau0 / (1 + N/N_srh)   (s)
m.tau_n0 = 1e-9;  m.tau_p0 = 1e-9;  m.N_srh = 1e19;  % III-V: radiative/Auger dominate, weak SRH doping dependence
% Intrinsic density computed from Nc, Nv and Eg (cm^-3); set ni_override to
% a number to force a value (Nc and Nv are then scaled by the same factor).
m.ni = sqrt(m.Nc*m.Nv)*exp(-m.Eg/(2*0.025852));
m.ni_override = [];
end
