#/bin/zsh
USAGE="$(basename "$0") project"

if [ $# != 1 ] ; then
    echo $USAGE
    exit 1;
fi

echo "Deleting runs for all jobs in project:" $1

#Retrieve the GUID of the project
PROJECT_ID=`cpdctl project list --name $1 --output json -j "(resources[].metadata.guid)[0]" --raw-output`
#echo "PROJECT_ID:" $PROJECT_ID

# Maximum chunk size allowed is 100 (this indicates the number of jobs that will be returned for each call to cpdctl)
CHUNK_SIZE=100

cpdctl job list --project-id $PROJECT_ID --limit $CHUNK_SIZE --output json  >tmpAllJobs.json
BOOKMARK=`jq '.next' <tmpAllJobs.json`

# parse the output json to identify each Job
jq -c '.results[].metadata.name' <tmpAllJobs.json | while read i; do
    NAME=`echo $i | tr -d '"'`
    ./deleteAllJobRunsForAJobInProject.sh $1 "${NAME}"
done

#loop through remaining chunks
while [ "$BOOKMARK" != "null" ]
do
    cpdctl job list --project-id $PROJECT_ID --next "$BOOKMARK" --limit $CHUNK_SIZE --output json  >tmpAllJobs.json
    BOOKMARK=`jq '.next' <tmpAllJobs.json`
    # parse the output json to identify each Job
    jq -c '.results[].metadata.name' <tmpAllJobs.json | while read i; do
        NAME=`echo $i | tr -d '"'`
        ./deleteAllJobRunsForAJobInProject.sh $1 "${NAME}"
    done
done

rm tmpAllJobs.json
