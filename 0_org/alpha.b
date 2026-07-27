/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \    /   O peration     | Version:  v2412                                 |
|   \  /    A nd           | Web:      www.openfoam.com                      |
|    \/     M anipulation  |                                                 |
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
        type            codedFixedValue;
        value           uniform 1.0;
        name            inletProfileAlphaB;
        code
        #{
            const fvPatch& boundaryPatch = patch();
            const vectorField& Cf = boundaryPatch.Cf();
            scalarField& field = *this;

            forAll(Cf, faceI)
            {
                scalar y = Cf[faceI].y();
                if (y <= 0.0)
                {
                    field[faceI] = 0.40;
                }
                else
                {
                    field[faceI] = 1.0;
                }
            }
        #};
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
