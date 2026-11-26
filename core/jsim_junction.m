function J = jsim_junction(A, B, EFl, EFr, C)
% JSIM_JUNCTION  Depletion approximation for the abrupt junction between
% layer A (left) and layer B (right), hetero or homo, pn or isotype.
%   EFl, EFr : Fermi levels of the two neutral layers (eV) (bias included)
% Built-in voltage comes from the work-function difference,
%   q*psi_l - q*psi_r = (EFr + W_B) - (EFl + W_A),  W = chi - (EF - Ec),
% and for a pn junction the depletion widths are (M&K Sec. 4.2, hetero form)
%   x1 = sqrt( 2 e1 e2 N2 Vt / (q N1 (e1 N1 + e2 N2)) ),  x2 = x1 N1/N2.
q = C.q; kT = C.kT;
J.dEc  = A.chi - B.chi;                       % Ec(B) - Ec(A) (eV)
J.dEv  = (A.chi + A.Eg) - (B.chi + B.Eg);     % Ev(B) - Ev(A) (eV)
dpsi   = (EFr + B.Wf) - (EFl + A.Wf);         % psi_left - psi_right (V)
dpsi0  = B.Wf - A.Wf;                         % same, at equilibrium
J.kind = [A.type B.type];
J.isPN = A.type ~= B.type;
J.Va   = (EFl - EFr)*(A.type == 'p') + (EFr - EFl)*(A.type == 'n');  % forward-positive bias
J.warn = '';
if J.isPN
    s = 1; if A.type == 'p', s = -1; end       % field points from n to p
    J.Vbi = s*dpsi0;  J.Vt = s*dpsi;
    Vte = J.Vt;
    if Vte < 2*kT
        Vte = 2*kT;
        J.warn = 'forward bias reaches V_bi: depletion approximation no longer valid (high injection)';
    end
    e1 = A.eps; e2 = B.eps; N1 = A.N; N2 = B.N;
    J.x1   = sqrt(2*e1*e2*N2*Vte/(q*N1*(e1*N1 + e2*N2)));
    J.x2   = J.x1*N1/N2;
    J.Emax = q*N1*J.x1/e1;                                % V/cm (left side of interface)
    J.Cj   = sqrt(q*e1*e2*N1*N2/(2*(e1*N1 + e2*N2)*Vte)); % F/cm^2
    J.sgn  = s;
    % share of Vt on each side (useful for the HBT spike discussion)
    J.V1 = q*N1*J.x1^2/(2*e1);  J.V2 = q*N2*J.x2^2/(2*e2);
else
    J.Vbi = abs(dpsi0);  J.Vt = abs(dpsi);
    sg = sign(dpsi); if sg == 0, sg = 1; end
    if A.type == 'n', depLeft = dpsi > 0; else, depLeft = dpsi < 0; end
    J.x1 = 0; J.x2 = 0;
    if depLeft
        J.x1 = sqrt(2*A.eps*J.Vt/(q*A.N)); J.Emax = q*A.N*J.x1/A.eps;
    else
        J.x2 = sqrt(2*B.eps*J.Vt/(q*B.N)); J.Emax = q*B.N*J.x2/B.eps;
    end
    J.Cj = NaN; J.sgn = sg; J.V1 = NaN; J.V2 = NaN;
    J.warn = 'isotype junction: depletion approximation only on the depleted side (accumulation layer from the numerical solution)';
end
J.W = J.x1 + J.x2;
end
