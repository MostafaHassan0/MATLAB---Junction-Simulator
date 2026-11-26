# Junction Simulator (MATLAB)

An interactive MATLAB app that recreates the project's interactive band and junction figures. You pick 2 or 3 materials, set each layer's doping (donors or acceptors) and the bias on each junction, and it draws:

- the energy-band diagram ($E_c$, $E_v$, $E_i$, and the quasi-Fermi levels $E_{Fn}$, $E_{Fp}$)
- the electric field $\mathcal{E}(x)$
- the electrostatic potential $\psi(x)$
- the charge density $\rho(x)/q$
- the carrier densities $n(x)$ and $p(x)$ on a log scale, with $|N_d - N_a|$ and $n_i$
- the band line-up before contact ($\chi$, $E_g$, $\Delta E_c$, $\Delta E_v$)
- I-V: a diode curve (log and linear), or for a transistor the Gummel plot and output curves
- C-V: $C_j$ and $1/C_j^2$ for each pn junction
- a text summary with $V_{bi}$, depletion widths, peak field, $C_j$, current and $\beta$

Every plot against position is shaded the same way:

| Shading / line | Meaning |
| --- | --- |
| green | quasi-neutral region (QNR) |
| orange | space-charge region, depleted (ionised dopants) |
| purple | space-charge region from mobile carriers (accumulation or inversion layer, e.g. at an n-N heterojunction) |
| dashed brown lines | edges of the depletion approximation, $-x_p$ and $x_n$ |
| solid black lines | metallurgical interfaces |

The QNR and SCR shading comes from the numerical solution: a point counts as space charge when $|\rho/q|$ is more than 10% of the local doping. The dashed lines come from the textbook depletion approximation. Comparing the two is the point: the real space-charge region has Debye tails beyond the depletion edges.

## Clone Repo

### For Online MATLAB

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=MostafaHassan0/ELEC481) or
```bash
gitclone https://github.com/MostafaHassan0/MATLAB---Junction-Simulator.git
```

### For Desktop MATLAB

[![Clone this repository](https://img.shields.io/badge/Clone-this%20repository-2ea44f?style=for-the-badge&logo=github&logoColor=white)](https://github.com/MostafaHassan0/MATLAB---Junction-Simulator) or [![Download ZIP](https://img.shields.io/badge/Download-ZIP-0969da?style=for-the-badge&logo=github&logoColor=white)](https://github.com/MostafaHassan0/MATLAB---Junction-Simulator/archive/refs/heads/main.zip)
```bash
git clone https://github.com/MostafaHassan0/MATLAB---Junction-Simulator.git
```



## How to run

1. Clone the repository (or download the ZIP and unpack it). Keep the subfolders together.
2. In MATLAB, `cd` into the folder and type `JunctionSimulatorApp`.
3. Pick a preset or set your own layers. With **Live update** on, every change re-solves (about 0.2 to 1 s).

You need MATLAB R2020b or newer (it uses `uifigure` and `uigridlayout`). No toolboxes are needed.

Other entry points:

- `run_examples` simulates four devices without the GUI and saves PNGs in `figs/`. It also runs in GNU Octave.
- `run_tests` checks the physics core against the M&K Ch. 4 formulas ($V_{bi}$, $W$, $\mathcal{E}_{max}$, $C_j$, the InP/InGaAs offset and the QFL split $qV$). All ten checks passed in Octave 8.
- **Open in figure windows** and **Save PNGs...** in the app give normal figures you can edit, zoom or export.
- **Full screen:** right-click any plot and choose *Full screen*, or press **Full screen (current tab)** to blow up the plots of the tab you are looking at. Press `Esc` (or the button in the corner) to leave.
- **Save preset...** stores the current layers, doping, widths and biases as a `.json` file in `presets/`. Your presets appear in the Preset list marked with `*`, and **Delete preset** removes the selected one. You can copy preset files between machines or edit them by hand.

## Controls

| Control | What it does |
| --- | --- |
| Layer 1, 2, 3 material | Any file in `materials/`. Set layer 3 to `none` for a 2-layer junction. |
| Donors / Acceptors | n-type or p-type. Same type on both sides gives an isotype junction (n-N or p-P). |
| N (cm^-3) | Doping, typed like `1e17`. |
| W (um) | Layer width. With **Automatic layer widths** the app picks room for the depletion regions; the transistor base gets its equilibrium depletion plus 100 nm, so reverse bias on the collector visibly shrinks the neutral base (Early effect). |
| J1, J2 bias | Magnitude in volts plus Forward or Reverse. Forward means the p side is positive. For an isotype junction, forward means the right layer is positive. For a transistor, J1 is emitter-base and J2 is base-collector, so forward-active is J1 Forward and J2 Reverse. |

Presets: Si pn diode (equilibrium, 0.5 V forward, 5 V reverse), N-AlGaAs/p-GaAs, n-InP/n-InGaAs isotype, Si npn and pnp BJT, InP/InGaAs SHBT, InP/InGaAs/InP DHBT (the project's Chau-style structure), GaInP/GaAs HBT and Si/SiGe/Si HBT.

## The materials folder

Each material is one MATLAB function file in `materials/` that returns a struct at 300 K:

| Field | Meaning |
| --- | --- |
| `name` | Name shown in the selectors |
| `Eg`, `chi` | Band gap and electron affinity (eV) |
| `eps_r` | Relative permittivity |
| `Nc`, `Nv` | Effective densities of states (cm^-3) |
| `mu_n`, `mu_p` | Caughey-Thomas mobility: `mu_max`, `mu_min`, `N_ref`, `alpha` |
| `tau_n0`, `tau_p0`, `N_srh` | Lifetime $\tau = \tau_0/(1 + N/N_{srh})$ |
| `ni` | Computed from $N_c$, $N_v$, $E_g$ |
| `ni_override` | Leave empty, or set a value (for example `1.45e10` for Si to match the book). $N_c$ and $N_v$ are then scaled by the same factor. |

Included: Si, Ge, GaAs, Al0.3Ga0.7As, In0.53Ga0.47As, InP, Ga0.51In0.49P, In0.52Al0.48As and strained Si0.8Ge0.2. The source is noted at the top of each file. Values for the ternaries are approximate, so check them against the Ioffe database before quoting them. To add a material, copy `Si.m`, rename the file and the function, change the numbers, and restart the app.

Band offsets: by default the app uses Anderson's rule ($\Delta E_c = \chi_1 - \chi_2$). `materials/pairs/band_offsets.m` overrides it for measured pairs. InP/InGaAs uses $\Delta E_c = 0.39\,\Delta E_g \approx 0.23$ eV (Forrest et al. 1984, the paper in the Project folder), InAlAs/InGaAs uses 0.73 and AlGaAs/GaAs uses 0.65.

## Physics (what the code solves)

All files are in `core/`.

1. **Neutral layers** (`jsim_eta_neutral`). Solves $n - p = N_d - N_a$ with Fermi-Dirac statistics, $n = N_c F_{1/2}\big((E_{Fn} - E_c)/kT\big)$ and $p = N_v F_{1/2}\big((E_v - E_{Fp})/kT\big)$. This gives $E_F - E_c$ and the work function $W = \chi - (E_F - E_c)$ of each layer.
2. **Bias.** Layer 1 sets $E_F = 0$. Forward bias $V$ on a junction lowers the p side's Fermi level by $qV$ relative to the n side.
3. **Depletion approximation** (`jsim_junction`, M&K Sec. 4.2 in heterojunction form). With $V_t = V_{bi} - V_a$:

$$x_1 = \sqrt{\frac{2\varepsilon_1\varepsilon_2 N_2 V_t}{q N_1(\varepsilon_1 N_1 + \varepsilon_2 N_2)}}, \qquad x_2 = x_1\frac{N_1}{N_2}$$

$$\mathcal{E}_{max} = \frac{q N_1 x_1}{\varepsilon_1}, \qquad C_j = \sqrt{\frac{q\,\varepsilon_1\varepsilon_2 N_1 N_2}{2(\varepsilon_1 N_1 + \varepsilon_2 N_2)V_t}}$$

4. **Quasi-Fermi levels** (Shockley assumptions). The majority QFL is flat in each layer. Both QFLs are flat across a pn depletion region. In a neutral region the minority QFL follows the diffusion solution, with $\Delta n = n_0(e^{qV/kT} - 1)$ at the depletion edge and $\Delta n = 0$ at the contact:

$$\Delta n(x) = \frac{\Delta n_L \sinh\big((W_q - s)/L\big) + \Delta n_R \sinh(s/L)}{\sinh(W_q/L)}$$

5. **Poisson's equation** (`jsim_solve_poisson`). Solves $\frac{d}{dx}\big(\varepsilon\,\frac{d\psi}{dx}\big) = -q(p - n + N_d - N_a)$ by Newton iteration on a grid refined near each interface, with $E_c = -q\psi - \chi$. So the band spikes and notches at heterojunctions, the Debye tails and the accumulation layers all come out of the solution and are not drawn by hand.
6. **I-V** (`jsim_iv`). For the diode, Shockley diffusion with finite neutral widths ($\coth(W/L)$) plus SCR recombination and generation, $q n_i x/(2\tau)\,(e^{qV/2kT} - 1)$. For the transistor, Ebers-Moll from base minority diffusion, with the neutral base width taken from both depletion regions (Early effect), back-injection into the emitter, and EB space-charge recombination in $I_B$.
7. **C-V** (`jsim_cv`). Uses $C_j(V)$ from step 3, and $1/C_j^2$ is linear with intercept $V_{bi}$.

## Limits to keep in mind

- Drift-diffusion transport is not solved self-consistently. The QFLs are imposed (Shockley), which is fine at low injection. The app warns you when forward bias approaches $V_{bi}$.
- There is no thermionic-emission limit at a conduction-band spike. The DHBT spike shows on the band diagram but does not reduce the I-V.
- There is no bandgap narrowing, incomplete ionisation, impact ionisation (breakdown), velocity saturation or Kirk effect.
- Everything is at T = 300 K.
- Si uses $n_i \approx 1.1\times10^{10}$ cm^-3 (Sze). The book uses $1.45\times10^{10}$; see `ni_override` above.

## Folder layout

```
JunctionSimulatorApp.m   the GUI (run this)
run_examples.m           batch example, saves PNGs to figs/
run_tests.m              checks against textbook formulas
materials/               one .m file per material (300 K)
materials/pairs/         measured band-offset overrides
core/                    physics: device build, junction, Poisson, I-V, C-V, summary
plots/                   one function per plot (works on uiaxes and normal axes)
figs/                    example output from run_examples (made in Octave) and can put saved pngs in it (only for desktop MATLAB)
tests/                   checks against textbook formulas and a batch example, saves PNGs to figs/
```                        
