sfdx force:auth:sfdxurl:store -f assets/dev-login.txt -a dev
sfdx force:source:convert -r ./force-app/ -d ./mdapi/
sfdx force:apex:test:run -c -u dev -r human -w 10
sfdx force:mdapi:deploy -d ./mdapi -u dev
sfdx force:mdapi:deploy:report -w 10

