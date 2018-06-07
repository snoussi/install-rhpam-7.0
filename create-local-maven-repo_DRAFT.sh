#!/bin/sh

MVN_REPO=jboss-brms-bpmsuite-6.4.0.GA-maven-repository-full.zip
MVN_INC_REPO=jboss-bpmsuite-6.4.5-incremental-maven-repository.zip

#TODO: Change or create the m2 folder ( /home/USERX/.m2/repository )
#M2_REPO_PATH=/home/bpms/.m2/
M2_REPO_PATH=/Users/msnoussi/tmp

echo
echo "Unzipping ${MVN_REPO} ..."
echo
mkdir unzip_tmp
unzip -qo $MVN_REPO -d ./unzip_tmp
echo
echo "Unzipping ${MVN_INC_REPO} ..."
echo
unzip -qo $MVN_INC_REPO -d ./unzip_tmp

echo
echo "Moving to ${M2_REPO_PATH}..."
echo
mv ./unzip_tmp/jboss-brms-bpmsuite-6.4.0.GA-maven-repository/maven-repository/*  $M2_REPO_PATH/repository
mv ./unzip_tmp/jboss-brms-bpmsuite-6.4.0.GA-maven-repository/example-settings.xml $M2_REPO_PATH/settings.xml

echo
echo "Cleaning up ..."
echo
rm -rf ./unzip_tmp