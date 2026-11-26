function R = jsim_simulate(cfg)
% JSIM_SIMULATE  Full simulation: device -> Poisson -> I-V, C-V, summary.
C = jsim_const();
dev = jsim_build_device(cfg, C);
R = jsim_solve_poisson(dev, C);
R.iv = jsim_iv(R.dev, C);
R.cv = jsim_cv(R.dev, C);
R.C = C;
R.summary = jsim_summary(R, C);
end
