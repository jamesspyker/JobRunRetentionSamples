USAGE="$(basename "$0") space_name job_name"

if [ $# != 2 ] ; then
    echo $USAGE
    exit 1;
fi

SPACE_ID=`cpdctl space list  --name "$1" --output json -j "(resources[].metadata.id)[0]" --raw-output`
echo "SPACE_ID:" $SPACE_ID

ASSET_ID=`cpdctl asset search --space-id $SPACE_ID --type-name job --query "asset.name:$2" --output json -j "results[0].metadata.asset_id" --raw-output`
echo "Removing job run retention settings for #Job_ID:" $ASSET_ID   

echo "Removing job retention for job:" $2
cpdctl job update  --space-id $SPACE_ID --job-id $ASSET_ID  --body "[{\"op\":\"add\",\"path\":\"/entity/job/retention_policy\",\"value\":null}]" --output json >>/dev/null

