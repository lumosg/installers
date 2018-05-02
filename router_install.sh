#!/usr/bin/env bash

#######################################################################
#License    : GPLv3
#Created by : br0k3ngl255
#Desc	    : Installing  DHCP and DNS on server
#Date		: 30.05.2018
#Version	: 1.0.35
########################################################################


########################################################################
#ToDo
########################################################################
#1) add epel-release as seperate function--> need to fix to work only with redha based
#2) data documentation is logs
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
sub_installer=""
NULL="/dev/null"
user=""
password=""
segement=""
netmask=""
gateway=""
line="\n\n==============================================================\n\n"
cursor="\n\n###############################################################\n\n"
BASHRC="/etc/bash.bashrc"
RBASHRC="/etc/bashrc"

srv_packages=( httpd   php dhcp figlet  nodejs bash-completion )
web_packages=( apache2 php dhcp figlet  nodejs bash-completion )


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
	
		printf "$line" &>> $logFile
			printf "Some thing went wrong --> Please chec the $log at $logFolder " &>> $logFile
		printf "$line" &>> $logFile
	
	exit 1
	}

var_setup(){
	if [[ "$Distro" == "centos" ]] || [[ $Distro == "redhat" ]] || [[ "$Distro" == "fedora" ]];then
		BASHRC="/etc/bashrc"
		sub_installer="rpm"
	else
		BASHRC="/etc/bash.bashrc"
		sub_installer="dpkg"
	fi
	
	printf "$line"
		printf " variables setup\n"
	printf "$line"
	
			printf "$line"  &>> $logFile
				printf " variables setup\n" &>> $logFile
			printf "$line"  &>> $logFile
}

distro_check(){
	local op=$1
	case $op in
			
			debian)  installer="apt-get" ; sub_installer="dpkg";;
			ubuntu)  installer="apt-get" ; sub_installer="dpkg";;
			redhat)  installer="yum" ; sub_installer="rpm";;
			fedora)  installer="dnf" ; sub_installer="rpm";;
			centos)  installer="yum" ; sub_installer="rpm" ;;
			*) 		 echo "$Distro is not supported"; exit 1 ;;
			
			printf "$line"
				printf "\nthe $op distro has been chosen and the install is $installer\n"
			printf "$line"
					printf "$line" &>> $logFile
						printf "\nthe $op distro has been chosen and the install is $installer\n" &>> $logFile
					printf "$line" &>> $logFile
	esac     
	}

net_check(){
	net_stat=$(ping -c 1 vk.com > $NULL 2> $NULL ;printf "$?\n")
			if [ $net_stat == "1" ] || [ $net_stat == "2" ];then
				printf "$line"
				printf "NO NETWORK - Get Online" 
				printf "$line"
				
						printf "$line" &>> $logFile
						printf "NO NETWORK - Get Online" &>> $logFile
						printf "$line" &>> $logFile
				
				return 1
			elif [ $net_stat == "0" ];then
				printf "$line"
					printf "Network is UP"
				printf "$line"
								
							printf "$line" &>> $logFile
								printf "Network is UP"  &>> $logFile
							printf "$line"  &>> $logFile
			else
				error
			fi
	}


rpm_addon(){
	printf "$line" 
	printf "adding epel repo for extending use"
	printf "$line"
		printf "$line" &>> $logFile
		printf "adding epel repo for extending use" &>> $logFile
		printf "$line" &>> $logFile
	 
	 printf " $installer install epel-release" &>> $logFile
		
			$installer install epel-release &>> $logFile
	}


pack_install(){
	printf "$line"
	printf "starting to install packages"
	printf "$line"
	
	if [ $Distro == "centos" ] || [ $Distro == "redhat" ] || [ $Distro == "fedora" ];then
		packages=${srv_packages[@]}
	else 
		packages=${web_packages[@]}
	fi
	
	for i in "${packages[@]}";
		do
			pac_check=$($sub_installer -l $i &> $logFile;printf "$?\n")
			if [[ "$pac_check" == "0" ]];then
				true
			else
				printf "%-50s %s\t"  "preparing to install $i "
					$installer install -y $i &>> $logFile;sleep $time

				if [[ $? != 0 ]];then
						printf "%-50s %s\t"  "Unable to install $i "
						printf "NOT installed\n"
				else 
						printf "installed\n"
				fi
			fi
		done
		}


user_setup(){
	
	while [ -z $user ] && [ -z $password ]
		do
			read -p " Please Provide user's NAME for setup" user
			read -p " Please Provide user's PASSWORD for setup" password

		done
		
			if [ $Distro == "redhat" ]	|| [ $Distro == "redhat" ] || [ $Distro == "redhat" ];then
			
				useradd -G wheel $user &> $logFile
				passwd < $password
			
			elif [ $Distro == "debian" ] || [ $Distro == "redhat" ];then
			
			
				
			else
					error
			fi
}

user_env_setup(){
	
	echo " if ! shopt -oq posix; then
			if [ -f /usr/share/bash-completion/bash_completion ]; then
				. /usr/share/bash-completion/bash_completion
			elif [ -f /etc/bash_completion ]; then
				. /etc/bash_completion
			fi
		   fi " >> $BASHRC
	echo "alias l=ls; alias ll='ls -l'; alias la='ls -la';alias lh='ls -lh' 
		  alias more=less; alias vi=vim; 
		  alias cl=clear; alias mv='mv -v'; 
		  alias cp='cp -v'; 
		  alias log='cd /var/log';
		  alias drop_caches='echo 3 > /proc/sys/vm/drop_caches'; 
          alias ip_forward='echo 1 > /proc/sys/net/ipv4/ip_forward';" >> $BASHRC
	
}

alias_setup(){
	echo "" >> $BASHRC
	
	
}
###
# Main +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
###

if [ $EUID == 0 ];then
	true

else
	printf "$curser"
		printf "Need Root Privileges - Please Aquire Root Access"
	printf "$curser"
fi
