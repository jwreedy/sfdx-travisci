#!/bin/bash
script_name=`basename "$0"`
log_dir=logfiles
scripts_dir=scripts
tests_log=$log_dir/local_tests.log
deployment_log=$log_dir/deployment.log
mdapi_dir=mdapi

echo "##########################################################################"
echo "#         Script Name: " $script_name
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
        echo "$script_name ERROR: $message"
        echo "$script_name INFO: Ending $script_name"
        exit 1
    fi
}
mkdir -p logfiles

# login to saandbox
echo "$script_name INFO: logging in to org"
sfdx force:auth:sfdxurl:store -f assets/dev-login.txt -a dev

# remove madapi directory and recreate
echo "$script_name INFO: Creating mdapi directory"
rm -r mdapi
sfdx force:source:convert -r ./force-app/ -d ./mdapi/
return_val=$?; error_handler; message="Creating mdapi directory"

# run local tests
echo "$script_name INFO: Running Local Tests"
sfdx force:apex:test:run -c -u dev -r human -w 10 >$tests_log
if grep -q 'Outcome              Failed' $tests_log; then
  echo "$script_name ERROR: An Error occured while running local tests:"
  grep 'Fail ' $tests_log
  echo '$script_name ERROR: Exiting $script_name due to error(s)'
  # cat local_tests.log
  exit 1
fi
echo "$script_name INFO: SUCCESS: Local Tests Successfully Completed"
echo "$script_name INFO: Deploying to .dev Sandbox"
sfdx force:mdapi:deploy -d ./mdapi -u dev -w 10 >$deployment_log
if grep -q 'Error' $deployment_log; then
  echo "$script_name ERROR: An Error occured while deploying metadata"
  grep 'Error ' $deployment_log
  echo '$script_name ERROR: Exiting $script_name due to error(s)'
  exit 1
fi
echo "$script_name SUCCESS: Sucessfully deployed metadata to .dev"
#sfdx force:mdapi:deploy:report -w 10 -u dev
