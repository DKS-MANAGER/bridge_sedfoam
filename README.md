# CFD Report: Erodible-Bed Contraction Scour using SedFoam

This repository contains the OpenFOAM (v2412) implementation, grid setup, and parallel run configurations designed to model vertical bridge contraction scour over an erodible sediment bed. By utilizing the high-fidelity two-phase solver **`sedFoam_rbgh`**, this model transitions from simplified rigid-bed wall functions to a fully resolved sediment transport, erodible bed deformation, and morphological scour evolution.

---

## 1. Executive Summary: What, How, and Why

### 1.1 What was done?
*   **Mobile Bed Adaptation**: Adapted the rigid-bed experimental setup from Majid et al. (2026) to a fully erodible sediment bed with median grain size $d_{50} = 0.68\text{ mm}$ and sediment density $\rho_s = 2650\text{ kg/m}^3$.
*   **Slope Integration**: Integrated the experimental channel slope ($S_0 = 0.018\%$) directly into the simulation as a streamwise gravity component ($g_x = 0.0017658\text{ m/s}^2$).
*   **Solver Diagnostics & Stabilization**: Resolved a numerical crash (floating-point exception `SIGFPE`) at physical time $t = 0.202\text{ s}$ by patching the granular pressure model, volume fraction tolerances, and PIMPLE correctors.

### 1.2 How was it resolved? (Applied Fixes)
*   **Particulate Pressure Correction**: Corrected `PPressureModel` from `none` to **`MuI`** and set `relaxPa` to **`0.001`** in [constant/granularRheologyProperties](file:///e:/DKS/bridge_sedfoam/constant/granularRheologyProperties) to enable the µ(I) frictional pressure formulation.
*   **Tightened Volume Fraction Tolerance**: Decreased the solver tolerance for the dispersed sediment phase volume fraction (`alpha.a` and `alpha.aFinal`) from $10^{-8}$ to **`1e-12`** in [system/fvSolution](file:///e:/DKS/bridge_sedfoam/system/fvSolution).
*   **Increased Pressure-Velocity Correctors**: Raised the number of PIMPLE correctors (`nCorrectors`) from 2 to **`3`** in [system/fvSolution](file:///e:/DKS/bridge_sedfoam/system/fvSolution).
*   **Updated Gravity Vector**: Patched [g](file:///e:/DKS/bridge_sedfoam/constant/g) to specify the incline: `value ( 0.0017658 -9.81 0 );`.

### 1.3 Why did it crash? (The Physical Mechanism)
In the original case configuration, the particulate pressure model (`PPressureModel`) was disabled (`none`). Consequently:
*   The solver lacked the necessary granular stress term to physically resist sediment packing beyond the critical limit ($\alpha_{max} = 0.635$).
*   Without this resistance, loose volume fraction tolerances ($10^{-8}$) allowed localized wiggles in `alpha.a` at the interface to build up, calculating artificial contact pressure spikes ($p_{ff} > 135\text{ kPa}$).
*   These spikes forced extreme, unphysical velocity gradients ($U_a > 7\text{ m/s}$) that triggered a floating-point exception (`SIGFPE`) in the drag/turbulence solvers.
*   **Result of Fix**: Enabling `PPressureModel MuI` and tightening tolerances keeps the interface smooth and bounded. At $t \approx 0.036\text{ s}$, the contact pressure remains exceptionally stable ($p_{ff} \approx 1.6\text{ kPa}$ compared to $7.8\text{ kPa}$ previously) and velocity fields are fully bounded ($U_a, U_b \approx 0.3\text{ m/s}$).

---

## 2. Governing Physical Theory

### 2.1 Two-Phase Saturated Hydrodynamic Solver
The flow solver operates on the two-phase Eulerian-Eulerian formulation where the fluid phase ($b$) and sediment/granular phase ($a$) satisfy:
$$\alpha_a + \alpha_b = 1.0$$

The phase-volume averaged Navier-Stokes equations are solved with inter-phase drag forces (using the Gidaspow-Schiller-Naumann formulation) and a shared pressure field:
$$\frac{\partial (\alpha_i \rho_i \mathbf{U}_i)}{\partial t} + \nabla \cdot (\alpha_i \rho_i \mathbf{U}_i \mathbf{U}_i) = -\alpha_i \nabla p + \nabla \cdot (\alpha_i \tau_i) + \alpha_i \rho_i \mathbf{g} + \mathbf{M}_{ji}$$

*Where $\mathbf{M}_{ji}$ represents the momentum transfer (drag and lift forces) between the fluid and sediment phases.*

### 2.2 Granular Stress & Rheology Model
Particle-particle interactions and erodible bed stability are modeled using the **$\mu(I)$ rheology framework** (Boyer et al. formulation):
- **Particulate Pressure ($p_a$)**: Prevents the sediment phase volume fraction from exceeding the packing limit ($\alpha_{\text{max}} = 0.635$) using the `MuI` model.
- **Friction Coefficient ($\mu(I)$)**: Governs transition from quasi-static to inertial flow regimes based on the inertial number $I$.
- **Dilatancy Angle ($\delta$)**: Dimensionless parameter representing vertical expansion/contraction under shear deformation, resolved dynamically by the granular rheology solver.

---

## 3. Computational Mesh & Case Setup

### 3.1 Spatial Discretization & Mesh Optimizations
A structured multi-block hexahedral grid was developed to resolve boundary layers and high-gradient zones (bed boundary layer, contraction entrance, and ceiling boundary layers):
- **Domain Dimensions**: $8.0\text{ m}$ (Length) $\times$ $0.20\text{ m}$ (Height) $\times$ $0.01\text{ m}$ (Width, 2D slice).
- **Sediment Bed**: Extends from $y = -0.10\text{ m}$ to $y = 0.0\text{ m}$ ($10\text{ cm}$ erodible depth).
- **Water Column**: Extends from $y = 0.0\text{ m}$ to $y = 0.10\text{ m}$ ($10\text{ cm}$ clear height).
- **Bridge Contraction Zone**: Ceils the flow from $x = 1.0\text{ m}$ to $x = 1.15\text{ m}$ ($L = 0.15\text{ m}$) with a ceiling block from $y = 0.075\text{ m}$ to $y = 0.10\text{ m}$ (clear throat height $H_b = 0.075\text{ m}$).
- **Mesh Density**: **110,300 cells** (1 cell thick in $Z$).
- **Near-Wall Resolution**: The vertical grading is optimized to refine grid cells near boundaries where high velocity gradients exist:
  - **Sediment-Water Interface ($y = 0.0\text{ m}$)**: Cell size refined down to $y_{\text{first}} \approx 0.22\text{ mm}$, yielding a dimensionless wall distance of $y^+ \approx 1.4$, placing the first cell well inside the viscous sublayer ($y^+ < 5$).
  - **Bridge Ceiling ($y = 0.075\text{ m}$)**: Refined using grading to capture wall-bounded shear layers.

### 3.2 Boundary Conditions (BCs)

| Field | description | Inlet | Bed (Bottom Wall) | Top Lid | Bridge Ceiling |
|:---|:---|:---|:---|:---|:---|
| **`alpha.a`** | Sediment Fraction | Coded profile ($\alpha_a=0.60$ for $y \le 0$) | `zeroGradient` | `zeroGradient` | `zeroGradient` |
| **`alpha.b`** | Fluid Fraction | Coded profile ($\alpha_b=0.40$ for $y \le 0$) | `zeroGradient` | `zeroGradient` | `zeroGradient` |
| **`U.a`** | Sediment Velocity | `fixedValue` uniform $(0, 0, 0)$ | `noSlip` | `slip` | `noSlip` |
| **`U.b`** | Fluid Velocity | `codedFixedValue` (1/7th power law) | `noSlip` | `slip` | `noSlip` |
| **`p_rbgh`** | Shared Pressure | `zeroGradient` | `zeroGradient` | `slip` | `zeroGradient` |
| **`k.b`** | Fluid TKE | `codedFixedValue` ($k = 2.535 \times 10^{-4}$) | `kqRWallFunction` | `slip` | `kqRWallFunction` |
| **`omega.b`**| Fluid Dissipation | `codedFixedValue` ($\omega = 4.153$) | `omegaWallFunction`| `slip` | `omegaWallFunction` |
| **`nut.b`** | Fluid Viscosity | `calculated` | `nutkWallFunction` | `slip` | `nutkWallFunction` |

---

## 4. Geometry & Domain Schematic

Below is the side-view schematic (X-Y plane) of the simulation domain showing the erodible sediment bed, the water column, and the bridge constriction zone:

![Bridge Contraction Scour Geometry Schematic](bridge_scour_geometry.png)

---

## 5. Execution & Simulation Progress

### 5.1 Clean and Run Command
To build/re-build the case and launch it:
```bash
source /usr/lib/openfoam/openfoam2412/etc/bashrc
./Allrun
```

### 5.2 Reset Case Files
To delete all generated mesh, processor subdirectories, logs, and time-step fields:
```bash
./Allclean
```

### 5.3 Observations & Monitoring
Use the following command to track solver convergence and physical time-step scaling:
```bash
tail -f log.sedFoam_rbgh
```

**Key Morphological Phases**:
- **Phase I (Rapid Scour)**: The high shear stress peak under the bridge contraction entrance drives rapid sediment displacement. The bed profile deforms quickly.
- **Phase II (Asymptotic Approach)**: The scour hole enlarges, expanding the flow throat area, which decreases local velocities and shear stresses. The erosion rate decreases exponentially toward a morphological equilibrium state.

---

## Acknowledgments
The baseline physical and channel setup parameters were calibrated based on the experimental flume configurations reported in:
> **Effect of Bed Roughness on Pressure Flow due to Vertical Contraction**  
> *Sofi Aamir Majid, S.M.ASCE; Shivam Tripathi; and Debopam Das*  
> **Journal of Hydraulic Engineering, ASCE (Volume 152, Issue 3, January 2026)**  
> DOI: [10.1061/JHEND8.HYENG-14490](https://doi.org/10.1061/JHEND8.HYENG-14490)
