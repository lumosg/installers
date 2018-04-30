#!/usr/bin/env bash

#######################################################################
#License    : GPLv3
#Created by : br0k3ngl255
#Desc	    : Installing  DHCP and DNS on server
#Date		: 30.05.2018
#Version	: 1.0.0
########################################################################




##Var - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ - _ 
Distro=$(cat /etc/*-release|grep -E '^ID='|awk -F= '{print $2}'|sed 's/\"//g')
Sub_distro="$(lsb_release -sc)"
time=0.5
tmp="/tmp"
log="install.log"
logFolder="/var/log/"
logFile="$logFolder/$log"
installer=""
NULL="/dev/null"
user=""
line="\n\n==============================================================\n\n"
cursor="\n\n###############################################################\n\n"
BASHRC="/etc/bash.bashrc"
RBASHRC="/etc/bashrc"

srv_packages=( httpd   php dhcp )
web_packages=( apache2 php dhcp )


##Funcs /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

help(){
	printf "$line"
	printf "Incorrect use of script"
	printf "usage : $0 -I apt-get -U username -P password"
	printf "$line"
	exit 1	
	}

error(){
	printf "$line"
	printf "Some thing went wrong --> Please chec the $log at $logFolder "
	printf "$line"
	}

distro_check(){
	local op=$1
	case $op in
			
			debian)  installer="apt-get" ;;
			ubuntu)  installer="apt-get" ;;
			redhat)  installer="yum" ;;
			fedora)  installer="dnf" ;;
			centos)  installer="yum";;
			*) 		 echo "$Distro is not supported"; exit 1 ;;
			
	esac     
	}

net_check(){
	net_stat=$(ping -c 1 vk.com > $NULL 2> $NULL ;printf "$?\n")
			if [ $net_stat == "1" ] || [ $net_stat == "2" ];then
				printf "$line"
				printf "NO NETWORK - Get Online"
				printf "$line"				
				return 1
			elif [ $net_stat == "0" ];then
				printf "$line"
					printf "Network is UP"
				printf "$line"

			fi
	}


