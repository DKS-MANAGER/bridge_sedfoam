#!/bin/bash

# 1. Wait for the sedFoam_rbgh process to finish
echo "Waiting for sedFoam_rbgh processes to finish..."
while pgrep -f "sedFoam_rbgh" > /dev/null; do
    sleep 30
done
echo "sedFoam_rbgh simulation completed."

# 2. Run case 1: E:\DKS\B_ridgi
echo "Running Case 1: B_ridgi..."
cd /mnt/e/DKS/B_ridgi
./Allclean
source /usr/lib/openfoam/openfoam2412/etc/bashrc 2>/dev/null || true
blockMesh > log.blockMesh 2>&1
makeFaMesh > log.makeFaMesh 2>&1
decomposePar > log.decomposePar 2>&1
# Run in background via mpirun directly (so we can wait for it properly here)
mpirun --oversubscribe -np 8 sedExnerFoam -parallel > log.sedExnerFoam 2>&1
echo "Case 1: B_ridgi completed."

# 3. Run case 2: E:\DKS\B_ridgi\Ks_0.33
echo "Running Case 2: B_ridgi/Ks_0.33..."
cd /mnt/e/DKS/B_ridgi/Ks_0.33
./Allclean
blockMesh > log.blockMesh 2>&1
makeFaMesh > log.makeFaMesh 2>&1
decomposePar > log.decomposePar 2>&1
mpirun --oversubscribe -np 8 sedExnerFoam -parallel > log.sedExnerFoam 2>&1
echo "Case 2: B_ridgi/Ks_0.33 completed."

# 4. Run case 3: E:\DKS\B_ridgi\Ks_1.9
echo "Running Case 3: B_ridgi/Ks_1.9..."
cd /mnt/e/DKS/B_ridgi/Ks_1.9
./Allclean
blockMesh > log.blockMesh 2>&1
makeFaMesh > log.makeFaMesh 2>&1
decomposePar > log.decomposePar 2>&1
mpirun --oversubscribe -np 8 sedExnerFoam -parallel > log.sedExnerFoam 2>&1
echo "Case 3: B_ridgi/Ks_1.9 completed."

echo "All 3 B_ridgi simulations completed successfully."
