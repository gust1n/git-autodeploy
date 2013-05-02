#!/bin/bash

#If dir or repo was not passed, output help
if [ -z "$2" ]
then
echo "Usage: ./git-autodeploy-setup [local dirname] [url remote repo] [branch to track]"
exit 1
fi

DIR=$1
REMOTE_REPO=$2

DIR_CONTENT="public_html"
DIR_REPO="repo"
DIR_LOGS="logs"

WEB_USER="www-data"
WEB_USER_GROUP="www-data"

# Specific branch to track is optional, defaults to master
if [ -n "$3" ]
then
BRANCH=$3
else
BRANCH="master"
fi

# If target directory exists
if [ -d $DIR ];
then
read -p "Directory $DIR already exists and the content may be overwritten, continue anyways? [y/N] " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
else
mkdir $DIR
fi

#Non-bare repo solution
cd $DIR

mkdir $DIR_CONTENT
mkdir $DIR_REPO
mkdir $DIR_LOGS

cd $DIR_CONTENT

#Become the web user that should own the deployment keys
su $WEB_USER

git --git-dir=$DIR/$DIR_REPO --work-tree=. init 
echo "gitdir: $DIR/$DIR_REPO" > .git
chmod og-rx .git #(possibly) secure the file
git remote add -t $BRANCH -f origin $REMOTE_REPO
git checkout $BRANCH

#Create simple deploy.php file to hook to bitbucket/github sericehooks
cat > deploy.php << EOF
<?php exec('git pull'); ?>
EOF

#Add deploy file to .gitignore
#echo "deploy.php"  >>  .gitignore

cd $DIR/$DIR_REPO

#This is an ugly but cool and working method,
#To allow for pushing directly to this repo we have to check out another
#branch pre-receive and then switch back post-receive

#Switch to temp branch to be able to push to this repos selected branch
cat > hooks/pre-receive << EOF
#!/bin/sh
git checkout -b tmp
EOF

#Switch back and delete branch
cat > hooks/post-receive << EOF
#!/bin/sh
git checkout $BRANCH; git branch -d tmp
EOF

#Make hooks excecutable
chmod +x hooks/pre-receive
chmod +x hooks/post-receive

#Make www-data user owner of the files
chown -R $WEB_USER:$WEB_USER_GROUP $DIR