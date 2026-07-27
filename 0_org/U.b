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
    class       volVectorField;
    object      U.b;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

dimensions      [0 1 -1 0 0 0 0];

internalField   uniform (0.26 0 0);

boundaryField
{
    inlet
    {
        type            codedFixedValue;
        value           uniform (0 0 0);
        name            inletProfileUb;
        code
        #{
            const fvPatch& boundaryPatch = patch();
            const vectorField& Cf = boundaryPatch.Cf();
            vectorField& field = *this;

            forAll(Cf, faceI)
            {
                scalar y = Cf[faceI].y();
                if (y > 0.0)
                {
                    scalar ratio = Foam::max(0.0, y) / 0.10;
                    scalar u_x = 0.2971 * Foam::pow(ratio, 1.0/7.0);
                    field[faceI] = vector(u_x, 0, 0);
                }
                else
                {
                    field[faceI] = vector(0, 0, 0);
                }
            }
        #};
    }
    outlet
    {
        type            inletOutlet;
        inletValue      uniform (0 0 0);
        value           uniform (0.26 0 0);
    }
    bottom
    {
        type            noSlip;
    }
    top
    {
        type            slip;
    }
    bridge
    {
        type            noSlip;
    }
    frontAndBack
    {
        type            empty;
    }
}
