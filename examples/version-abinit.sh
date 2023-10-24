#!/bin/bash
#SBATCH --time=00:05:00 #demande 5 minutes
#SBATCH --cpus-per-task=1 #demande 1 coeur
#SBATCH --mem=256M #demande 256MB de mémoire
#SBATCH --output=version-abinit.out #nom du fichier de sortie

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK #REQUIS EN TOUT TEMPS, limite le nombre de CPU sur le serveur

module load abinit/9.6.2
echo "Version de ABINIT:"
abinit --version
