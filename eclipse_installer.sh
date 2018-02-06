#!/usr/bin/env bash

########################################################################
#created by br0k3ngl255
#license: GPLv3
#
########################################################################

###Variables
HOME=$(pwd)
INST_DIR="/opt"
TMP="/tmp"
CURSOR="\n\n####################################################################################\n\n"
LINE="\n\n====================================================================================\n\n"
LINK="http://eclipse.bluemix.net/packages/oxygen.2/data/eclipse-javascript-oxygen-2-linux-gtk-x86_64.tar.gz"
FILE="eclipse.tar.gz"
NAME="eclipse"
logfile="eclipse_install.log"
logFile="$TMP/$logfile"
#downloader="wget"
###Functions
net_check(){
	cmd=$(ping -c 1 vk.com &> /dev/null; echo $?)
		if  (($cmd==0));then
			printf $CURSOR
				printf "Network Up"
			printf $CURSOR

		else
			printf $CURSOR			
				printf "Network Down, exiting..."
			printf $CURSOR
			exit 1
		fi
}


download_progress(){
	local spin='|/-\'
	local delay=0.5
	progress=$(ps aux|grep -v grep|grep wget &> /dev/null ;echo $?) 
	while [ $progress -eq 0 ]
		do
			local temp=${spin#?}
			printf " [%c]  " "$spin"
			local spin=$temp${spin%"$temp"}
			sleep $delay
			printf "\b\b\b\b\b\b"
		done
		printf "   \b\b\b"
	}
	
get_eclipse(){
	if [ -x /usr/bin/curl ];then
		download_progress
		cd $TMP && { curl -O $LINK ; cd -; }
		download_progress
		if [ -e $TMP/$FILE ];then
			tar xvzf $TMP/$FILE -C $INST_DIR
		else
			printf "\n Something went wrong\n";exit 1;
		fi
	elif [ -x /usr/bin/wget ];then
		download_progress
		wget  $LINK  -O $TMP/$FILE &> /dev/null
		download_progress
		#if [ -e $TMP/$FILE ];then
	#		tar xvzf $TMP/$FILE -C $INST_DIR
#		else
#			printf $CURSOR
#				printf "Something went wrong"
#			printf $CURSOR
#			exit 1;
#		fi
		
	else
		printf $CURSOR
			printf " no available tool to download the file\n"
		printf $CURSOR			
		exit 1;
	fi
}


eclipse_gui_setup(){
if [[ -e $TMP/$FILE ]];then
	cd $TMP
		download_progress
		tar xvzf $FILE -C $INST_DIR &> $logFile
		download_progress
fi

if [[ ! -e /usr/share/applications/$NAME.desktop ]];then

cat <<EOF > /usr/share/applications/$NAME.desktop
	[Desktop Entry]
	Type=Application
	Version=
	Name=Eclipse
	Exec=eclipse %F
	Icon=eclipse
	Terminal=false
	Categories=GTK;Development;IDE;
	StartupNotify=true
EOF
fi 
}

eclipse_bin_setup(){
	if [[ ! -e /usr/bin/$NAME ]];then
		cat << EOF > /usr/bin/$NAME
			#!/usr/bin/env bash

				BIN="/opt/eclipse"
				$BIN/eclipse "$*"

EOF

		chmod +x /usr/bin/$NAME	
	
	
	elif [[ -e /usr/bin/$NAME ]];then
		chmod +x /usr/bin/$NAME	

	fi

}

permission_setup(){
	cmd=$(cat /etc/passwd|awk -F : {'print $3'})
		for i in $cmd ; 
			do 
				if (($i>=1000))&&(($i<=2000));then
					chown $i:$i $INST_DIR/$NAME -R
						break
				fi 
			done
}

####
#Main - _ -- _ -- _ -- _ -- _ -- _ -- _ -- _ -- _ -- _ -- _ -- _ -- _ -
####

	if (($EUID == 0));then
		net_check;
			if [ -e $INST_DIR/$NAME ];then
				true
			elif [ ! -e $INST_DIR/$NAME ];then
				get_eclipse
			fi
		eclipse_setup;permission_setup
	else
		clear
		printf "$CURSOR"
		printf "\n Please run with root\n" 
		printf "$CURSOR"
	fi
