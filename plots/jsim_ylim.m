function yl = jsim_ylim(varargin)
% padded y-limits over several data vectors (top margin leaves room for labels)
v = [];
for k = 1:nargin, d = varargin{k}; v = [v; d(isfinite(d(:)))]; end %#ok<AGROW>
lo = min(v); hi = max(v);
if hi - lo < 1e-12, lo = lo - 1; hi = hi + 1; end
r = hi - lo; yl = [lo - 0.06*r, hi + 0.16*r];
end
