#/bin/zsh
USAGE="$(basename "$0") project_name"

if [ $# != 1 ] ; then
    echo $USAGE
    exit 1;
fi

echo "Removing job schedules for all jobs in project:" $1

#Retrieve the GUID of the project
PROJECT_ID=`cpdctl project list --name $1 --output json -j "(resources[].metadata.guid)[0]" --raw-output`

cpdctl job list --project-id $PROJECT_ID --output json -j "results[].metadata.name" >tmpAllJobs.json

# parse the output json to identify each Job
jq -c '.[]' <tmpAllJobs.json | while read i; do
    NAME=`echo $i | tr -d '"'`
    ./removeJobScheduleInProject.sh $1 "${NAME}"
done

rm tmpAllJobs.json
