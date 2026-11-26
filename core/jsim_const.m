function C = jsim_const()
% JSIM_CONST  Physical constants and temperature used by the whole app.
% Units: energies in eV, lengths in cm, densities in cm^-3, eps in F/cm.
C.T    = 300;                 % K (all material files are at 300 K)
C.kT   = 8.617333262e-5*C.T;  % thermal energy (eV) = 0.025852 eV
C.q    = 1.602176634e-19;     % C
C.eps0 = 8.8541878128e-14;    % F/cm
end
