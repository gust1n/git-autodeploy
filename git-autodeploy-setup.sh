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

if [ -n "$3" ]
# Settings branch to track is optional, defaults to master
then
BRANCH=$3
else
BRANCH="master"
fi

if [ -d $DIR ];
then
echo "Dir $DIR already exists"
exit 1
else

mkdir $DIR

#Non-bare repo solution
cd $DIR

mkdir $DIR_CONTENT
mkdir $DIR_REPO
mkdir $DIR_LOGS

cd $DIR_CONTENT

git --git-dir=$DIR/$DIR_REPO --work-tree=. init && echo "gitdir: $DIR/$DIR_REPO" > .git
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
chown -R www-data:www-data $DIR

fi
