#!/usr/bin/env bash

#Author  : br0k3ngl255
#Date    : 27.08.3017
#Purpose : setup systems features on debian based systems.
#Version : 3.0.2

#TODO: write a function that follows the stages of script and lets the use know whats going on.
#TODO: add function that upgrades system if such is needed.
#TODO: make repository deployment more general and save for each distro.
###Vars ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
logFolder="/tmp"
log="install_log.txt"
logFile="$logFile/$log"
line="=============================================================="
cursor="###############################################################"
REPONAME="$(lsb_release -si|awk {'print tolower ($0)'})"
REPONAME_BETA=
KODENAME="$(lsb_release -sc)"
PASSWD="1"
USER="mobius"
BASHRC="/etc/bash.bashrc"
RBASHRC="/etc/bashrc"
NULL="/dev/null"
GRUB_DEFAULT_CONFIG="/etc/default/grub"
GEN_GRUB_CONFIG="/boot/grub/grub.cfg"
TMP="/tmp"
MATE_SESSION_DIR="/home/$USER/.config/autostart/"
PLANK_APP=

INSTALLER="apt-get"
export DEBIAN_FRONTEND=noninteractive

dev_packages=("python-scapy" " python-pip" " python-networkx " "python-netaddr " " python-netifaces" " python-netfilter " " apt-transport-https" " ca-certificates " "curl " "gnupg2 " "software-properties-common" " " "python-gnuplot " " python-mako " "python-radix " "ipython " " ipython3 " "python-pycurl " " python-lxml" "python-nmap " " python-flask" " python-scrapy" " perl-modules" " build-essential" " cmake" " bison " " flex" " git"  )
firmware_packages=( "firmware-misc-nonfree"  "firmware-atheros" " firmware-brcm80211" "firmware-samsung" " firmware-realtek" "firmware-linux" " firmware-linux-free" " firmware-linux-nonfree" " intel-microcode" "firmware-zd1211" )
gui_packages=("lightdm" "mate-desktop-environment-extras" "culmus" "mixxx" "guake" "plank" "atom" "sqlitebrowser" "pgadmin3" "vim-gtk" "codeblocks" "ninja-ide" "geany" "geany-plugins" "wireshark" "zenmap" "transmission" "gparted" "vlc" "abiword" "owncloud-client" "vim" "plank" "moka-icon-theme" "faba-icon-theme")
lib_packages=( "curl" "libpoe-component-pcap-perl" " libnet-pcap-perllibgtk2.0-dev" " libltdl3-dev" " libncurses-dev" " libusb-1.0-0-dev" "libncurses5-dev" "libbamf3-dev" "libdbusmenu-gtk3-dev" "libgdk-pixbuf2.0-dev" "libgee-dev libglib2.0-dev" "libgtk-3-dev" "libwnck-3-dev" "libx11-dev" "libgee-0.8-dev" "libnet1-dev" "libpcre3-dev" "libssl-dev" "libcurl4-openssl-dev" "libxmu-dev" "libpcap-dev" "libglib2.0" "libxml2-dev" "libpcap-dev" "libtool" " libsqlite3-dev" " libhiredis-dev" "libgeoip-dev" "libesd0-dev" "libncurses5-dev" "libusb-1.0-0" "libusb-1.0-0-dev" "libstdc++6-4.9-dbg")


###Funcs /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

help(){
	printf "$line\n"
	printf "usage : $0 -I apt-get -U username -P password"
	printf "\n$line"
	exit 1
}

insert_repo(){
		op=$1
		case $op in
	    $REPONAME)printf "inserting repo";	printf "
##MAIN
deb http://http.$REPONAME.net/$REPONAME $KODENAME main\n
deb-src http://http.$REPONAME.net/$REPONAME $KODENAME main\n
deb http://http.$REPONAME.net/$REPONAME $KODENAME-updates main\n
deb-src http://http.$REPONAME.net/$REPONAME $KODENAME-updates main\n
deb http://security.$REPONAME.org/ $KODENAME/updates main\n
deb-src http://security.$REPONAME.org/ $KODENAME/updates main\n
deb ftp://ftp.$REPONAME.org/$REPONAME stable main contrib non-free\n
###BackPort
deb http://http.$REPONAME.net/$REPONAME $KODENAME-backports main\n
deb http://ftp.$REPONAME.org/$REPONAME/ $KODENAME-backports non-free contrib\n
	" > /etc/apt/sources.list
	printf "\ndeb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Debian_7.0/ /\n" >> /etc/apt/sources.list
	printf "\ndeb http://download.virtualbox.org/virtualbox/debian $KODENAME contrib\n" >> /etc/apt/sources.list
	;;
			*) printf "Error getting Repo\n";exit 1 ;;

	esac
}

sys_upgrade_check(){
	current_distro=$(cat /etc/*-release|grep "^ID"|grep -E -o "[a-z]w+")
		if [ "$current_distro" == "debian" ];then
			apt-get update && apt-get upgrade &>> $logFile
		fi
		if [ "$current_distro" == "redhat" ];then
			yum update -y
		fi
	}

sys_stat(){

	pac_stat=$(ps aux |grep -v grep |grep apt-get &> /dev/null ;echo $?)

	while true;
		do
			if [ $pac_stat == "0" ];then
				printf "processing apt-get \n"
				sleep 5
			else
				break
			fi
		done
	}
net_check(){
	net_stat=$(ping -c 1 vk.com > $NULL 2> $NULL ;printf "$?\n")
			if [ $net_stat == "1" ] || [ $net_stat == "2" ];then
				printf "$line\n"
				printf "NO NETWORK - Get Online"
				printf "\n$line"				
				return 1
			elif [ $net_stat == "0" ];then
				printf "$line\n"
					printf "Network is UP"
				printf "\n$line"

					sleep 2
				printf "$line\n"
					printf "starting app install";
				printf "\n$line"

					#insertRepo $REPONAME
					apt-get update
				printf "$line\n"
					printf "finished updating repo cache"
				printf "\n$line"
					return 0
			fi
	}

repo_certs(){ #TODO - save all in /tmp
cd $TMP
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O-  |  apt-key add - &> $NULL;
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O-  &> $NULL|  apt-key add - &> $NULL;
wget -q  http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Debian_7.0/Release.key -O-  |apt-key add - &> $NULL;


if [ which curl ];then
	curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - &> $NULL;
else
	echo $line
	echo "no curl installed"
	echo $line
fi
cd $HOME
    }


multi_pac_install(){
	printf "$line\n"
	printf "installing DEV packages"
	printf "\n$line"
	for i in "${dev_packages[@]}";
		do
			pac_check=$(dpkg -l $i &> $logFile;printf "$?\n")
			if [[ "$pac_check" == "0" ]];then
				true
			else
				printf "%-40s %s\n" "preparing to install $i "
					apt-get install -y $i &>> $logFile
				printf "installed  "
			fi
		done
		
	printf "$line\n"
	printf "installing FRMWARE packages"
	printf "\n$line"
	for i in "${firmware_packages[@]}";
		do
			pac_check=$(dpkg -l $i &> $logFile;printf "$?\n")
			if [[ "$pac_check" == "0" ]];then
				true
			else
				printf "%-40s %s\n" "preparing to install $i "
					apt-get install -y $i &>> $logFile
				printf  "installed  \n"
			fi
		done
		
	printf "$line\n"
	printf " installing GUI packages"
	printf "\n$line"

	for i in "${gui_packages[@]}";
		do
			pac_check=$(dpkg -l $i &> $logFile;printf "$?\n")
			if [[ "$pac_check" == "0" ]];then
				true
			else
				printf "%-40s %s\n" "preparing to install $i"
					apt-get install -y $i &>> $logFile
				printf  "installed  \n"
			fi
		done
		
	printf "$line\n"
	printf " installing LIB packages"
	printf "\n$line"
	for i in "${lib_packages[@]}";
		do
			pac_check=$(dpkg -l $i &> $logFile;printf "$?\n")
			if [[ "$pac_check" == "0" ]];then
				true
			else
				printf "%-40s %s\n" "preparing to install $i "
					apt-get install -y $i &>> $logFile
				printf  "installed\n"
			fi
		done
	}

set_general_user(){
        user_chk=$(cat /etc/passwd|grep $USER &> $NULL;printf "$?\n")
      if [ $USER == "" ];then
			printf "$line/n"
            printf " no username provided to create"
            printf "\n$line"
      else
            if [ "$user_chk" == "0" ];then
				printf "$line\n"
                printf "$USER already exists";true
				printf "\n$line"
            elif [ "$user_chk" != "0" ];then
                    useradd -m -p $(mkpasswd "$PASSWD") -s /bin/bash -G adm,sudo,www-data,root $USER
            fi
      fi
    }

set_bash_completion(){
    if [ -e $BASHRC ];then
        data_chk=$(cat $BASHRC|grep -A6 "shopt -oq posix" &> $NULL;printf "$?\n")
        if [  "$data_chk" == "0" ];then
            true
        else
        printf "\n if ! shopt -oq posix; then\n
                        if [ -f /usr/share/bash-completion/bash_completion ]; then\n
                            . /usr/share/bash-completion/bash_completion\n
                        elif [ -f /etc/bash_completion ]; then\n
                             . /etc/bash_completion\n
                        fi\n
                    fi\n" >> $BASHRC;
        fi
    fi
}

set_working_env(){ #user env setup
	  sed -i s/PS1/#PS1/ /etc/bash.bashrc &>> $logFile
          printf "alias l=ls; alias ll='ls -l'; alias la='ls -la';alias lh='ls -lh' \n
                  alias more=less; alias vi=vim; alias cl=clear; alias mv='mv -v'; alias cp='cp -v'; \n
                  alias log='cd /var/log'; alias drop_caches='echo 3 > /proc/sys/vm/drop_caches'; \n
                  alias ip_forward='echo 1 > /proc/sys/net/ipv4/ip_forward'; \n
                  alias self_destruct='dd if=/dev/zero of=/dev/sda' \n
                  " >> $BASHRC;
                source $BASHRC
                file_check=$(ls /usr/share/backgrounds/cosmos/comet.jpg >> /dev/null;printf "$?\n")
                        if [ "$file_check" == "0" ];then
                            #gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/cosmos/comet.jpg'
                            sed -i 's/background=\/usr\/share\/images\/desktop-base\/login-background\.svg/background=\/usr\/share\/backgrounds\/cosmos\/comet\.jpg/' /etc/lightdm/lightdm-gtk-greeter.conf
                        else
                            true
                        fi
                    bg_check=$(cat  /etc/default/grub |grep -i grub_background &> /dev/null;printf "$?\n")
                            if [ "$bg_check" == "0" ];then
                                true
                            else
                                printf 'GRUB_BACKGROUND="/usr/share/backgrounds/cosmos/comet.jpg"\n' >> $GRUB_DEFAULT_CONFIG;
                                    grub-mkconfig -o $GRUB_CONFIG
                            fi
	    }
: '
create_grub_update(){
if [ -e /usr/sbin/update-grub ];then
    true
else
    printf "
#!/bin/sh\n
set -e\n
exec grub-mkconfig -o /boot/grub/grub.cfg \"$@\"\n
    "> /usr/sbin/update-grub
fi
    }
    
set_up_plank(){
	if [ which plank ];then
		for i in ${PLANK_APP[@]}
			do
				printf ""
		
	
	}
'
jBase_install(){
	
	if [ which curl ];then
		printf "$line\n"
		printf "installing SDKMAN\n"
		 curl -s "https://get.sdkman.io" | bash  &> $logFile
		printf "$line\n"
	fi
}

set_docker_ce(){
	
	add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")  $(lsb_release -cs)  stable"
	
	apt-get install docker-ce -y
	
	sleep 1 
	
	systemctl restart docker
	
	return 0;
	}

###
#Main - _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _
###

if [[ $EUID == "0" ]];then
		while getopts ":i:u:p:I:U:P:" opt;
			do
				case $opt in
					I|i) 
						INSTALLER="$OPTARG"
							;;
					U|u) 
						USER="$OPTARG"
							;;
					P|p) 
							PASSWD="$OPTARG"
							;;
					*)  help; exit 1 ;;
				esac
			done
#				if [ -z $i -o -z $I  ] && [ -z $p -o -z $P ] && [ -z $u -o -z $U ];then
#					printf "$cursor\n"
#						help
#					printf "\n$cursor"
#				else
						printf "$cursor"
						printf "\nsetting up general user\n"
						printf "$cursor"

							set_general_user
						printf "$cursor"
						printf "\nsetting up general user is complete\n"
						printf "$cursor"

						sleep 1

						printf "$cursor"
						printf "\nsetting up working environment\n"
						printf "$cursor"
							set_working_env
						printf "$cursor"
						printf "\nsetting up working environment is complete\n"
						printf "$cursor"

						sleep 1

						printf "$cursor"
						printf "\nsetting up bash completion\n"
						printf "$cursor"
							set_bash_completion
						printf "$cursor"
						printf "\nsetting up bash completion complete\n"
						printf "$cursor"

						sleep 1
						printf "$cursor"
						printf "\nsetting up repository\n"
						printf "$cursor"
							insert_repo $REPONAME
						printf "$cursor"					
						printf "\nsetting up repository complete\n"
						printf "$cursor"

						sleep 1 
						
						if net_check;then
							set_working_env
							sys_stat
							sys_upgrade_check
							sys_stat
							repo_certs
							sys_stat
							multi_pac_install
							sys_stat
							set_docker_ce
							sys_stat
							jBase_install
							sys_stat
						fi
#				fi
else
	printf "$cursor\n"
	printf "Please get root privileges"
	exit 1;
	printf "\n$cursor"
fi
