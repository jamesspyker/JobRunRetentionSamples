USAGE="$(basename "$0") project_name job_name"

if [ $# != 2 ] ; then
    echo $USAGE
    exit 1;
fi

PROJECT_ID=`cpdctl project list --name $1 --output json -j "(resources[].metadata.guid)[0]" --raw-output`

ASSET_ID=`cpdctl asset search --project-id $PROJECT_ID --type-name job --query "asset.name:$2" --output json -j "results[0].metadata.asset_id" --raw-output`

echo "Removing job schedule for job:" $2
cpdctl job update  --project-id $PROJECT_ID --job-id $ASSET_ID  --body "[{\"op\":\"add\",\"path\":\"/entity/job/schedule\",\"value\":\"\"}]" --output json >>/dev/null
cpdctl job update  --project-id $PROJECT_ID --job-id $ASSET_ID  --body "[{\"op\":\"add\",\"path\":\"/entity/job/schedule_info\",\"value\":null}]" --output json >>/dev/null

