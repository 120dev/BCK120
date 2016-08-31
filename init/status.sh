BACKUP_FROM_OVER_SSH="FALSE";
if [ ! -z "${KILL_PB}" ]
then
	RSYNC='FALSE';EXTRA='FALSE';SQL='FALSE';ROTATION='FALSE';
fi

################################################################### NOTIF_MAIL
if [ "${NOTIF_MAIL}" == "TRUE" ]
then
	info_NOTIF_MAIL="Notification par mail : ${MAIL_TO}";
else
	info_NOTIF_MAIL="Notification par mail : FALSE";
fi
################################################################### RSYNC
if [ "${RSYNC}" == "TRUE" ]
then

	info_RSYNC="
~~~~~~ -- RSYNC -- ~~~~~~

SIMULATION : $SIMULATION

Backup TO : ${BACKUP_TO[*]}
Backup FROM : ${BACKUP_FROM}
Type analyse : ${TYPE_ANALYSE_RSYNC}
Delete excluded : ${DELETE_EXCLUDED}
Backup delete files : ${BACKUP_DELETE_FILES}
Limite bande passante : ${BWLIMIT} kb/s
";

 if [ ${BACKUP_FROM_OVER_SSH} == "TRUE" ]
 then
 		info_RSYNC="
${info_RSYNC}
Syncronisation via SSH : ${BACKUP_FROM_OVER_SSH}
 Serveur : ${SSH_HOST}
 Login connexion SSH : ${SSH_LOGIN}
 Option SSH : ${SSH_RSYNC_OPTION}
 Backup TO : ${SSH_BACKUP_TO[*]}";
	fi
	info_RSYNC="${info_RSYNC}";
fi
################################################################### EXTRA
if [ "${EXTRA}" == "TRUE" ]
then
info_EXTRA="
~~~~~~ -- EXTRA -- ~~~~~~

Liste : ${array_extra[*]}
Compression : ${COMPRESSION_EXTRA}"
fi

################################################################### SQL
if [ "${SQL}" == "TRUE" ]
then

info_SQL="
~~~~~~ -- SQL -- ~~~~~~
";
	if [ ${METHODE_1} == "TRUE" ]
	then		
		info_SQL_M1="
Methode 1 : ${METHODE_1}
 Serveur : ${SQL_HOST}
 Login : ${SQL_LOGIN}
 Database : ${SQL_DATABASE[*]}
 Dump commun : ${SQL_DUMP_COMMUN}
";
	else
		info_SQL_M1="METHODE 1 : ${METHODE_1}";
	fi
	if [ ${METHODE_2} == "TRUE" ]
	then
		info_SQL_M2="
Methode 2 : ${METHODE_2}
 Stop MySQL : ${STOPSQL}
 Path Init Script MySQL : ${SQL_PATH_INIT}
 Path Lib MySQL : ${PATH_LIB_SQL}";
fi
info_SQL="${info_SQL} ${info_SQL_M1} ${info_SQL_M2}";
 
fi
################################################################### ROTATION
if [ "${ROTATION}" == "TRUE" ]
then
	info_ROTATION="
~~~~~~ -- ROTATION -- ~~~~~~
NBR jour rotation : ${NBR_JOUR_ROTATION}
Type rotation : ${TYPE_ROTATION}";
else
	info_ROTATION="ROTATION : FALSE";
fi
###############################################################################################################
echo "
####### - ${BCK_NAME} - @bck120 v${VER} ######
## < $DATEJ >
##
## PID < ${MICROTIME_PID} >
## Minutes < $MINUTES >
##############################

Nom de l'instance : ${BCK_NAME}

Etat des modules :
------------------
RSYNC : ${RSYNC}
EXTRA : ${EXTRA}
MySQL : ${SQL}
ROTATION : ${ROTATION}
$info_RSYNC ${info_EXTRA} ${info_SQL}

~~~~~~ Divers ~~~~~~
HDD Free Mini : ${MIN_HDD_FREE} %
${info_NOTIF_MAIL}
~~~~~~ fin ~~~~~~ ">> "${VAR_CHROOT_SESSION}/body_mail.txt";

#${CHROOT_BIN_SED} "s/FALSE/Inactif/"  "${VAR_CHROOT_SESSION}/body_mail.txt" > "${VAR_CHROOT_SESSION}/body_mail.tmp"
#${CHROOT_BIN_SED} "s/TRUE/Actif/"  "${VAR_CHROOT_SESSION}/body_mail.tmp" >> "${VAR_CHROOT_SESSION}/body_mail.tmp"
#sed "s/FALSE/Desactive/"

if [ "${SHOW_STATUS}" == "TRUE" ];then ${CHROOT_BIN_CAT} "${VAR_CHROOT_SESSION}/body_mail.txt" >> "${VAR_LOG_NAME}"; fi

#cp "${VAR_CHROOT_SESSION}/body_mail.txt" "/etc/init.d/bck120/body_mail.sav"

#2>&1 | tee


# SIMULATION=$SIMULATION;
# BACKUP_TO=(${BACKUP_TO});
# BACKUP_FROM=(${BACKUP_FROM};

