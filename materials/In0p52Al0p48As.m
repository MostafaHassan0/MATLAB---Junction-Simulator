function m = In0p52Al0p48As()
% IN0P52AL0P48AS  In0.52Al0.48As material data at T = 300 K.
% Edit the numbers here to change the material everywhere in the app.
% Lattice matched to InP. Approximate (Ioffe NSM; me = 0.075). With InGaAs: dEc ~ 0.52 eV (set in materials/pairs/band_offsets.m).
m.name  = 'In0.52Al0.48As';
m.Eg    = 1.46;   % band gap (eV)
m.chi   = 3.98;   % electron affinity (eV)
m.eps_r = 12.4;   % relative permittivity
m.Nc    = 5.1e17;   % conduction-band effective density of states (cm^-3)
m.Nv    = 1.16e19;   % valence-band effective density of states (cm^-3)
% Doping-dependent mobility (Caughey-Thomas form, cm^2/V s):
%   mu(N) = mu_min + (mu_max - mu_min) / (1 + (N/N_ref)^alpha)
m.mu_n  = struct('mu_max', 4000,  'mu_min', 400,  'N_ref', 1.0e17, 'alpha', 0.5);
m.mu_p  = struct('mu_max', 100, 'mu_min', 20, 'N_ref', 1.0e17, 'alpha', 0.5);
% SRH lifetime: tau(N) = tau0 / (1 + N/N_srh)   (s)
m.tau_n0 = 1e-9;  m.tau_p0 = 1e-9;  m.N_srh = 1e19;  % III-V: radiative/Auger dominate, weak SRH doping dependence
% Intrinsic density computed from Nc, Nv and Eg (cm^-3); set ni_override to
% a number to force a value (Nc and Nv are then scaled by the same factor).
m.ni = sqrt(m.Nc*m.Nv)*exp(-m.Eg/(2*0.025852));
m.ni_override = [];
end
