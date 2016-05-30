nginx-php-fp-in-openshift
=========================

Usage
-----

To get your custom PHP version working at OpenShift, you have to do the following:

1. Create a new Openshift "Do-It-Yourself" application.
2. Clone this repository.
    * ! Optionally you might want to change to a different branch to get a different PHP version.
3. Add a new remote "openshift" (You can find the URL to your git repository on the Openshift application page)
4. Run `git push --force "openshift" master:master`
5. SSH into your gear
6.  `cd $OPENSHIFT_REPO_DIR && rm -rf misc* && rm -rf www && rm -rf nginx-php-fp-in-openshift-tornado-added ` 
7. `git clone https://github.com/power-electro/nginx-php-fp-in-openshift-tornado-added.git` 
8. `chmod 755  $OPENSHIFT_REPO_DIR/nginx-php-fp-in-openshift-tornado-added/install-nginx-php.sh`
9. Wait (This may take at least an hour)
    If you want to see "what's going on, you may tail the log file and watch some shell movie ;)
10. `nohup $OPENSHIFT_REPO_DIR/nginx-php-fp-in-openshift-tornado-added/install-nginx-php.sh > $OPENSHIFT_LOG_DIR/install.log & `
    `tail -f $OPENSHIFT_DIY_LOG_DIR/install.log`
11. Open http://appname-namespace.rhcloud.com/phpinfo.php to verify running
   apache
12. You can remove the misc content

