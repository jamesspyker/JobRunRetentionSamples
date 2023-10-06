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

cpdctl job list --space-id $SPACE_ID --output json -j "results[].metadata.name" >tmpAllJobs.json

# parse the output json to identify each Job
jq -c '.[]' <tmpAllJobs.json | while read i; do
    NAME=`echo $i | tr -d '"'`
    ./deleteAllJobRunsForAJobInSpace.sh $1 "${NAME}"
done

rm tmpAllJobs.json
