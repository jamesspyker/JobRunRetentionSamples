USAGE="$(basename "$0") project_name job_name"

if [ $# != 2 ] ; then
    echo $USAGE
    exit 1;
fi

PROJECT_ID=`cpdctl project list --name "$1" --output json -j "(resources[].metadata.guid)[0]" --raw-output`
#echo "PROJECT_ID:" $PROJECT_ID

ASSET_ID=`cpdctl asset search --project-id $PROJECT_ID --type-name job --query "asset.name:$2" --output json -j "results[0].metadata.asset_id" --raw-output`
#echo "Job_ID:" $ASSET_ID   

echo "Removing job retention for job:" $2
cpdctl job update  --project-id $PROJECT_ID --job-id $ASSET_ID  --body "[{\"op\":\"add\",\"path\":\"/entity/job/retention_policy\",\"value\":null}]" --output json >>/dev/null

