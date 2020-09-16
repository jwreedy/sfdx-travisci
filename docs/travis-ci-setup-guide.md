# Travis CI Setup and Installation Guide

1. Create a Travis CI Account
2. Install the Travis CLI
3. Create Connected App in DevHub Org
4. Sandbox Credential Setup
5. branching strategy
6. test script
7. deployment script


## Create a Travis CI Account
1. Go to the Travis CI website and click Sign Up.  
2. Click Authorize travis-ci to log in with your GitHub credentials, then enter your GitHub password.
3. When you’ve logged in, click your picture to go to profile settings.
4. Find the sfdx-travisci repository and turn on Travis CI for your repo.

## Install the Travis CLI
https://github.com/travis-ci/travis.rb#installation

## Create Connected App in DevHub Org
If you are going to use scratch orgs, follow the steps in this TrailHead to connect Travis-CI to your DevHub org.

# Sandbox Credential Setup
The Salesforce DX URL is a unique URL in the format of force://<clientId>:<clientSecret>:<refreshToken>@<instanceUrl>. It is automatically created by Salesforce DX after you complete the web browser login, and it can be used in the future to log in again without prompting for a password.

Get the url
```
$ sfdx force:org:display -u sandbox_alias --verbose
``` 
The URL will be listed under “Sfdx Auth Url” and will start with “force://”. Copy this url and paste it into its own file in your DX project’s assets directory called “<sandboxName>-login.txt”. 

## Branching Strategy
#### Feature Branch
***Use orphan/story branches***  -- or release to qa periodically from dev when stable and all stories on dev branch havae been tested.
Create feature branches to work on a specific sprint story.
``` 
$ git checkout -b feature/AO-123-add-missing-policy-validation
```

#### dev Branch
When you have completed your work:
 1. checked-it-in to the remote repository
 2. pull the dev branch locally
 3. merge your dev branch into your feature branch
 4. resolve any merge conflicts
 5. push your feature branch to the remote repo
 6. create a pull request to merge with dev branch 
 7. approve pull request and merge with dev branch  
 
Upon completing the merge, travis-ci will run local tests, and deploy to the dev sandbox.

#### qa Branch
Upon successfully smoke testing feature in dev, push it to qa.
1. locally, pull the most recent version of qa branch
2. merge story branch or dev branch with qa branch
3. push to remote repo

Upon pushing to remote repo, branch will be deployed to qa.


#### master Branch
Once qa is ready to be released, it can be merged with master.







