# Computational Fluid Dynamics (CFD) Validation Case: Erodible-Bed Contraction Scour using SedFoam

This repository contains the OpenFOAM (v2412) implementation, grid setup, and parallel run configurations designed to model vertical bridge contraction scour over an erodible sediment bed. By utilizing the high-fidelity two-phase solver **`sedFoam_rbgh`**, this model transitions the rigid-bed vertical contraction setup from the ASCE study (Majid et al., 2026) into a fully resolved mobile-bed sediment transport, erodible bed deformation, and morphological scour evolution case.

---

## 1. Project Overview & Context

This numerical model adapts the experimental hydraulic flume configurations described in the ASCE Journal of Hydraulic Engineering study:
> **Effect of Bed Roughness on Pressure Flow due to Vertical Contraction**  
> *Sofi Aamir Majid, S.M.ASCE; Shivam Tripathi; and Debopam Das*  
> *ASCE Journal of Hydraulic Engineering (Volume 152, Issue 3, January 2026)*  
> DOI: [10.1061/JHEND8.HYENG-14490](https://doi.org/10.1061/JHEND8.HYENG-14490)

The original experimental work analyzed pressure-flow hydrodynamics under a vertical bridge contraction using a rigid bed with three roughness grades ($K_s = 0.33\text{ mm}$, $0.68\text{ mm}$, and $1.90\text{ mm}$). 

In this repository, the setup is converted into a **mobile sediment bed** to simulate morphological scour. We employ the Eulerian-Eulerian two-phase flow solver `sedFoam_rbgh` coupled with the Boyer et al. $\mu(I)$ granular rheology model to resolve granular shear deformation, dilatancy, and erosion under the bridge contraction ceiling.

---

## 2. Hydraulic & Physical Parameters

The baseline flow, fluid, and sediment properties configured in the workspace are summarized below:

### 2.1 Flow & Channel Geometry
| Parameter | Symbol | Value | Context / Reference |
| :--- | :---: | :--- | :--- |
| Approach Flow Depth | $H_a$ | $0.10\text{ m}$ | Clear-water depth above the sediment bed |
| Channel Bed Slope | $S_0$ | $0.018\%$ | Integrated as gravity component $g_x = 0.0017658\text{ m/s}^2$ |
| Channel Width | $Z_w$ | $0.30\text{ m}$ | Modeled as $0.01\text{ m}$ 2D slice (empty boundaries) |
| Bridge Constriction Length | $L$ | $0.15\text{ m}$ | Located streamwise from $x = 1.0\text{ m}$ to $x = 1.15\text{ m}$ |
| Contraction Ceiling Height | $H_b$ | $0.075\text{ m}$ | Clear throat height under the bridge soffit |
| Constriction Ratio | $H_b/H_a$ | $0.75$ | $25\%$ vertical area constriction |

### 2.2 Phase Properties & Physics
| Parameter | Symbol | Value | Case File Reference |
| :--- | :---: | :--- | :--- |
| Fluid Phase Density (Water) | $\rho_f$ | $1000\text{ kg/m}^3$ | [transportProperties](file:///e:/DKS/bridge_sedfoam/constant/transportProperties#L28) |
| Fluid Kinematic Viscosity | $\nu_f$ | $1.0 \times 10^{-6}\text{ m}^2/\text{s}$ | [transportProperties](file:///e:/DKS/bridge_sedfoam/constant/transportProperties#L29) |
| Sediment Phase Density | $\rho_s$ | $2650\text{ kg/m}^3$ | [transportProperties](file:///e:/DKS/bridge_sedfoam/constant/transportProperties#L19) |
| Median Grain Diameter | $d_{50}$ | $0.68\text{ mm}$ | [transportProperties](file:///e:/DKS/bridge_sedfoam/constant/transportProperties#L21) |
| Frictional Friction Angle | $\phi$ | $22.02^\circ$ (mus = 0.4) | [granularRheologyProperties](file:///e:/DKS/bridge_sedfoam/constant/granularRheologyProperties#L26) |
| Maximum Packing Limit | $\alpha_{s,\text{max}}$ | $0.635$ | [granularRheologyProperties](file:///e:/DKS/bridge_sedfoam/constant/granularRheologyProperties#L24) |
| Frictional Pressure Exponent | $\eta_1$ | $5$ | [ppProperties](file:///e:/DKS/bridge_sedfoam/constant/ppProperties#L29) |
| Inter-phase Drag Model | — | Gidaspow-Schiller-Naumann | [interfacialProperties](file:///e:/DKS/bridge_sedfoam/constant/interfacialProperties#L18) |
| Turbulence Formulation | — | twophasekOmega (fluid phase) | [turbulenceProperties.b](file:///e:/DKS/bridge_sedfoam/constant/turbulenceProperties.b#L22) |

---

## 3. Repository & Directory Map

The directory structure is organized as follows:

```directory
bridge_sedfoam/
├── 0_org/                      # Original boundary & initial condition fields
│   ├── alpha.a                 # Sediment phase fraction (0.60 inside bed, 0.0 above)
│   ├── alpha.b                 # Fluid phase fraction (0.40 inside bed, 1.0 above)
│   ├── U.a                     # Sediment velocity (no-slip walls, uniform zero inlet)
│   ├── U.b                     # Fluid velocity (1/7th power law inlet profile)
│   ├── p_rbgh                  # Shared dynamic pressure (zero at outlet)
│   ├── k.b                     # Fluid phase Turbulent Kinetic Energy (TKE)
│   ├── omega.b                 # Fluid phase Specific Dissipation Rate
│   ├── nut.b                   # Fluid turbulent kinematic viscosity (wall functions)
│   ├── Theta                   # Granular temperature BC
│   ├── pa                      # Shear-induced granular pressure field
│   └── alphaPlastic / delta    # Plasticity & dilatancy parameters
├── constant/                   # Physical models and fluid/solid properties
│   ├── g                       # Gravity vector with bed slope incline
│   ├── transportProperties     # Phase densities, settling parameters, viscosity limits
│   ├── granularRheologyProperties # Boyer et al. mu(I) friction & viscosity settings
│   ├── ppProperties            # Johnson-Jackson contact pressure model settings
│   ├── interfacialProperties    # Inter-phase drag model definitions
│   ├── forceProperties          # Mean pressure gradient and lift/virtual mass coefficients
│   ├── turbulenceProperties.a  # Laminar settings for solid phase
│   ├── turbulenceProperties.b  # k-omega turbulence parameters for fluid phase
│   └── twophaseRASProperties   # Two-phase RAS parameters and limiters
├── system/                     # Discretization, solvers, and parallel settings
│   ├── blockMeshDict           # Structured hex-mesh block and grading definitions
│   ├── setFieldsDict           # Sediment bed (y < 0) volume fraction initialization
│   ├── fvSchemes               # Discretization schemes (implicit time, bounded upwind)
│   ├── fvSolution              # Linear solvers, tolerances, and PIMPLE correctors
│   ├── controlDict             # Sim execution limits, write time step, adjustTimeStep
│   └── decomposeParDict        # Domain decomposition parameters (scotch, 8 processors)
├── Allclean                    # Bash utility to reset and clean case directories
├── Allrun                      # Bash utility to mesh, initialize, and launch the run
├── bridge_scour_geometry.png   # Side-view schematic of contraction domain
└── fo.foam                     # ParaView metadata load link
```

---

## 4. Solver Fixes & Rigid-to-Mobile Bed Adaptation Log

Converting the flume geometry from a rigid bed to a dynamic, erodible two-phase boundary layer required significant solver configuration changes. During testing, a numerical blow-up occurred due to `SIGFPE` (Floating Point Exception) and timestep collapses. 

The following key modifications were made to ensure numerical stability and correct physics:

### 4.1 Granular Frictional Pressure Model & Viscosity Limiter
*   **What was changed**: Corrected `PPressureModel` to **`MuI`** and set `relaxPa` to **`1e-4`** (granular pressure damping) in [constant/granularRheologyProperties](file:///e:/DKS/bridge_sedfoam/constant/granularRheologyProperties). Set `nuMax` to **`1e2`** (effective granular viscosity limiter) in [constant/transportProperties](file:///e:/DKS/bridge_sedfoam/constant/transportProperties).
*   **Why**: When granular pressure is unrelaxed or viscosity is unlimited (`nuMax` defaults to 10), the Boyer et al. effective viscosity blows up asymptotically ($\mu_{eff} \propto (1 - \alpha/\alpha_{max})^{-2}$) near the maximum packing limit. This causes numerical stiffness and solver divergence. Limiting $\mu_{eff}$ via `nuMax = 1e2` and damping the pressure updates with `relaxPa = 1e-4` stabilized the shear stress calculation near the sediment-water interface.

### 4.2 Decoupled Packing Limits
*   **What was changed**: Decoupled the packing limit in the friction/viscosity rheology model (`alphaMaxG = 0.625`) from the contact pressure model (`alphaMax = 0.635` in `ppProperties`).
*   **Why**: Having the exact same maximum limit in both models creates a mathematical singularity where the volume fraction $\alpha_a$ hits the packing limit asymptote in both models simultaneously. Decoupling them provides a physical safety margin, allowing the frictional rheology to restrict flow deformation before the contact pressure diverges.

### 4.3 Boundary Condition Corrections for Phase Fractions & Pressure
*   **What was changed**: Changed the inlet boundary condition for `alpha.a` and `alpha.b` from `codedFixedValue` to **`zeroGradient`** in [0_org/alpha.a](file:///e:/DKS/bridge_sedfoam/0_org/alpha.a) and [0_org/alpha.b](file:///e:/DKS/bridge_sedfoam/0_org/alpha.b). Changed `p_rbgh` at the `bottom` and `bridge` patches from `zeroGradient` to **`fixedFluxPressure`** in [0_org/p_rbgh](file:///e:/DKS/bridge_sedfoam/0_org/p_rbgh).
*   **Why**: The coded inlet was forcing a fixed concentration of $0.60$ at the inlet face every timestep, continuously pushing new particles into the domain and overloading the packing model at the upstream boundary. Zero gradient allows the bed to settle naturally based on the `setFields` initialization. Additionally, using `zeroGradient` for pressure on solid walls causes hydrostatic pressure decoupling in buoyant solvers; `fixedFluxPressure` ensures correct pressure-velocity coupling.

### 4.4 Discretization Scheme Stabilization
*   **What was changed**: Replaced the unbounded `Gauss linear` scheme for the Reynolds stress divergence terms `div(phiRa,Ua)` and `div(phiRb,Ub)` with **`Gauss linearUpwind grad(U.a)`** and **`grad(U.b)`** in [system/fvSchemes](file:///e:/DKS/bridge_sedfoam/system/fvSchemes).
*   **Why**: The unbounded linear scheme caused high-speed velocity oscillations and unphysical jet shear under the sharp edge of the contraction deck, driving local divergence. The bounded `linearUpwind` scheme preserves second-order accuracy while ensuring numerical stability.

### 4.5 Multi-Corrector, Under-Relaxation, & Temporal Control
*   **What was changed**: Added a `relaxationFactors` block in [system/fvSolution](file:///e:/DKS/bridge_sedfoam/system/fvSolution) (`p_rbgh` = 0.3, `U.a` = 0.5, `U.b` = 0.7, `alpha.a` = 0.5, `pa` = 0.3), set PIMPLE outer iterations to **`nOuterCorrectors 2`**, non-orthogonal correctors to **`nNonOrthogonalCorrectors 1`**, and configured `deltaT 1e-5` (startup) with `maxCo 0.3` in [system/controlDict](file:///e:/DKS/bridge_sedfoam/system/controlDict).
*   **Why**: Outer iterations and under-relaxation are necessary to damp field changes when solver coupling is strong. The conservative startup timestep allows the initialized sediment bed to adjust to the shear flow without producing numerical shockwaves, while `maxCo 0.3` allows the timestep to safely recover and accelerate once stability is achieved.

---

## 5. Prerequisites & Environment Setup

The case is configured for OpenFOAM v2412 and the community build of SedFoam:
*   **CFD Platform**: [OpenFOAM v2412](https://www.openfoam.com/)
*   **Two-Phase Solver**: community build of `sedFoam_rbgh` (with compiled community library `libroughWallFunctions.so`)
*   **Post-processing**: [ParaView](https://www.paraview.org/) or any visualization engine reading VTK/OpenFOAM formats

Ensure your shell has sourced the OpenFOAM environment before launching:
```bash
source /usr/lib/openfoam/openfoam2412/etc/bashrc
```

---

## 6. Step-by-Step Execution Guide

To clean, build, and run the simulation in parallel, run the following commands in your Linux environment:

### 6.1 Automatic Workflow Execution
The wrapper scripts clean, mesh, initialize, partition, and launch the solver. Run from the case root:
```bash
# Clean directory and launch parallel run in the background
./Allrun
```

### 6.2 Manual Execution Step-by-Step
If you prefer to execute the toolchain manually:

```bash
# 1. Clean previous run data
./Allclean

# 2. Generate the structured hexahedral mesh
blockMesh > log.blockMesh 2>&1

# 3. Copy original boundary fields
cp -r 0_org 0

# 4. Initialize sediment bed height (y < 0) and velocities
setFields > log.setFields 2>&1

# 5. Pre-write cell centers for boundary layers
postProcess -func writeCellCentres -time 0 > log.writeCellCentres 2>&1
ln -s Cx 0/ccx 2>/dev/null || true
ln -s Cy 0/ccy 2>/dev/null || true
ln -s Cz 0/ccz 2>/dev/null || true

# 6. Decompose domain into 8 subdomains for parallel execution
decomposePar > log.decomposePar 2>&1

# 7. Run the parallel solver (change -np to match your processor cores)
mpirun -np 8 sedFoam_rbgh -parallel > log.sedFoam_rbgh 2>&1 &
```

### 6.3 Directory Cleanup
To reset the repository and delete mesh files, logs, and temporal solver outputs:
```bash
./Allclean
```

---

## 7. Post-Processing & Validation Metrics

After the simulation finishes (or while it is running), you can evaluate the results using standard tools:

### 7.1 Real-Time Convergence Check
Monitor the solver outputs to ensure that continuity errors and Courant numbers remain bounded:
```bash
# View the end of the log file
tail -f log.sedFoam_rbgh

# Search for potential solver warnings
grep -i "error\|fatal\|diverge" log.sedFoam_rbgh
```

### 7.2 Bed Shear Stress ($\tau_b$) Extraction
The case is configured with `writeTau true` in [constant/forceProperties](file:///e:/DKS/bridge_sedfoam/constant/forceProperties). During execution, the solver outputs the bed shear stress profiles for the fluid and solid phases:
1. Load the case in ParaView using the dummy file `fo.foam`.
2. Apply the **Plot Over Line** filter along the sediment-water interface ($y = 0\text{ m}$, $x = 0$ to $8\text{ m}$).
3. Plot the magnitude of the fluid shear stress (`tau.b`) and solid shear stress (`tau.a`) to analyze the spatial shear stress peaks.

### 7.3 Scour Hole Profile Evolution
To track the erodible bed surface deformation over time:
1. In ParaView, select the sediment phase volume fraction field **`alpha.a`**.
2. Apply a **Contour** filter at value `alpha.a = 0.30` (representing the mid-bed concentration boundary).
3. The resulting contour line maps the morphodynamic profile of the scour hole. Export this contour as a `.csv` at different timesteps ($t = 1\text{ s}$, $5\text{ s}$, $10\text{ s}$, $60\text{ s}$) to plot the scour evolution.

---

## Acknowledgements & References

If you use or adapt this validation case, please formally cite the baseline experimental study:

```bibtex
@article{majid2026roughness,
  author = {Majid, Sofi Aamir and Tripathi, Shivam and Das, Debopam},
  title = {Effect of Bed Roughness on Pressure Flow due to Vertical Contraction},
  journal = {Journal of Hydraulic Engineering},
  volume = {152},
  number = {3},
  pages = {04025001},
  year = {2026},
  doi = {10.1061/JHEND8.HYENG-14490}
}
```

*Special thanks to the OpenFOAM Foundation and the SedFoam developer community for providing the underlying two-phase solver libraries.*
