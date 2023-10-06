#/bin/zsh
USAGE="$(basename "$0") project_name job_name"

if [ $# != 2 ] ; then
    echo $USAGE
    exit 1;
fi

echo "Deleting Job Runs for Job:" $2

# Maximum chunk size allowed is 100 (this indicates the number of job runs that will be returned for each call to cpdctl)
CHUNK_SIZE=100

# Retrieve the GUID of the Project
PROJECT_ID=`cpdctl project list --name $1 --output json -j "(resources[].metadata.guid)[0]" --raw-output`
#echo "PROJECT_ID:" $PROJECT_ID

#Retrieve the GUID of the Job
ASSET_ID=`cpdctl asset search --project-id $PROJECT_ID --type-name job --query "asset.name:$2" --output json -j "results[0].metadata.asset_id" --raw-output`
#echo "Job_ID:" $ASSET_ID

# Retrieve the first set of job runs, remember the bookmark
cpdctl job run list --project-id $PROJECT_ID --job-id $ASSET_ID --limit $CHUNK_SIZE --output json   >tmpRunChunk.json
BOOKMARK=`jq '.next' <tmpRunChunk.json`
#echo "Bookmark:" $BOOKMARK


#extract the job run ids into a file and call utility to delete all those runs
jq '.results[].metadata | [ .usage.last_update_time, .asset_id ]' -c <tmpRunChunk.json >tmpRunsList.json 2>/dev/null
./deleteAllJobRunsFromFileInProject.sh $PROJECT_ID $ASSET_ID tmpRunsList.json


#loop through remaining chunks
while [ "$BOOKMARK" != "null" ]
do
    cpdctl job run list --project-id $PROJECT_ID --job-id $ASSET_ID --next "$BOOKMARK" --limit $CHUNK_SIZE --output json   >tmpRunChunk.json
    BOOKMARK=`jq '.next' <tmpRunChunk.json`
    #echo "Bookmark:" $BOOKMARK 
    jq '.results[].metadata | [ .usage.last_update_time, .asset_id ]' -c <tmpRunChunk.json >tmpRunsList.json
    ./deleteAllJobRunsFromFileInProject.sh $PROJECT_ID $ASSET_ID tmpRunsList.json
done
rm tmpRunsList.json
rm tmpRunChunk.json
echo "Done deleting Job Runs for Job:" $2