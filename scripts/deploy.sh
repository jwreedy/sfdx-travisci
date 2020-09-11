#!/bin/bash
script_name=`basename "$0"`
environment=$1
log_dir=logfiles
scripts_dir=scripts
tests_log=$log_dir/local_tests.log
deployment_log=$log_dir/deployment.log
mdapi_dir=mdapi

echo "##########################################################################"
echo "#         Script Name: " $script_name
echo "#         Environment: " $environment
echo "#       Log Directory: " $log_dir/
echo "#   Scripts Directory: " $scripts_dir/
echo "#     Local Tests Log: " $tests_log
echo "#      Deployment Log: " $deployment_log
echo "#     mdapi Directory: " $mdapi_dir/
echo "##########################################################################"
echo

################################################################################
# Error Handler
error_handler(){
    if [[ $return_val -ne 0 ]]; then
        echo "$script_name ERROR: $error_message"
        echo "$script_name INFO: Ending $script_name"
        exit 1
    fi
}
mkdir -p logfiles

# login to saandbox
error_message="An error occurred while attempting to login to org"
echo "$script_name INFO: logging in to org"
sfdx force:auth:sfdxurl:store -f assets/$environment-login.txt -a $environment
return_val=$?; error_handler

# remove madapi directory and recreate
error_message="An error occurred while attempting to creating mdapi directory"
echo "$script_name INFO: Creating mdapi directory"
sfdx force:source:convert -r ./force-app/ -d ./mdapi/
return_val=$?; error_handler

# run local tests
error_message="An error occured while running Local Tests - check deployment status in org for errors"
echo "$script_name INFO: Running Local Tests"
sfdx force:mdapi:deploy -c -d ./mdapi -l RunLocalTests --ignoreerrors -u $environment -w 10 >$tests_log
return_val=$?; error_handler

#sfdx force:apex:test:run -c -u $environment -r human -w 10 >$tests_log
if grep -q 'Failed\ERROR' $tests_log; then
  echo "$script_name ERROR: An Error occured while running local tests:"
  echo "**"
  grep 'Failed\ERROR' $tests_log
  echo "**"
  echo '$script_name ERROR: Exiting $script_name due to error(s)'
  # cat local_tests.log
  exit 1
fi
#echo "$script_name INFO: SUCCESS: Local Tests Successfully Completed"
error_message="An error occured while attempting to deploying to $environment - check deployment status in org for errors"
echo "$script_name INFO: Deploying to .$environment Sandbox"
sfdx force:mdapi:deploy -d ./mdapi -u $environment -w 10 >$deployment_log
return_val=$?; error_handler

if grep -q 'Error\ERROR' $deployment_log; then
  echo "$script_name ERROR: An Error occured while deploying metadata"
  grep 'Error\ERROR' $deployment_log
  echo '$script_name ERROR: Exiting $script_name due to error(s)'
  exit 1
fi
echo "$script_name SUCCESS: Sucessfully deployed metadata to .$environment"
#sfdx force:mdapi:deploy:report -w 10 -u $environment
