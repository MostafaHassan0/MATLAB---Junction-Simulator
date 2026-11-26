function CV = jsim_cv(dev, C)
% JSIM_CV  Depletion capacitance per unit area of each pn junction,
%   Cj = sqrt( q e1 e2 N1 N2 / (2 (e1 N1 + e2 N2)(Vbi - V)) ),
% so 1/Cj^2 is linear in V with intercept Vbi (M&K Sec. 4.2).
CV.j = {};
for j = 1:dev.nL-1
    if ~dev.J(j).isPN, continue; end
    A = dev.L(j); B = dev.L(j+1); Vb = dev.J0(j).Vbi;
    V = linspace(-max(3, -dev.V(j) + 1), Vb - 0.05, 300);
    Cj = zeros(size(V));
    for i = 1:numel(V)
        EFr = A.EF - V(i); if A.type == 'p', EFr = A.EF + V(i); end
        Jx = jsim_junction(A, B, A.EF, EFr, C); Cj(i) = Jx.Cj;
    end
    s.V = V; s.C = Cj; s.Vbi = Vb; s.Vop = dev.V(j); s.Cop = dev.J(j).Cj;
    s.name = sprintf('J%d (%s/%s)', j, A.name, B.name);
    CV.j{end+1} = s;
end
end
