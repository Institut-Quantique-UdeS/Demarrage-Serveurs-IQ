#!/bin/bash
#SBATCH --time=00:05:00 #demande 5 minutes
#SBATCH --cpus-per-task=4 #demande 4 coeurs
#SBATCH --mem=2G #demande 2GB de mémoire
#SBATCH --output=matmul.out #nom du fichier de sortie

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK #REQUIS EN TOUT TEMPS, limite le nombre de CPU sur le serveur

module load python/3.11 scipy-stack/2023b
python matvec.py 8000
