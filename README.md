# Maintaining Job Runs
This can be used for both aaS and on prem installations of CPD. This example emulates the behaviour you'd see if you configured the job retention for each job to retain job runs for 3 days but you could alter these to use any criteria you wanted for determining which job runs to delete.

# Working with Projects or Spaces

There are two different sets of scripts for working with Projects or Spaces but the same functionality is available for both.  The notes below happen to describe the Space version of the scripts.

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

cpdctl config profile set myonprem --url https://yourinstallation.com --username {user_name} --password {password}

cpdctl config profile use myonprem

# Clean up job runs for a given space

./deleteAllRunsAllJobsInSpace.sh space_name

Note that it will create some temporary data files (all ending with .json) while it is running

# Configuring the cleanup

The threshold for determining which runs to delete is in the script deleteAllJobRunsFromFileInSpace.sh

This line:

OLDDATE=`date -v -3d +%s`

defines the date to use to determine what runs to delete. The "-3d" indicates all runs at least 3 days old. This is the format for MacOS

The script contains an alternate syntax for Linux

# Configuring the chunk size

The list of job runs for a given Job are returned in chunks.  These scripts will loop retrieving all the chunks until all job runs have been considered.

In production there is no real reason to specify the chunk size (the default value if unspecified is 100, which is also the maximum).  But for testing it is sometimes convenient to work with smaller chunk sizes.

That chunk size is specified in the script deleteAllJobRunsForAJobInSpace.sh in the line:

CHUNK_SIZE=100

# Removing any existing retention configuration in your jobs

If you choose to implement your retention checks using these scripts you should remove the retention setting for the jobs.  You can do this directly in the UI for most types of jobs, or may already have no retention settings.

But if there are already retention settings configured you can remove them for all the jobs in a space using the script

removeJobRetentionAllJobsInSpace.sh space_name

or for an individual job using

removeJobRetentionInSpace.sh space_name job_name

# Working with projects

There is also a set of scripts (ending in InProjects) that can be used in the same way to manage job runs in Projects
