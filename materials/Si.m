function m = Si()
% SI  Si material data at T = 300 K.
% Edit the numbers here to change the material everywhere in the app.
% Sources: Sze & Ng, Physics of Semiconductor Devices 3rd ed. App. G; mobility fit Masetti/Arora (close to M&K Fig. 1.16). Note: M&K uses ni = 1.45e10; set ni_override = 1.45e10 to reproduce book answers.
m.name  = 'Si';
m.Eg    = 1.12;   % band gap (eV)
m.chi   = 4.05;   % electron affinity (eV)
m.eps_r = 11.7;   % relative permittivity
m.Nc    = 2.86e19;   % conduction-band effective density of states (cm^-3)
m.Nv    = 2.66e19;   % valence-band effective density of states (cm^-3)
% Doping-dependent mobility (Caughey-Thomas form, cm^2/V s):
%   mu(N) = mu_min + (mu_max - mu_min) / (1 + (N/N_ref)^alpha)
m.mu_n  = struct('mu_max', 1417,  'mu_min', 65,  'N_ref', 8.5e16, 'alpha', 0.72);
m.mu_p  = struct('mu_max', 471, 'mu_min', 48, 'N_ref', 6.3e16, 'alpha', 0.76);
% SRH lifetime: tau(N) = tau0 / (1 + N/N_srh)   (s)
m.tau_n0 = 1e-6;  m.tau_p0 = 1e-6;  m.N_srh = 5e16;
% Intrinsic density computed from Nc, Nv and Eg (cm^-3); set ni_override to
% a number to force a value (Nc and Nv are then scaled by the same factor).
m.ni = sqrt(m.Nc*m.Nv)*exp(-m.Eg/(2*0.025852));
m.ni_override = [];
end
