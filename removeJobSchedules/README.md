# Cleaning up job schedules
This can be used for both aaS and on prem installations of CPD. This example will remove the schedule in all jobs in the specified projects.

# Working with Projects

This example works specifically for Projects but can be easily customized to work with Spaces.

# Install cpdctl

You need to install cpdctl from https://github.com/IBM/cpdctl

The utility scripts that you'll use assume that cpdctl is on your search path. cpdctl is standalone so you can just copy it to a location already on your path if that is easiest.

# Install jq

These scripts rely on the utility jq for parsing JSON output from cpdctl

https://jqlang.github.io/jq/manual/

# Configure cpdctl to work with your cluster.

For example, to work with CPDaaS:

cpdctl config profile set cpdaas --url https://cloud.ibm.com --apikey {your API key}

cpdctl config profile use cpdaas

[Note: cpdaas is just the profile name, you could name it anything else you want.  You can have many of these profiles configured and can just switch to the one you want using 'cpdctl config profile use ']


for an onprem install need to provide the URL of your installation along with the username and password of the user to perform the actions

cpdctl config profile set myonprem --url https://yourinstallation.com --user {user_name} --password {password}

cpdctl config profile use myonprem

# Remove the schedules for all jobs for a given project

./removeJobScheduleAllJobsInProject.sh project_name

Note that it will create some temporary data files (all ending with .json) while it is running

