# Burn Wound RF Sensing - Scripting

MATLAB scripts and functions for the forward transmission-line model,
signal processing, burn permittivity modeling, and inverse solver
supporting the MSc thesis (UWB burn wound detection, layered arm phantom).

## Status
See `docs/status.md` for current phase and blockers.

## Structure
- `data/raw/` - CST exports and IT'IS dispersion files, untouched
- `data/processed/` - cleaned/converted data (gitignored, regenerate from scripts/)
- `data/reference/` - literature-sourced constants (Rangaiah tables, etc.)
- `functions/forward_model/` - Gangwar eqs 1-4 (Z0, gamma, Gamma_th, cascading)
- `functions/signal_processing/` - difference, envelope, time-gating, deconvolution
- `functions/burn_model/` - Maxwell-Garnett mixing, water-content driver
- `functions/inverse_solver/` - objective function, GA wrapper
- `functions/rx_chain/` - link budget, noise floor, detectability analysis
- `functions/io/` - CST/IT'IS loaders, sigma-to-eps'' conversion
- `scripts/` - top-level runnable scripts
- `tests/` - validation gates (Fresnel check, CST overlay, synthetic recovery)
- `figures/` - generated plots (gitignored)
- `docs/` - notes, decisions log, equation derivations

## Dependencies
- MATLAB (version TBD)
- Toolboxes: Signal Processing, Global Optimization (for `ga`)

## Validation gates
The forward model is NOT trusted until:
1. Single-interface air-to-muscle matches the Fresnel coefficient exactly (`tests/`)
2. Overlay against a known CST stack matches (`tests/`, requires CST license)

## References
- Gangwar et al. - forward model equations, signal processing (eqs 1-18)
- Rangaiah [12] - Maxwell-Garnett burn permittivity model
- Rangaiah [14] - measured burn dielectric bands (validation)
