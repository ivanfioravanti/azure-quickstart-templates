#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2015 Microsoft Azure
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#--------------------------------------------------------------------------------------------------
# MongoDB Template for Azure Resource Manager with MMS (brought to you by 4ward srl)
#
# This script installs MongoDB MMS Automation Agent on each Azure virtual machine.
# The script will be supplied with runtime parameters declared from within the corresponding ARM template.
#--------------------------------------------------------------------------------------------------


help()
{
	echo "This script installs MongoDB on the Ubuntu virtual machine image"
	echo "Options:"
	echo "		-g MongoDB MMSGroupID"
	echo "		-a MongoDB MMSApiKey"
	echo "		-d Data folder"
}

# You must be root to run this script
if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this script." >&2
    exit 3
fi

# Parse script parameters
while getopts :g:a:d:h optname; do

	# Log input parameters (except the admin password) to facilitate troubleshooting
	if [ ! "$optname" == "p" ] && [ ! "$optname" == "k" ]; then
		log "Option $optname set with value ${OPTARG}"
	fi

	case $optname in
	g) # MongoDB MMSGroupID
    	MMSGROUPID=${OPTARG}
		;;
	a) # MongoDB MMSApiKey
    	MMSAPIKEY=${OPTARG}
		;;
  	d) # MongoDB Data folder that will be linked to /data
    	DATAFOLDER=${OPTARG}
	    ;;
  	h)  # Helpful hints
		help
		exit 2
		;;
    \?) # Unrecognized option - show help
		echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
		help
		exit 2
		;;
  esac
done

# Validate parameters
if [ "$MMSGROUPID" == "" ] || [ "$MMSAPIKEY" == "" ];
then
    log "Script executed without MMS information"
    echo "You must provide MMS Group Id and ApiKey." >&2
    exit 3
fi

# Disable THP
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
grep -q -F 'transparent_hugepage=never' /etc/default/grub || echo 'transparent_hugepage=never' >> /etc/default/grub

# Add local machine name to the hosts file to facilitate IP address resolution
if grep -q "${HOSTNAME}" /etc/hosts
then
  echo "${HOSTNAME} was found in /etc/hosts"
else
  echo "${HOSTNAME} was not found in and will be added to /etc/hosts"
  # Append it to the hosts file if not there
  echo "127.0.0.1 $(hostname)" >> /etc/hosts
  log "Hostname ${HOSTNAME} added to /etc/hosts"
fi

# Install MongoDB MMS Automation Agent
curl -sOL https://mms.mongodb.com/download/agent/automation/mongodb-mms-automation-agent-manager_latest_amd64.deb
dpkg -i mongodb-mms-automation-agent-manager_latest_amd64.deb
sed -i 's/mmsGroupId=@GROUP_ID@/mmsGroupId='"$MMSGROUPID"'/g' /etc/mongodb-mms/automation-agent.config
sed -i 's/mmsApiKey=@API_KEY@/mmsApiKey='"$MMSAPIKEY"'/g' /etc/mongodb-mms/automation-agent.config
mkdir -p $DATAFOLDER
chown mongodb:mongodb $DATAFOLDER
sudo ln -s $DATAFOLDER /data
start mongodb-mms-automation-agent
rm -rf mongodb-mms-automation-agent-manager_latest_amd64.deb
export LC_ALL=en_US.UTF-8
grep -q -F 'LC_ALL=C' /etc/default/locale || echo 'LC_ALL=C' >> /etc/default/locale

#Install MongoDB Client tools
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
apt-get update
sudo apt-get install -y mongodb-org-shell
sudo apt-get install -y mongodb-org-tools
