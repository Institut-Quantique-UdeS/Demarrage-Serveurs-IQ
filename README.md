# Demarrage-Serveurs-IQ

Ce dépôt présente comment bien démarrer sur les serveurs de l'IQ et lancer son premier calcul.
Il est un complément de la [documentation des serveurs de calcul](https://institut-quantique-udes.github.io/Presentation-Plateforme-CHP/) et de la [documentation de l'Alliance](https://docs.alliancecan.ca/) pour les grappes nationales dont la plateforme essait de reproduire l'expérience.

## Prérequis

* Avoir soit un compte pour la plateforme CHP de l'IQ, soit un professeur membre de l'IQ etun compte à l'Alliance de Recherche Digitale du Canada, voir la section [Demande d'accès aux ressources](https://institut-quantique-udes.github.io/Presentation-Plateforme-CHP/description.html#demande-d-acces-aux-ressources)
* Un accès à un client SSH (ligne de commande sous Linux et MacOS, ou PowerShell sur Windows)
* Savoir utiliser la ligne de commande Unix. Si débutant, consulter la [formation de Software Capentry](https://swcarpentry.github.io/shell-novice/) sur le sujet.

## Description et connexion à la plateforme

La plateforme de Calcul Haute Performance (CHP) de l'IQ se compose de:

* Trois serveurs de type « CPU » équipés de deux processeurs AMD EPYC 7643 (48 coeurs à 2.3 GHz chacun), 512 GB de mémoire vive et un SSD local de 1 TB
* Un serveur de type « GPU » équipé de deux accélérateurs NVIDIA A40 avec 48 GB de mémoire vive GDDR6 dédiée, deux processeurs Intel Xeon Gold 6342 (24 coeurs à 2.8 GHz chacun), 512 GB de mémoire vive principal et un SSD local de 1TB
* Un serveur de données (NAS) équipé de 24 disques SAS de 16 TB chacun, de deux processeurs Intel Xeon Gold 6226R (16 coeurs à 2.9 GHz chacun) et de 256 GB de RAM. Les données sont dupliquées sur les disques pour un stockage disponible d’environ 190 TB.

Les ressources en calcul CPU et GPU sont accessibles par un ordonnanceur qui maximise l'utilisation des ressources, il n'y a pas d'accès direct aux serveurs.
À la place, les utilisateurs ont accès à un noeud de connexion (nommé `ip09`) qui permet de gérer les fichiers et les programmes et de soumettre les tâches de calcul à l'ordonnanceur.
Les utilisateurs s'y connectent par SSH avec:

```
ssh [username]@ip09.ccs.usherbrooke.ca
```

À l'arrivée, les usagers ont affaire à un environnement standard Unix et configuré de la même manière que les grappes nationales de l'Alliance (tels que Narval, Béluga, Graham, Cedar et Niagara).
En revanche, les calculateurs de l'IQ n'ont pas accès à l'espace $HOME des usagers. 
Il est par conséquent obligatoire de travailler sur le serveur de données de l'IQ situé à `/net/nfs-iq/data/[username]` qui possède de plus de bien meilleures performances en lecture et écriture de fichier depuis les serveurs de calcul de l'IQ:

```
cd /net/nfs-iq/data/[username]
```

## Créer son environnement de travail

### Charger des logiciels

Page de la documentation de l'Alliance: [https://docs.alliancecan.ca/wiki/Utiliser_des_modules](https://docs.alliancecan.ca/wiki/Utiliser_des_modules)

Les serveurs de calcul sont configurés avec la pile logicielle de l'Alliance de Recherche Digitale du Canada, qui contient plus de 5000 logiciels installées avec diverses versions (voir documentation de l'Alliance, section [Logiciels disponibles](https://docs.alliancecan.ca/wiki/Available_software/fr)).
Les logiciels sont mis à disposition des usagers sous forme de modules, qui sont activés à la demande.
La commande `module` permet de gérer et de chercher des modules sur les serveurs de l'IQ:

```
module spider [mot clé]      # Recherche dans tous les modules
module avail [mot clé]       # Recherche dans les modules qui peuvent être chargés immédiatement
module load [module/version] # Charge un module
module unload [module]       # Déactive un module
module list                  # Liste les modules activés
module purge                 # Déactive tous les modules
```

De manière générale, un usager se connecte à la plateforme via `ip09.ccs.usherbrooke.ca`, recherche un module avec ``spider``, recherche les informations d'une version particulière puis charge le module tel qu'indiqué. 
À noter que tous les modules ont des noms en minuscule.
Par exemple, `module spider triqs` retourne deux versions disponibles, `module spider triqs/3.1.1` retourne plus d'information sur la version 3.1.1, puis l'usager charge TRIQS 3.1.1 avec `module load StdEnv/2020 gcc/10.3.0 openmpi/4.1.1 triqs/3.1.1`.


### Script Python

Page de la documentation de l'Alliance: [https://docs.alliancecan.ca/wiki/Python/fr](https://docs.alliancecan.ca/wiki/Python/fr)

Plusieurs versions de Python sont installées par défaut sur les serveurs, avec Python 2.7 et de 3.5 à 3.11.
En revanche, seules les versions Python 3.8 à 3.11 sont encore supportées et les usagers doivent favoriser l'utilisation de ces versions.
Python est chargé avec la commande `module`, tel que (pour Python 3.11) `module load python/3.11`.

La pile logicielle utilisée par les serveurs de l'IQ possède un dépôt de librairies précompilées et optimisées pour les serveurs.
La commande `avail_wheels [nom_lib_python]` permet de lister les versions disponibles et précompilées des librairie pour les différentes versions de Python.
Par exemple, le simulateur de circuit quantique `qiskit_aer`, la commande:

```
[moroub@ip09 ~]$ avail_wheels qiskit_aer
name        version    python    arch
----------  ---------  --------  ------
qiskit_aer  0.12.2     cp39      avx2
qiskit_aer  0.12.2     cp311     avx2
qiskit_aer  0.12.2     cp310     avx2
```

indique que `qiskit_aer` version 0.12.2 est disponible de Python 3.9 à 3.11.
Pour plus d'information sur la commande `avail_wheels`, utilisez l'aide de la commande: `avail_wheels -h`.
Les librairies s'installent ensuite avec la commande `pip install [librarie] --no-index`.
L'option `--no-index` permet de chercher uniquement dans les librairies précompilées et optimisées (recommandé).

À noter que les librairies Python communes au calcul scientifique (tel que NumPy, SciPy et d'autres) sont regroupées dans un module nommé `scipy-stack`.
Il se charge avec `module spider scipy-stack` pour voir les versions disponibles et `module load scipy-stack/[version]`.
D'autres librairies viennent aussi en extension de certains modules, comme par exemple les librairies Python `symengine` ou `triqs_maxent` qui viennent en extension des modules `symengine` et `triqs` respectivement.
Ces dernières s'affichent lorsque recherchées avec `module spider [librairie]`, et il suffit de charger le module correspondant pour avoir accès à la librairie.

Dernièrement, l'utilisation d'environnement virtuel est recommandé.
Ils permettent d'isoler chaque application ou tâche de calcul où seules les dépendances minimales sont installées, et évite ainsi une gestion globale des librairies Python.
Les commandes principales sont:

```
module load python/[version] #charge la version Python pour créer l'environnement
virtualenv [nom_environnement] --no-download #crée l'environnement
source [chemin_vers_l'env]/[nom_environnement]/bin/activate #entre dans l'environnement
deactivate #quitte l'environnement
```

À noter qu'il est nécessaire de charger `scipy-stack` et les autres modules avec extension avant d'entrer dans l'environnement virtuel pour que les librairies Python qu'ils contiennent soient visibles dans ce dernier.


### Transférer ses données

La commande `scp` est recommandée pour envoyer des données locales depuis son ordinateur vers les serveurs de l'IQ.
La commande est (depuis un terminal sur l'ordinateur local):

```
scp -r [fichier_ou_dossier_local] [username]@ip09.ccs.usherbrooke.ca:/net/nfs-iq/data/[username]/
```

Ou, depuis les serveurs de l'IQ vers son ordinateur local:

```
scp -r [username]@ip09.ccs.usherbrooke.ca:/net/nfs-iq/data/[username]/[chemin_vers_le_fichier] .
```

Il est aussi possible de monter son espace utilisateur de l'IQ dans un dossier local via SSHFS sur Mac et Linux:

```
mkdir home-IQ
sshfs [username]@ip09.ccs.usherbrooke.ca:/net/nfs-iq/data/[username] ./home-IQ
```

qui permet d'utiliser le serveurs de données de l'IQ comme un répertoire local sur son ordinateur (plus ergonomique).


## Lancer ses calculs

Il est du devoir de l'usager de connaître les tâches qu'il soumet, c'est-à-dire, si la tâche est séquentiel (un seul coeur de calcul), parallélisé par fils (plusieurs coeurs sur un même serveur, tâche OpenMP) ou parallélisé par processus (plusieurs coeurs sur un seul/plusieurs serveurs, tâche MPI); sa consommation de mémoire, le temps nécessaire, et si un GPU est nécessaire ou non.
Les calculs ne doivent pas s'effectuer sur le noeud de connexion `ip09`, car il s'agit d'un noeud partagé pour la gestion des données et la configuration de l'environnement de travail.
Ils doivent être décrit dans un script de tâche, puis soumis à l'ordonnanceur qui devient alors responsable d'exécuter la tâche.


### Calcul CPU

Page de la documentation de l'Alliance: [https://docs.alliancecan.ca/wiki/Running_jobs/fr](https://docs.alliancecan.ca/wiki/Running_jobs/fr).

RAPPEL: Toutes les données des tâches de calcul doivent se trouver sur le serveurs de données de l'IQ, soit dans `/net/nfs-iq/data/[username]`.

Une simple tâche de calcul à titre éducatif serait de charger le logiciel ABINIT en version 9.6.2 et d'afficher la version du logiciel chargé.
Les commandes pour y parvenir sont:

```
module load abinit/9.6.2
abinit --version
```

Cette tâche est séquentielle est ne demande que peu de temps et de mémoire. Le script de tâche est donc:

```
#!/bin/bash
#SBATCH --time=00:05:00 #demande 5 minutes
#SBATCH --cpus-per-task=1 #demande 1 coeur
#SBATCH --mem=256M #demande 256MB de mémoire
#SBATCH --output=version-abinit.out #nom du fichier de sortie

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK #REQUIS EN TOUT TEMPS, limite le nombre de CPU sur le serveur

module load abinit/9.6.2
echo "Version de ABINIT:"
abinit --version
```

Cet exemple de tâche est disponible dans le dossier `examples`.
Elle est soumise sur les noeuds de l'IQ avec la commande:

```
sbatch -p c-iq version-abinit.sh
```

L'option `-p c-iq` est nécessaire pour soumettre sur la partition des noeud de l'IQ, à placer juste après la commande `sbatch`.
La commande `sbatch` retourne alors l'identifiant unique de la tâche de calcul, par exemple `Submitted batch job 1806355`.
L'ordonnanceur donne la tâche aux serveurs de calcul en fonction de la disponibilité des serveurs, la priorité de l'usager (définie selon son utilisation passée des serveurs) et des demandes de ressources (mémoire et CPUs).
La commande `sq` permet de voir le statut des tâches soumises, par exemple:

```
JOBID     USER      ACCOUNT           NAME  ST  TIME_LEFT NODES CPUS       GRES MIN_MEM NODELIST (REASON) 
1806355   moroub def-moroub_c version-abinit   R       5:26     1    1     (null)    256M cp3702 (None)
```

À la fin de l'exécution de la tâche, le résultat est enregistré dans le fichier de sortie spécifiée par l'option `--output` dans le script de tâche, au même endroit d'à partir duquel il a été lancé.
L'exemple précédent retourne dans `version-abinit.out`:

```
Version de ABINIT:
9.6.2
```

Finalement, la commande `seff [jobid]` permet d'avoir les statistiques d'utilisation des ressources par la tâche, par exemple:

```
Job ID: 1806355
Cluster: mp2
User/Group: moroub/moroub
State: COMPLETED (exit code 0)
Cores: 1
CPU Utilized: 00:00:02
CPU Efficiency: 25.00% of 00:00:08 core-walltime
Job Wall-clock time: 00:00:08
Memory Utilized: 1012.00 EB
Memory Efficiency: 0.39% of 256.00 MB
```

La tâche a durée 8 secondes avec 25% d'efficacité CPU et moins de 1% d'efficacité mémoire, ce qui est peut mais normal à la vue de la faible complexité de la tâche en exemple.

Un autre exemple utilisant la parallélisation par fils OpenMP est aussi disponible dans le dossier sous le nom `matmul.sh`, qui multiplie deux matrices carrées avec NumPy dont la taille est définie par la ligne de commande.
Un bon exercice serait de lancer la tâche avec différent nombre de CPUs via l'option `--cpus-per-task` et voir l'évolution du temps de calcul.


### Calcul GPU

Page de la documentation de l'Alliance: [https://docs.alliancecan.ca/wiki/Using_GPUs_with_Slurm/fr](https://docs.alliancecan.ca/wiki/Using_GPUs_with_Slurm/fr).

Les tâches GPUs sont semblables aux tâches CPU et doivent être définies avec un script de tâche.
En revanche, et contrairement à la documentation de l'Alliance, les GPUs ne sont pas définis dans l'ordonnanceur SLURM.
Pour soumettre une tâches GPU sur le serveur GPU de l'IQ, le nom du noeud GPU doit être défini explicitement, par exemple:

```
sbatch -p c-iq --nodelist=cp3705 job-gpu.sh
```

Pour plus d'information, voir la [documentation des serveurs de l'IQ](https://institut-quantique-udes.github.io/Presentation-Plateforme-CHP/job.html#calcul-sur-gpu).
