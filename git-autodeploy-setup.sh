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
mkdir $DIR/$DIR_CONTENT
mkdir $DIR/$DIR_REPO
mkdir $DIR/$DIR_LOGS

#Become the web user (that should own the deployment keys)
su $WEB_USER

#Initialize the git repo
git --git-dir=$DIR/$DIR_REPO --work-tree=. init $DIR/$DIR_CONTENT
echo "gitdir: $DIR/$DIR_REPO" > $DIR/$DIR_CONTENT/.git
chmod og-rx $DIR/$DIR_CONTENT/.git #(possibly) secure the file

#Add the remote to the repo
git --git-dir $DIR/$DIR_REPO remote add -t $BRANCH -f origin $REMOTE_REPO
git --git-dir $DIR/$DIR_REPO checkout $BRANCH

#Create simple deploy.php file to hook to bitbucket/github sericehooks
cat > $DIR/$DIR_CONTENT/deploy.php << EOF
<?php exec('git pull'); ?>
EOF

#This is an ugly but cool and working method,
#To allow for pushing directly to this repo we have to check out another
#branch pre-receive and then switch back post-receive

#Switch to temp branch to be able to push to this repos selected branch
cat > $DIR/$DIR_REPO/hooks/pre-receive << EOF
#!/bin/sh
git checkout -b tmp
EOF

#Switch back and delete branch
cat > $DIR/$DIR_REPO/hooks/post-receive << EOF
#!/bin/sh
git checkout $BRANCH; git branch -d tmp
EOF

#Make hooks excecutable
chmod +x $DIR/$DIR_REPO/hooks/pre-receive
chmod +x $DIR/$DIR_REPO/hooks/post-receive

#Make www-data user owner of the files
chown -R $WEB_USER:$WEB_USER_GROUP $DIR