#!/bin/sh 
#SBATCH --job-name=HELLO
#SBATCH --workdir=/tmp
#SBATCH --ntasks-per-node=1
#SBATCH --nodes=1
#SBATCH --time=100:00
#SBATCH --output=slurm-%j.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jehoon.song@standigm.com

date; 
SECONDS=0 

echo "Hello! I am `hostname`."; echo "CurrentDir: `pwd`."

ORG="${SLURM_SUBMIT_HOST}:${SLURM_SUBMIT_DIR}"

WORKDIR=`mktemp -d`
echo "WorkDir: ${WORKDIR}" 
cd ${WORKDIR}

OUTPUT="${SLURM_JOB_ID}.out"

# Run Program. 
echo "# ${OUTPUT}" > ${OUTPUT}
echo "MATCH p=(x:Compound)-[*2]-(y:Disease) return x.name, y.name limit 1000;" | cypher-shell >> ${OUTPUT}

# Post Processing. 
HASH=`md5sum ${OUTPUT} | awk '{ print $1 }'`
#curl --user tableshare:sait2012$ -X MKCOL http://192.168.0.89:5005/homes/tableshare/archive/${HASH}
#curl --user tableshare:sait2012$ -T ${WORKDIR}/${OUTPUT} http://192.168.0.89:5005/homes/tableshare/archive/${HASH}/
UPLOAD_DIR="http://192.168.0.89:5005/homes/tableshare/slurm/${SLURM_JOB_ID}"

curl -s --user "tableshare:sait2012$" -X MKCOL ${UPLOAD_DIR} 
curl -s --user "tableshare:sait2012$" -T ${WORKDIR}/${OUTPUT} ${UPLOAD_DIR}/ 

rm -rf ${WORKDIR}

echo "Elapsed Time: ${SECONDS}s."
echo "Bye!"; date 
