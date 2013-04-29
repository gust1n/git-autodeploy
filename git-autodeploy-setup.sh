#!/bin/bash

#If dir or repo was not passed, output help
if [ -z "$2" ]
then
echo "Usage: ./git-autodeploy-setup [local dirname] [url remote repo] [branch to track]"
exit 1
fi

DIR=$1
REMOTE_REPO=$2

PATH_WEBROOTS="/srv/www/"
DIR_CONTENT="public_html"
DIR_REPO="repo"
DIR_LOGS="logs"

if [ -n "$3" ]
# Test whether command-line argument is present (non-empty).
then
BRANCH=$3
else
BRANCH="master"
fi

if [ -d $PATH_WEBROOTS$DIR ];
then
echo "Dir $PATH_WEBROOTS$DIR already exists"
else

mkdir $PATH_WEBROOTS$DIR

#Non-bare repo solution
cd $PATH_WEBROOTS$DIR

mkdir $DIR_CONTENT
mkdir $DIR_REPO
mkdir $DIR_LOGS

cd $DIR_CONTENT

git --git-dir=$PATH_WEBROOTS$DIR/$DIR_REPO --work-tree=. init && echo "gitdir: $PATH_WEBROOTS$DIR/$DIR_REPO" > .git
chmod og-rx .git #secure the file
git remote add -t $BRANCH -f origin $REMOTE_REPO
git checkout $BRANCH

#Create simple phpfile to hook to bitbucket/github sericehooks
cat > deploy.php << EOF
<?php exec('git pull'); ?>
EOF

#Add deploy file to .gitignore
echo "deploy.php"  >>  .gitignore

cd $PATH_WEBROOTS$DIR/$DIR_REPO

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

cd $PATH_WEBROOTS
chown -R www-data:www-data $DIR

fi

#Bare repo
# cd $PATH_REPOS$DIR
# git init --bare

# cat > hooks/post-receive << EOF
# #!/bin/sh
# GIT_WORK_TREE=$PATH_WEBROOTS$DIR git checkout -f $BRANCH
# EOF
# chmod +x hooks/post-receive

# cat > hooks/post-receive << EOF
# #!/bin/sh
# GIT_WORK_TREE=$PATH_WEBROOTS$DIR git checkout -f
# EOF
# chmod +x hooks/post-receive

# git remote add -t $BRANCH -f origin $REMOTE_REPO
# git checkout -f $BRANCH
#git fetch -q origin master:master
