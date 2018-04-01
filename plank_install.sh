#!/usr/bin/env bash

########################################################################
#Author  : br0k3ngl255
#Date    : 01.04.3017
#Purpose : setup systems features on debian based systems.
#Version : 0.0.1
########################################################################
#TODO: 
########################################################################

logFolder="/tmp"
log="install_log.txt"
logFile="$logFile/$log"
line="\n\n==============================================================\n\n"
cursor="\n\n###############################################################\n\n"
INSTALLER="apt-get"
#--------------------------------------------------------------------
LINK="https://launchpad.net/plank/1.0/0.11.4/+download/plank-0.11.4.tar.xz"
dependencies=(automake gnome-common intltool pkg-config valac\
			   libbamf3-dev libdbusmenu-gtk3-dev libgdk-pixbuf2.0-dev\ 
			   libgee-dev libglib2.0-dev libgtk-3-dev libwnck-3-dev\
			   libx11-dev libgee-0.8-dev)


#Fucntions- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _

dependencies_verification(){
	for i in ${dependencies[@]}
		do
				pac_check=$(dpkg -l $i &> $logFile;printf "$?\n")
			if [[ "$pac_check" == "0" ]];then
				true
			else
				printf "%-50s %s\t" "preparing to install $i "
					$INSTALLER install -y $i &>> $logFile;sleep $TIME
				printf  "installed\n"
			fi
		done
	}


getting_the_link(){
	if [ $(which wget) ];then
			wget  $LINK -O plank.tar.gz &>> $logFile
	elif [ $(which curl) ];then
			curl $LINK &>> $logFile
	else 
			echo "unable to download"
			exit 1
	fi
	}

open_the_link_file(){
	if [ ! -e "plank.tar.gz" ];then
		printf "\n file does not exists"
	fi
	
	if [ -e "plank.tar.gz" ];then
		printf "\n openining file"; sleep 0.5
			tar xvzf plank.tar.gz &>> $logfile
			
	}


###
# Main +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
###

if [ "$EUID" != "0" ];then
	echo "need ROOT Access in order to install the tool"
elif [ "$EUID" != "0" ];then
	printf $line
		printf "\n starting to check dependencies"
			dependencies_verification
	printf $line
	
	printf $line
		printf "\n downloading  sources"
			getting_the_link && open_the_link_file
					
	printf $line
	
	
