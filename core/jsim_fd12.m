function F = jsim_fd12(e)
% JSIM_FD12  Normalised Fermi-Dirac integral of order 1/2 (Aymerich-Humet
% approximation, error < 1 %).  F -> exp(e) for e << 0 (Boltzmann limit), so
%   n = Nc*F((EFn - Ec)/kT),   p = Nv*F((Ev - EFp)/kT).
F = 1./(exp(-e) + 3*sqrt(pi/2)*(e + 2.13 + (abs(e - 2.13).^2.4 + 9.6).^(5/12)).^(-1.5));
end
