function txt = jsim_summary(R, C)
% JSIM_SUMMARY  Text lines with the key numbers of the simulation.
dev = R.dev; L = dev.L; kT = C.kT;
txt = {sprintf('Device: %s', dev.kind), ''};
for k = 1:dev.nL
    txt{end+1} = sprintf('Layer %d: %s, %s-type, N = %.3g cm^-3, W = %.3g um', k, L(k).name, L(k).type, L(k).N, L(k).Wum); %#ok<*AGROW>
    txt{end+1} = sprintf('   Eg = %.3f eV, chi(used) = %.3f eV, ni = %.3g cm^-3, EF - Ec = %.3f eV', ...
        L(k).Eg, L(k).chi, L(k).ni, L(k).eta*kT);
    txt{end+1} = sprintf('   minority: m0 = %.3g cm^-3, D = %.3g cm^2/s, tau = %.3g s, L = %.3g um', ...
        L(k).m0, L(k).Dm, L(k).taum, L(k).Lm*1e4);
end
txt{end+1} = '';
for j = 1:dev.nL-1
    J = dev.J(j); J0 = dev.J0(j);
    txt{end+1} = sprintf('Junction %d (%s/%s, %s):', j, L(j).name, L(j+1).name, J.kind);
    txt{end+1} = sprintf('   dEc = %+.3f eV, dEv = %+.3f eV  (%s)', J.dEc, J.dEv, L(j+1).offsetRule);
    txt{end+1} = sprintf('   Vbi = %.3f V, applied (forward +) = %+.3f V, total drop = %.3f V', J0.Vbi, dev.V(j), J.Vt);
    txt{end+1} = sprintf('   depletion approx: x_left = %.4g um, x_right = %.4g um, W = %.4g um', J.x1*1e4, J.x2*1e4, J.W*1e4);
    txt{end+1} = sprintf('   peak field (approx) = %.3g kV/cm, Cj = %.3g nF/cm^2', J.Emax/1e3, J.Cj*1e9);
end
i = R.x > 0; Ek = max(abs(R.E))/1e3;
txt{end+1} = sprintf('Numerical peak |field| = %.3g kV/cm (Poisson, %d Newton iterations)', Ek, R.iter);
iv = R.iv;
if strcmp(iv.type, 'diode')
    txt{end+1} = sprintf('Diode at V = %+.3f V: J = %.3g A/cm^2 (diffusion %.3g, SCR %.3g)', iv.Vop, iv.Jop, iv.Jdiff_op, iv.Jgr_op);
elseif strcmp(iv.type, 'bjt')
    o = iv.op;
    txt{end+1} = sprintf('Transistor at VBE = %+.3f V, VBC = %+.3f V: |JC| = %.3g A/cm^2, |JB| = %.3g A/cm^2', o.VBE, o.VBC, o.IC, o.IB);
    txt{end+1} = sprintf('   beta = %.3g, emitter efficiency = %.4f, base transport = %.4f, neutral base = %.3g nm', o.beta, o.gamma, o.alphaT, o.WB*1e7);
end
if any(dev.punch), txt{end+1} = 'WARNING: a layer is fully depleted (punch-through).'; end
if ~isempty(dev.warn)
    txt{end+1} = ''; txt{end+1} = 'Notes:';
    for k = 1:numel(dev.warn), txt{end+1} = ['  - ' dev.warn{k}]; end
end
end
