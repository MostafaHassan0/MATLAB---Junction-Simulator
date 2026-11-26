function T = band_offsets()
% BAND_OFFSETS  Measured conduction-band offsets that override Anderson's
% electron-affinity rule for specific material pairs.
% Each row: {material A, material B, dEc/dEg}, where
%   dEc = ratio * |Eg_A - Eg_B|  and the wider-gap side has the higher Ec.
% Pairs not listed here use Anderson's rule (dEc = chi_narrow - chi_wide).
T = {
  'InP',            'In0.53Ga0.47As', 0.39   % Forrest et al., APL 1984 (project folder)
  'In0.52Al0.48As', 'In0.53Ga0.47As', 0.73   % dEc ~ 0.52 eV (Ioffe / People 1983)
  'Al0.3Ga0.7As',   'GaAs',           0.65   % 65/35 rule
};
end
