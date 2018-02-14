#!/usr/bin/env bash

#Author  : br0k3ngl255
#Date    : 27.08.3017
#Purpose : setup systems features on debian based systems.
#Version : 3.2.18

#TODO: write a function that follows the stages of script and lets the use know whats going on.
#TODO: add function that upgrades system if such is needed.
#TODO: make repository deployment more general and save for each distro.
#TODO: validate curl in install function as well so you can proceed with docker and other function.
#TOFO: configure the MATE environment file.
###Vars ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
logFolder="/tmp"
log="install_log.txt"
logFile="$logFile/$log"
line="\n\n==============================================================\n\n"
cursor="\n\n###############################################################\n\n"
curl_flag=0
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
