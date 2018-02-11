#!/bin/sh 
#SBATCH --job-name=HELLO
##SBATCH --workdir=/home/root
#SBATCH --ntasks-per-node=1
#SBATCH --nodes=1
#SBATCH --time=100:00
#SBATCH --output=slurm-%j.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jehoon.song@standigm.com

echo "Hello. I am `hostname`. It's nice to work with you."

ORG="${SLURM_SUBMIT_HOST}:${SLURM_SUBMIT_DIR}"
TEMP_WD=`mktemp -d`
echo "workdir: ${TEMP_WD}" 

cd $TEMP_WD

OUTPUT="${SLURM_JOB_ID}.out"

# Run Program. 
echo "# ${OUTPUT}" > ${OUTPUT}
echo "MATCH p=(x:Compound)-[*2]-(y:Disease) return x.name, y.name limit 1000;" | cypher-shell >> ${OUTPUT}

# Post Processing. 
HASH=`md5sum ${OUTPUT} | awk '{ print $1 }'`
#curl --user tableshare:sait2012$ -X MKCOL http://192.168.0.89:5005/homes/tableshare/archive/${HASH}
#curl --user tableshare:sait2012$ -T ${TEMP_WD}/${OUTPUT} http://192.168.0.89:5005/homes/tableshare/archive/${HASH}/
UPLOAD_DIR="http://192.168.0.89:5005/homes/tableshare/slurm/${SLURM_JOB_ID}"
curl -s --user "tableshare:sait2012$" -X MKCOL ${UPLOAD_DIR} 
curl -s --user "tableshare:sait2012$" -T ${TEMP_WD}/${OUTPUT} ${UPLOAD_DIR}/ 

echo "Bye!"

