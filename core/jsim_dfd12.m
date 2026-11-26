function dF = jsim_dfd12(e)
% JSIM_DFD12  Derivative of jsim_fd12 (central difference).
h = 1e-4;
dF = (jsim_fd12(e + h) - jsim_fd12(e - h))/(2*h);
end
