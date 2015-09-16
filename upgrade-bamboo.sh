#!/bin/bash
###
### Script to upgrade Atlassian Bamboo.
### It shows the diffs of the common configuration files and asks to copy files from the old instance
###
## Usage:
## ./upgrade-bamboo.sh <old-dir> <new-dir>
## Example:
## ./upgrade-bamboo.sh bamboo bamboo-5.2-standalone
## Suggestions:
## bamboo - should be a symlink to the current Bamboo installation directory.
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
 echo "Usage: $0 <old-bamboo-instance-dir> <new-bamboo-instance-dir>"
 echo
 exit 1
fi


OLD=$1
NEW=$2

echo
echo
echo "Old Bamboo instance in $OLD, new Bamboo files in $NEW."
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
echo "Comparing crowd.properties"
echo "==================="
diff $OLD/atlassian-bamboo/WEB-INF/classes/crowd.properties $NEW/atlassian-bamboo/WEB-INF/classes/crowd.properties || true
confirm "Copy the file from old instance? [y/N]" && cp -v $OLD/atlassian-bamboo/WEB-INF/classes/crowd.properties $NEW/atlassian-bamboo/WEB-INF/classes/crowd.properties

echo
echo "Comparing seraph-config.xml"
echo "==================="
diff $OLD/atlassian-bamboo/WEB-INF/classes/seraph-config.xml $NEW/atlassian-bamboo/WEB-INF/classes/seraph-config.xml || true
confirm "Copy the file from old instance? [y/N]" && cp -v $OLD/atlassian-bamboo/WEB-INF/classes/seraph-config.xml $NEW/atlassian-bamboo/WEB-INF/classes/seraph-config.xml

echo
echo "Comparing bamboo-init.properties"
echo "==================="
diff $OLD/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties $NEW/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties || true
confirm "Copy the file from old instance? [y/N]" && cp -v $OLD/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties $NEW/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties

echo
echo "Comparing log4j.properties"
echo "==================="
diff $OLD/atlassian-bamboo/WEB-INF/classes/log4j.properties $NEW/atlassian-bamboo/WEB-INF/classes/log4j.properties || true
confirm "Copy the file from old instance? [y/N]" && cp -v $OLD/atlassian-bamboo/WEB-INF/classes/log4j.properties $NEW/atlassian-bamboo/WEB-INF/classes/log4j.properties

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
