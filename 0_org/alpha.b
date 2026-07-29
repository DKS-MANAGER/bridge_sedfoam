/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\    /   O peration     | Version:  v2412                                 |
|   \\  /    A nd           | Web:      www.openfoam.com                      |
|    \\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
    version     2.0;
    format      ascii;
    class       volScalarField;
    object      alpha.b;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

dimensions      [0 0 0 0 0 0 0];

internalField   uniform 1.0;

boundaryField
{
    inlet
    {
        // zeroGradient: alpha.b=0.40 in bed set by setFields at t=0.
        // codedFixedValue was continuously re-injecting alpha.b=0.40
        // at inlet, fighting the solver and causing alpha.a+alpha.b != 1.
        type            zeroGradient;
    }
    outlet
    {
        type            zeroGradient;
    }
    bottom
    {
        type            zeroGradient;
    }
    top
    {
        type            zeroGradient;
    }
    bridge
    {
        type            zeroGradient;
    }
    frontAndBack
    {
        type            empty;
    }
}
