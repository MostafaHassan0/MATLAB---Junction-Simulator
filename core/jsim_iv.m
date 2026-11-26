function IV = jsim_iv(dev, C)
% JSIM_IV  Current-voltage curves (current densities, A/cm^2).
% Diode (2 layers, pn): Shockley diffusion current with finite neutral
% widths plus space-charge recombination/generation (M&K Ch. 5):
%   J = q[Dn n_p0/Ln coth(Wp/Ln) + Dp p_n0/Lp coth(Wn/Lp)](e^{V/kT} - 1)
%     + q[ni1 x1/(2 tau1) + ni2 x2/(2 tau2)](e^{V/2kT} - 1)
% Transistor (npn/pnp): Ebers-Moll from minority diffusion in the base with
% the neutral base width set by both depletion regions (Early effect).
% Thermionic limits at a conduction-band spike are not included.
kT = C.kT; IV.type = 'none'; IV.msg = '';
if dev.nL == 2
    if ~dev.J(1).isPN, IV.msg = 'I-V not modelled for an isotype junction'; return; end
    Vb = dev.J0(1).Vbi;
    Vr = max(2, -dev.V(1) + 0.5);
    V  = linspace(-Vr, Vb - 0.03, 400);
    if dev.V(1) > V(end), V = [V dev.V(1)]; end
    [Jd, Jg] = diode_j(dev, C, V);
    [Jd0, Jg0] = diode_j(dev, C, dev.V(1));
    IV.type = 'diode'; IV.V = V; IV.Jdiff = Jd; IV.Jgr = Jg; IV.J = Jd + Jg;
    IV.Vop = dev.V(1); IV.Jop = Jd0 + Jg0; IV.Jdiff_op = Jd0; IV.Jgr_op = Jg0;
elseif dev.isBJT
    IV.type = 'bjt';
    VbE = dev.J0(1).Vbi; VBC = dev.V(2);
    VBE = linspace(0.1, VbE - 0.02, 300);
    [IE, IC, IB] = bjt_j(dev, C, VBE, VBC*ones(size(VBE)));
    IV.VBE = VBE; IV.IC = IC; IV.IB = IB; IV.IE = IE;
    [IE0, IC0, IB0, d0] = bjt_j(dev, C, dev.V(1), dev.V(2));
    IV.op = struct('VBE', dev.V(1), 'VBC', dev.V(2), 'IC', IC0, 'IB', IB0, 'IE', IE0, ...
        'beta', IC0/IB0, 'gamma', d0.gamma, 'alphaT', d0.alphaT, 'WB', d0.WB);
    % output characteristics: |IC| vs |VCE| for a few VBE values
    Vop = dev.V(1);
    if Vop < 0.3, Vop = min(0.8, VbE - 0.1); end
    IV.VBEset = Vop + [-0.06 -0.03 0 0.03];
    IV.VBEset = IV.VBEset(IV.VBEset < VbE - 0.02);
    VCE = linspace(0, max(3, 1.5*(dev.V(1) - dev.V(2))), 250);
    IV.VCE = VCE; IV.ICout = zeros(numel(IV.VBEset), numel(VCE));
    for i = 1:numel(IV.VBEset)
        [~, ic] = bjt_j(dev, C, IV.VBEset(i)*ones(size(VCE)), IV.VBEset(i) - VCE);
        IV.ICout(i,:) = ic;
    end
    IV.VCEop = dev.V(1) - dev.V(2);
else
    IV.msg = 'I-V shown only for pn diodes and npn/pnp transistors';
end
end

function [Jd, Jg] = diode_j(dev, C, V)
kT = C.kT; q = C.q; A = dev.L(1); B = dev.L(2);
Jd = zeros(size(V)); Jg = Jd;
for i = 1:numel(V)
    EFr = A.EF - V(i); if A.type == 'p', EFr = A.EF + V(i); end
    J = jsim_junction(A, B, A.EF, EFr, C);
    W1 = max(A.width - J.x1, 1e-7); W2 = max(B.width - J.x2, 1e-7);
    J0 = q*(A.Dm*A.m0/A.Lm*coth(W1/A.Lm) + B.Dm*B.m0/B.Lm*coth(W2/B.Lm));
    Jr = q*(A.ni*J.x1/(2*A.tau_gr) + B.ni*J.x2/(2*B.tau_gr));
    Jd(i) = J0*(exp(V(i)/kT) - 1);
    Jg(i) = Jr*(exp(V(i)/(2*kT)) - 1);
end
end

function [IE, IC, IB, d] = bjt_j(dev, C, VBE, VBC)
% forward-positive junction voltages; returns magnitudes for npn and pnp alike
kT = C.kT; q = C.q; E = dev.L(1); Bs = dev.L(2); Cl = dev.L(3);
IE = zeros(size(VBE)); IC = IE; IB = IE;
sE = 1; if E.type == 'p', sE = -1; end         % npn: EF_base = EF_E - VBE
for i = 1:numel(VBE)
    EFb = E.EF - sE*VBE(i); EFc = EFb + sE*VBC(i);
    J1 = jsim_junction(E, Bs, E.EF, EFb, C);
    J2 = jsim_junction(Bs, Cl, EFb, EFc, C);
    WB = max(Bs.width - J1.x2 - J2.x1, 1e-8);
    WE = max(E.width - J1.x1, 1e-7); WC = max(Cl.width - J2.x2, 1e-7);
    u = WB/Bs.Lm; ea = exp(VBE(i)/kT) - 1; eb = exp(VBC(i)/kT) - 1;
    k0 = q*Bs.Dm*Bs.m0/Bs.Lm;
    JnE = k0*(coth(u)*ea - eb/sinh(u));
    JnC = k0*(ea/sinh(u) - coth(u)*eb);
    JpE = q*E.Dm*E.m0/E.Lm*coth(WE/E.Lm)*ea;
    JpC = q*Cl.Dm*Cl.m0/Cl.Lm*coth(WC/Cl.Lm)*eb;
    Jre = q*(E.ni*J1.x1/(2*E.tau_gr) + Bs.ni*J1.x2/(2*Bs.tau_gr))*(exp(VBE(i)/(2*kT)) - 1);
    IE(i) = JnE + JpE + Jre;
    IC(i) = JnC - JpC;
    IB(i) = IE(i) - IC(i);
    d.gamma = JnE/(JnE + JpE); d.alphaT = JnC/JnE; d.WB = WB;
end
end
