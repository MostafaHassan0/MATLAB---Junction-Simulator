function mu = jsim_mobility(p, N)
% JSIM_MOBILITY  Caughey-Thomas doping-dependent mobility (cm^2/V s).
mu = p.mu_min + (p.mu_max - p.mu_min)./(1 + (N./p.N_ref).^p.alpha);
end
