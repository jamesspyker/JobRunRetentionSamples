#/bin/zsh
USAGE="$(basename "$0") space_id job_id filename"
SPACE_ID=$1
ASSET_ID=$2

if [ $# != 3 ] ; then
    echo $USAGE
    exit 1;
fi

# Get the date (in epoch seconds) for 3 days in the past (two versions for OSX and Linux)
OLDDATE=`date -v -3d +%s`000
#OLDDATE=`date -d "-3 day" +%s`000

cat $3 |  while read -r
do
    TIME=`echo $REPLY | jq -r '.[0]'`
#    echo "Time:" $TIME
    RUN_ID=`echo $REPLY | jq -r '.[1]'`
#    echo "Job_Run_ID:" $RUN_ID
    if [[ $TIME -lt $OLDDATE ]]
    then
        echo "Deleting Job Run ID:" $RUN_ID
        cpdctl job run delete --space-id $SPACE_ID --job-id $ASSET_ID --run-id $RUN_ID >>/dev/null 2>&1
        #If the job run wasn't already completed, then can force the delete by uncommenting following line
        #cpdctl asset delete --space-id $SPACE_ID --asset-id $RUN_ID >>/dev/null 2>&1
    else
        echo "Retaining Job Run ID:" $RUN_ID
    fi 
done
