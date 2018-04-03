#!/bin/sh

PRODUCT="Red Hat Process Automation Manager 7.0 on EAP7.1"

RHPAM_BC=rhba-7.0.0.ER2-business-central-eap7-deployable
RHPAM_PS=rhba-7.0.0.ER2-kie-server-ee7
#RHPAM_PATCH_WILDCARD=

EAP=jboss-eap-7.1.0
EAP_PATCH=jboss-eap-7.1.1-patch

EAP_USER=admin
EAP_PWD=jboss1!

RHPAM_USER=pamAdmin
RHPAM_PWD=pamAdmin1!

TARGET=../
SRC_DIR=./installs

JBOSS_HOME=$TARGET/jboss-eap-7.1
RHPAM_HOME=$TARGET/rhpam-7.0

echo
echo "##############################################################"
echo "##                                                          ##"
echo "      Installing ${PRODUCT}"
echo "##                                                          ##"
echo "##                                                          ##"
echo "##############################################################"
echo

# make some checks first before proceeding.
if [ -r $SRC_DIR/$EAP.zip ] || [ -L $SRC_DIR/$EAP.zip ]; then
  echo "JBoss Product sources $EAP are present..."
  echo
else
  echo "Need to download $EAP.zip package from the Customer Portal"
  echo "and place it in the $SRC_DIR directory to proceed..."
  echo
  exit
fi

if [ -r $SRC_DIR/$EAP_PATCH.zip ] || [ -L $SRC_DIR/$EAP_PATCH.zip ]; then
  echo "JBoss Product patches $EAP_PATCH.zip are present..."
  echo
else
  echo "Need to download $EAP_PATCH.zip package from the Customer Portal"
  echo "and place it in the $SRC_DIR directory to proceed..."
  echo
  exit
fi


if [ -r $SRC_DIR/$RHPAM_BC.zip ] || [ -L $SRC_DIR/$RHPAM_BC.zip ]; then
  echo "JBoss Product sources $RHPAM_BC.zip are present..."
  echo
else
  echo "Need to download $RHPAM_BC.zip package from the Customer Portal"
  echo "and place it in the $SRC_DIR directory to proceed..."
  exit
fi

if [ -r $SRC_DIR/$RHPAM_PS.zip ] || [ -L $SRC_DIR/$RHPAM_PS.zip ]; then
  echo "JBoss Product sources $RHPAM_PS.zip are present..."
  echo
else
  echo "Need to download $RHPAM_PS.zip package from the Customer Portal"
  echo "and place it in the $SRC_DIR directory to proceed..."
  exit
fi

# "Need to download all patch package from the Customer Portal and place it in the $SRC_DIR directory ..."
#for f in $(ls $SRC_DIR/$RHPAM_PATCH_WILDCARD); do
# if [ -r $f ] || [ -L $f ]; then
#    echo "JBoss Product patches $f are present..."
# fi
#done


# Remove the old JBoss instance, if it exists.
if [ -x $JBOSS_HOME ]; then
  echo "  - existing JBoss product install detected in $JBOSS_HOME !"
  echo "  - existing JBoss product install removed..."
  echo
  rm -rf $JBOSS_HOME
fi
if [ -x ./patch_tmp ]; then
  echo "  - existing JBoss product patch_tmp detected and removed..."
  echo
  rm -rf ./patch_tmp
fi



# Install EAP
echo
echo "JBoss EAP installer running now..."
echo
unzip -qo $SRC_DIR/$EAP.zip -d $TARGET
if [ $? -ne 0 ]; then
  echo
  echo "Error occurred during JBoss EAP installation!"
  exit
fi

# Add a default admin user.
echo
echo "Adding a default admin user on JBoss EAP ..."
echo
$JBOSS_HOME/bin/add-user.sh $EAP_USER $EAP_PWD --silent
if [ $? -ne 0 ]; then
  echo
  echo "Error occurred during JBoss EAP installation!"
  exit
fi

echo
echo "Applying $EAP_PATCH.zip patch now..."
echo
$JBOSS_HOME/bin/jboss-cli.sh --command="patch apply $SRC_DIR/$EAP_PATCH.zip --override-all"

if [ $? -ne 0 ]; then
 echo
 echo "Error occurred during JBoss EAP patching!"
 exit
fi

echo
echo "Deploying $PRODUCT ($RHPAM_BC) now..."
echo
unzip -qo $SRC_DIR/$RHPAM_BC.zip -d $TARGET

if [ $? -ne 0 ]; then
  echo
  echo "Error occurred during $PRODUCT installation!"
  exit
fi

echo
echo "Deploying $PRODUCT ($RHPAM_PS) now..."
echo
unzip -qo $SRC_DIR/$RHPAM_PS.zip -d $JBOSS_HOME/standalone/deployments

if [ $? -ne 0 ]; then
  echo
  echo "Error occurred during $PRODUCT installation!"
  exit
fi

touch $JBOSS_HOME/standalone/deployments/kie-server.war.dodeploy


# echo
# echo "Applying patches on $PRODUCT now..."
# echo
# mkdir -p ./patch_tmp
# cd $SRC_DIR
# for f in $RHPAM_PATCH_WILDCARD; do
#   echo " >>> Applying $f ...";
#   unzip -qo $f -d ../patch_tmp ;
#   (cd ../patch_tmp/${f%????} && exec ./apply-updates.sh ../../$JBOSS_HOME eap7.x);
# done
# cd ..

# rm -rf ./patch_tmp
# if [ $? -ne 0 ]; then
#   echo
#   echo "Error occurred during $PRODUCT installation!"
#   exit
# fi

# Create initial users
echo
echo "Creating initial users ..."
echo
$JBOSS_HOME/bin/add-user.sh -a -r ApplicationRealm -u $RHPAM_USER -p $RHPAM_PWD -ro admin,analyst,user,kie-server,rest-all --silent
if [ $? -ne 0 ]; then
  echo
  echo "Error occurred during JBoss EAP installation!"
  exit
fi

echo
echo "Renaming folders ..."
echo
mv $JBOSS_HOME $RHPAM_HOME
cp reset-dc.sh $RHPAM_HOME
