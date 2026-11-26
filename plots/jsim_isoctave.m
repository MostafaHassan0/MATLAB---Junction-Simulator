function tf = jsim_isoctave()
tf = exist('OCTAVE_VERSION', 'builtin') ~= 0;
end
