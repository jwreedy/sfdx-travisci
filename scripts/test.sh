sfdx force:org:create -v HubOrg -s -f config/project-scratch-def.json -a ciorg --wait 3
sfdx force:org:display -u ciorg
sfdx force:source:push -u ciorg
sfdx force:apex:test:run -u ciorg --wait 10
sfdx force:org:delete -u ciorg -p
