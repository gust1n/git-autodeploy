# Git automatic deployment (PHP)

Follow these simple steps to setup your server with branch-specific git automatic deployment!

## Description
Tired of setting up webservers and ftp-account? Do you use git to track your development but then feel
stuck in old techniques when trying to deploy? Use this script to setup a webroot for automatic git deployment.

##What it does
It creates a basic folder structure like this:
```
your-passed folder name
	/public_html
	/logs
	/repo
```
It then initializes a git repo inside the public_html folder but with a "remote" repo, located in the /repo folder.
This is to separate your public content to important stuff like the repo.

Note that this does *not* use a --bare git repo, you can acually push directly to this repo. Read inline comments if your interrested in the techniques I've used.

## Installation
1. Run `git clone https://github.com/JockeGustin/git-autodeploy.git` to download the actual script to your webserver.
2. If you dont want the standard structure with `/public_html`, `/logs` and `/repo` you should change the folder names (inside git-autodeploy-setup.sh)
3. Make the script excecutable: `chmod +x git-autodeploy-setup.sh`

## Usage
1. Create the actual repo to be tracked at your service of choise (bitbucket, github, etc.)
2. Make sure the branch you want to track exists in your remote repository
3. (Optional, this is only needed when your repository is not public). Add the user www-data's (the script will set ownership to www-data, change if otherwise) ssh key to remote repositories deployment keys
4. Run ./git-autodeploy-setup.sh as www-data (su www-data to change to the www-data user)
5. Just to make sure it works, run a manual deploy as www-data: `php ./deploy.php` (deploy.php is created by the script)
6. Set up your webserver (nginx/apache/whatever) to point to your new `public_html` folder
7. Add a post commit servicehook to your remote repository and point it to http://yourwebsite.com/deploy.php
8. It now should autodeploy!

## The actual script
Use it like so: `./git-autodeploy-setup.sh [local dirname] [url remote repo] [branch to track]`
- [local dirname] This is just the name of the path to the directory to be created, I often use the website name prefixed by some branch identifier, e.g. `/srv/www/dev.jockegustin.se` for the branch `develop` of my website. 
- [url remote repo] This is the URL to your remote repository. Like git@github.com:blablabla...
- [branch to track] Defaults to `master` but can track any branchname you provide. Just make sure the branch actually exists

