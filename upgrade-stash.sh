#!/bin/bash
###
### Script to upgrade Atlassian Stash.
### It shows the diffs of the common configuration files and asks to copy files from the old instance
###
## Usage:
## ./upgrade-stash.sh <old-dir> <new-dir>
## Example:
## ./upgrade-stash.sh stash stash-5.2-standalone
## Suggestions:
## stash - should be a symlink to the current Stash installation directory.
## 
## Author: Radek Antoniuk <http://www.quiddia.com>
##

set -e
clear

confirm() {
    read -r -p "${1:-Do you want to continue? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

if [[ "$#" -ne 2 ]]; then
 echo
 echo "Usage: $0 <old-stash-instance-dir> <new-stash-instance-dir>"
 echo
 exit 1
fi


OLD=$1
NEW=$2

echo
echo
echo "Old Stash instance in $OLD, new Stash files in $NEW."
! confirm "Correct [y/N]?" && echo "Exiting..." && exit 1

echo
echo "Comparing server.xml..."
echo "======================="
diff $OLD/conf/server.xml $NEW/conf/server.xml || true
confirm "Copy the file from old instance? [y/N]" && cp -v $OLD/conf/server.xml $NEW/conf/server.xml

echo
echo "Comparing setenv.sh"
echo "==================="
diff $OLD/bin/setenv.sh $NEW/bin/setenv.sh || true
confirm "Copy the file from old instance? [y/N]" && cp -v $OLD/bin/setenv.sh $NEW/bin/setenv.sh

echo
MYSQL=$(find $OLD/lib/ -type f -name 'mysql*.jar')
if [[ -n $MYSQL ]]; then
  echo "Found MySQL driver: $MYSQL"
  confirm "Copy the file from old instance? [y/N]" && cp -v $MYSQL $NEW/lib/
else
  echo "MySQL JDBC driver not found."
fi

USER=$(stat -L -c '%U' $OLD)
GROUP=$(stat -L -c '%G' $OLD)
echo
echo "$OLD was owned by $USER.$GROUP. Execute chown -R on $NEW?"
confirm && chown -R $USER.$GROUP $NEW

echo
if [[ -s "$OLD" ]]; then
  echo "$OLD is a symlink to $(readlink -f $OLD)"
  confirm "Replace it with a symlink to the new instance? [y/N]" && rm -vf $OLD && ln -vs $NEW $OLD
else
  echo "$OLD is not a symlink. Manage it on your own."
fi

# vim: ts=2 sw=2 smarttab 
