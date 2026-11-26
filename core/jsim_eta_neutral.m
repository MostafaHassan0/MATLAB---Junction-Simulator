function eta = jsim_eta_neutral(L, kT)
% JSIM_ETA_NEUTRAL  eta = (EF - Ec)/kT in a neutral layer (full ionisation,
% Fermi-Dirac statistics): solves n - p = Nd - Na by bisection.
g  = L.Eg/kT;
lo = -g - 80; hi = 80;
for i = 1:200
    mid = (lo + hi)/2;
    f = L.Nc*jsim_fd12(mid) - L.Nv*jsim_fd12(-mid - g) - (L.Nd - L.Na);
    if f > 0, hi = mid; else, lo = mid; end
end
eta = (lo + hi)/2;
end
