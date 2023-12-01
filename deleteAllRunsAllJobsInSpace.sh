#/bin/zsh
USAGE="$(basename "$0") space_name"

if [ $# != 1 ] ; then
    echo $USAGE
    exit 1;
fi

echo "Deleting runs for all jobs in space:" $1

#Retrieve the GUID of the space
SPACE_ID=`cpdctl space list --name $1 --output json -j "(resources[].metadata.id)[0]" --raw-output`
#echo "SPACE_ID:" $SPACE_ID

# Maximum chunk size allowed is 100 (this indicates the number of jobs that will be returned for each call to cpdctl)
CHUNK_SIZE=100

cpdctl job list --space-id $SPACE_ID --limit $CHUNK_SIZE --output json  >tmpAllJobs.json
BOOKMARK=`jq '.next' <tmpAllJobs.json`

# parse the output json to identify each Job
jq -c '.results[].metadata.name' <tmpAllJobs.json | while read i; do
    NAME=`echo $i | tr -d '"'`
    ./deleteAllJobRunsForAJobInSpace.sh $1 "${NAME}"
done

#loop through remaining chunks
while [ "$BOOKMARK" != "null" ]
do
    cpdctl job list --space-id $SPACE_ID --next "$BOOKMARK" --limit $CHUNK_SIZE --output json  >tmpAllJobs.json
    BOOKMARK=`jq '.next' <tmpAllJobs.json`
    # parse the output json to identify each Job
    jq -c '.results[].metadata.name' <tmpAllJobs.json | while read i; do
        NAME=`echo $i | tr -d '"'`
        ./deleteAllJobRunsForAJobInSpace.sh $1 "${NAME}"
    done
done

rm tmpAllJobs.json
