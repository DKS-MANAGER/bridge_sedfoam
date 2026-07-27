# CFD Bridge Scour Simulation with sedFoam_rbgh

This repository contains the OpenFOAM (v2412) implementation, grid setup, and configuration for simulating **vertical bridge contraction scour over an erodible sediment bed** using the two-phase solver **`sedFoam_rbgh`**.

Rather than utilizing a static, rigid rough bed boundary layer approximation, this case models a full $10\text{ cm}$ erodible sediment bed beneath the water column, allowing resolved sediment transport, bed mobilization, and scour development.

---

## 1. Simulation Setup & Physics

### 1.1 Spatial Domain & Mesh
- **Dimensions**: $8.0\text{ m}$ (Length) $\times$ $0.20\text{ m}$ (Total Height: $0.10\text{ m}$ sediment bed + $0.10\text{ m}$ fluid column) $\times$ $0.01\text{ m}$ (2D slice).
- **Sediment Bed**: Located from $y = -0.10\text{ m}$ to $y = 0.0\text{ m}$ (initialized with sediment volume fraction $\alpha_a = 0.60$).
- **Bridge Constriction**: Extends from $x = 1.0\text{ m}$ to $x = 1.15\text{ m}$ ($L = 0.15\text{ m}$) with a ceiling block from $y = 0.075\text{ m}$ to $y = 0.10\text{ m}$ (constriction height $H = 0.025\text{ m}$, clear throat height $H_b = 0.075\text{ m}$).
- **Mesh Density**: Structured hexahedral grid refined at the bed-water interface.

### 1.2 Boundary & Initial Conditions

| Field | Description | Inlet BC | Bed (Bottom Wall) | Top Lid |
|---|---|---|---|---|
| **`alpha.a`** | Sediment Volume Fraction | Erodible bed profile ($\alpha_a = 0.60$ for $y \le 0$, else $0.0$) | `zeroGradient` | `zeroGradient` |
| **`alpha.b`** | Fluid Volume Fraction | Erodible bed profile ($\alpha_b = 0.40$ for $y \le 0$, else $1.0$) | `zeroGradient` | `zeroGradient` |
| **`U.a`** | Sediment Velocity | `fixedValue` uniform $(0, 0, 0)$ | `noSlip` | `slip` |
| **`U.b`** | Fluid Velocity | Coded 1/7th power-law boundary layer | `noSlip` | `slip` |
| **`p_rbgh`** | Shared Pressure | `zeroGradient` | `zeroGradient` | `slip` |

---

## 2. Solver & Execution

The solver used is **`sedFoam_rbgh`**, which resolves the two-phase flow equations using an Eulerian-Eulerian formulation, accounting for inter-phase drag, particle-particle interactions (granular rheology), and turbulent dispersion.

### 2.1 Automated Workflow
- **`./Allrun`**: Automatically cleans previous runs, generates the structured mesh using `blockMesh`, copies the `0_org` templates, initializes the fields with `setFields`, and runs the solver in parallel.
- **`./Allclean`**: Resets the directory to a pristine state.

### 2.2 Running the Simulation
To clean, setup, and run the simulation in parallel (4 cores):
```bash
./Allrun
```
To monitor the logs:
```bash
tail -f log.sedFoam_rbgh
```
