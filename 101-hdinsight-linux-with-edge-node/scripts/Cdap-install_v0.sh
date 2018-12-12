#!/bin/bash

USERID=$(echo -e "import hdinsight_common.Constants as Constants\nprint Constants.AMBARI_WATCHDOG_USERNAME" | python)
PASSWD=$(echo -e "import hdinsight_common.ClusterManifestParser as ClusterManifestParser\nimport hdinsight_common.Constants as Constants\nimport base64\nbase64pwd = ClusterManifestParser.parse_local_manifest().ambari_users.usersmap[Constants.AMBARI_WATCHDOG_USERNAME].password\nprint base64.b64decode(base64pwd)" | python)
CLUSTERNAME=$(echo -e "import hdinsight_common.ClusterManifestParser as ClusterManifestParser\nprint ClusterManifestParser.parse_local_manifest().deployment.cluster_name" | python)
HDP_VERSION=$(hdp-select  | grep spark2-client | awk '{print $NF}')

######## Code to download cdap deb packages ############

sudo curl -o /etc/apt/sources.list.d/cask.list http://repository.cask.co/ubuntu/precise/amd64/cdap/5.1/cask.list
curl -s http://repository.cask.co/ubuntu/precise/amd64/cdap/5.1/pubkey.gpg | sudo apt-key add -
sudo apt-get update

######## Code to install apache2 ###################

######## Code to get ansible scripts #####################

sudo mkdir -p /opt/guavus/cdap_provisioner
sudo wget -O /opt/guavus/  https://ankurhdistg.blob.core.windows.net/reflex/reflex-tdf-cdap.tgz
sudo tar xzf /opt/guavus/reflex-tdf-cdap.tgz -C /opt/guavus/cdap_provisioner/

sed -i "s/^amb_user_id:.*/amb_user_id: '${USERID}'/" /opt/guavus/cdap_provisioner/inventory/reflex/vars/main.yml
sed -i "s/^amb_password:.*/amb_password: '${PASSWD}'/" /opt/guavus/cdap_provisioner/inventory/reflex/vars/main.yml
sed -i "s/^amb_cluster_name:.*/amb_cluster_name: '${CLUSTERNAME}'/" /opt/guavus/cdap_provisioner/inventory/reflex/vars/main.yml

###################################################

########### Trigger ansible ######################
