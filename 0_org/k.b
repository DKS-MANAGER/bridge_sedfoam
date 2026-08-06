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
    object      k.b;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

dimensions      [0 2 -2 0 0 0 0];

internalField   uniform 4.594e-4;

boundaryField
{
    inlet
    {
        type            codedFixedValue;
        value           uniform 1e-8;
        name            inletProfileKb;
        code
        #{
            const fvPatch& boundaryPatch = patch();
            const vectorField& Cf = boundaryPatch.Cf();
            scalarField& field = *this;

            forAll(Cf, faceI)
            {
                scalar y = Cf[faceI].y();
                if (y > 0.0)
                {
                    field[faceI] = 4.594e-4;
                }
                else
                {
                    field[faceI] = 1e-8;
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
        type            kqRWallFunction;
        value           uniform 1e-8;
    }
    top
    {
        type            slip;
    }
    bridge
    {
        type            kqRWallFunction;
        value           uniform 4.594e-4;
    }
    frontAndBack
    {
        type            empty;
    }
}
