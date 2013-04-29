# Git automatic deployment (PHP)

Follow these simple steps to setup your server with branch-specific git automatic deployment!

## Installation
1. Run `git clone https://github.com/JockeGustin/git-autodeploy.git` to download the actual script to your webserver.
2. If your webroot is not located at `/srv/www/` you should change this (inside git-autodeploy-setup.sh)
3. Make the script excecutable: `chmod +x git-autodeploy-setup.sh`

## Usage
1. Create the actual repo to be tracked at your service of choise (bitbucket, github, etc.)
2. Make sure the branch you want to track exists in your remote repository
3. (Optional, this is only needed when your repository is not public). Add the user www-data's (or whatever user owns your public webroot) ssh key to remote repositories deployment keys
4. Run ./git-autodeploy-setup.sh as www-data (su www-data to change to the www-data user)
5. Run a manual deploy as www-data to add fingerprint: `php ./deploy.php` (deploy.php is created by the script)
6. Set up your webserver (nginx/apache/whatever) to point to your new `public_html` folder
7. Add a post commit servicehook to your remote repository and point it to http://yourwebsite.com/deploy.php
8. It now should autodeploy!

## The actual script
Use it like so: `./git-autodeploy-setup.sh [local dirname] [url remote repo] [branch to track]`
- [local dirname] This is just the name of the wrapping directory to be created, I often use the website name prefixed by some branch identifier, e.g. `dev.jockegustin.se` for the branch `develop` of my website. 
- [url remote repo] This is the URL to your remote repository. Like git@github.com:blablabla...
- [branch to track] Defaults to `master` but can track any branchname you provide. Just make sure the branch actually exists
