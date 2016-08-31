# v0.2
#################################################################
# INIT VAR
#################################################################

MICROTIME_init=`${CHROOT_BIN_DATE} +%s`;
error_count_init=0;
error_count_module=0
ACTIVATION_MODULE=0;
error_OP=0
nbr_OP=0;

# - > Test de l'existance des variables

if_empty 'VAR_CHROOT' || exit;
if_empty 'VAR_BCK_CHROOT' || exit;
if_empty 'BCK_NAME' || exit;

###########################
# INIT SESSION
###########################
# Supprime le denier slash ex : /bck120/ en /bck120
# Afin d'eviter d'avoir des "/bck120//backuo"
supprime_dernier_slash "${VAR_CHROOT}"; VAR_CHROOT="${return_supprime_dernier_slash}";

# Remplace les espaces par des "_"
show_convert_underscore "${VAR_CHROOT}"; VAR_CHROOT="${show_convert}";

creation_dossier "${VAR_CHROOT}" || exit;

###
# Creation des logs
###


VAR_CHROOT_SESSION="${VAR_BCK_CHROOT}/CONF-USER/tmp/${BCK_NAME}";
creation_dossier "${VAR_CHROOT_SESSION}" || echo 'DIIIIIIIIIIIII'


VAR_LOG_CHROOT_SESSION_init="${VAR_CHROOT_SESSION}/_init.log";
VAR_LOG_CHROOT_SESSION_init_err="${VAR_CHROOT_SESSION}/_init_err.log";
VAR_LOG_CHROOT_SESSION_debug="${VAR_CHROOT_SESSION}/debug.log";
VAR_LOG_CHROOT_SESSION_debug_err="${VAR_CHROOT_SESSION}/debug_err.log";



touch "${VAR_LOG_CHROOT_SESSION_init}"
touch "${VAR_LOG_CHROOT_SESSION_init_err}"


# - > Creation des variables pour les logs
ANNEE=`${CHROOT_BIN_DATE} +%Y`;
MOIS=`${CHROOT_BIN_DATE} +%d/%m/%y`;
JOUR=`${CHROOT_BIN_DATE} +%d-%m`;
HEURE=`${CHROOT_BIN_DATE} +%H:%M-%S`;
MINUTES=`${CHROOT_BIN_DATE} +%H%M%S`;
SECONDE=`${CHROOT_BIN_DATE} +%S`;
MOIS_UNIQUE=`${CHROOT_BIN_DATE} +%m`;
JOUR_UNIQUE=`${CHROOT_BIN_DATE} +%d`;
COMMUN_SUFIX_PATH="${ANNEE}/${MOIS_UNIQUE}/${JOUR_UNIQUE}/${MINUTES}";
COMMUN_SUFIX_PATH_COMPAC="${ANNEE}-${MOIS_UNIQUE}-${JOUR_UNIQUE}-${MINUTES}";

DATE_START_BCK="$(date +%d/%m/%y) $(date +%H:%M:%S)"
MICROTIME_START=`${CHROOT_BIN_DATE} +%s`;
MICROTIME_PID=$$;

# Log temporaire (header du mail)
echo > "${VAR_CHROOT_SESSION}/body_mail.txt"


if [ -z "${ARG_SCRIPT_1_OBLIGATOIRE}" ]; then ARG_SCRIPT_1_OBLIGATOIRE="FALSE"; fi;
if [ "${ARG_SCRIPT_1_OBLIGATOIRE}" == "TRUE" ]
then
	if [ -z "${ARG_SCRIPT_1}" ];
	then
		KILL_PB="Le parametre 1 du script est manquant !!";
		echo "${KILL_PB}" 1>> "${VAR_LOG_CHROOT_SESSION_init}" 2>> "${VAR_LOG_CHROOT_SESSION_init_err}" >> "${VAR_CHROOT_SESSION}/body_mail.txt";
	fi;
fi


###
# GESTION DES MONTAGES
###
if [ ! -z "${MOUNT_SHARE_SCRIPT}" ]
then
	creation_sous_titre_log "Montage des lecteurs reseaux en cours ..." 1>> "${VAR_LOG_CHROOT_SESSION_init}" >> "${VAR_LOG_CHROOT_SESSION_debug}"
	
	# Lancement du script de montage
	if [ -z "${ARG_SCRIPT_MOUNT}" ]; then ARG_SCRIPT_MOUNT=; fi;
	"${MOUNT_SHARE_SCRIPT}" "${ARG_SCRIPT_MOUNT}"  1>> "${VAR_LOG_CHROOT_SESSION_init}" 2>> "${VAR_LOG_CHROOT_SESSION_init_err}" >> "${VAR_LOG_CHROOT_SESSION_debug}"
	if [ ${?} != 0 ]
	then
	
		KILL_PB="Probleme pour monter les lecteurs reseaux";
		echo "${KILL_PB}" 1>> "${VAR_LOG_CHROOT_SESSION_init}" 2>> "${VAR_LOG_CHROOT_SESSION_init_err}" >> "${VAR_CHROOT_SESSION}/body_mail.txt";	
	fi
	echo "######" 1>> "${VAR_LOG_CHROOT_SESSION_init}" >> "${VAR_LOG_CHROOT_SESSION_debug}"
	${CHROOT_BIN_CAT} "${VAR_LOG_CHROOT_SESSION_debug}" && ${CHROOT_BIN_RM} "${VAR_LOG_CHROOT_SESSION_debug}"
	
fi
if [ "${VAR_CHROOT_MOUNT}" == "TRUE" ]
then
	if (! check_si_mount "${VAR_CHROOT}")
	then
		KILL_PB="Le lecteur ${VAR_CHROOT}, n'est pas monte"
		echo "${KILL_PB}" 1>> "${VAR_LOG_CHROOT_SESSION_init}" 2>> "${VAR_LOG_CHROOT_SESSION_init_err}" >> "${VAR_CHROOT_SESSION}/body_mail.txt";
	
	fi
else
	if (check_si_mount "${VAR_CHROOT}")
	then
		KILL_PB="Le lecteur ${VAR_CHROOT}, est monte, alors qu'il ne devrait pas !! < VAR_CHROOT_MOUNT=${VAR_CHROOT_MOUNT}>"
		echo "${KILL_PB}" 1>> "${VAR_LOG_CHROOT_SESSION_init}" 2>> "${VAR_LOG_CHROOT_SESSION_init_err}" >> "${VAR_CHROOT_SESSION}/body_mail.txt";
	fi
fi

###################################
# CREATION DES DOSSIERS & FICHIERS
###################################

###
# DOSSIER RACINE DE LA SAUVEGARDE
###
VAR_ROOT="${VAR_CHROOT}/${BCK_NAME}";

###
# Creation des dossiers des logs
###

VAR_LOG="${VAR_ROOT}/log";
VAR_LOG_NAME="${VAR_LOG}/${MINUTES}-${JOUR}";
VAR_LOG_FINAL="${VAR_LOG}/${ANNEE}/${MOIS_UNIQUE}";

show_convert_underscore "${VAR_LOG_FINAL}";
if [ ! -z "${show_convert}" ]; then VAR_LOG_FINAL="${show_convert}"; fi;
creation_dossier "${VAR_LOG_FINAL}" || status 3 "Probleme de test d'ecriture sur ${VAR_LOG_FINAL}";

${CHROOT_BIN_TOUCH} "${VAR_LOG_NAME}" || status 3 "Probleme de creation du fichier log ${VAR_LOG_NAME}";
if [ ${FULL_LOG} == "TRUE" ]
then
	status 4 "Pour voir le log en direct 'tail -f \"${VAR_LOG_NAME}\"";
fi

################################################
################# PRE CHECK ####################
################################################


###
# - > Verification de l'espace disque
###
if [ ! -z "${MIN_HDD_FREE}" ]
then
	if ( ! check_check_hdd "${VAR_CHROOT}" "${MIN_HDD_FREE}" "DIE" 1>> "${VAR_LOG_CHROOT_SESSION_init}" 2>> "${VAR_LOG_CHROOT_SESSION_init_err}" >> "${VAR_CHROOT_SESSION}/body_mail.txt")
	then
		KILL_PB="Verification de l'espace disque FAILED";
		echo "${KILL_PB}" 1>> "${VAR_LOG_CHROOT_SESSION_init}" 2>> "${VAR_LOG_CHROOT_SESSION_init_err}" >> "${VAR_CHROOT_SESSION}/body_mail.txt";	
	fi
fi

###
# - > Generation du PID unique
###



PID_BCK="${VAR_CHROOT_SESSION}/${BCK_NAME}.pid"
#touch  "${PID_BCK}"
if ( test -f "${PID_BCK}" )
then
	status 1 "
	
#################################################################
      Une sauvegarde est deja en cours d'execution

 < ${PID_BCK} >

 ATTENTION !! CECI N'EST PAS RECOMMANDE !! ATTENTION

 Pour lancer la sauvegarde, supprimez le fichier <PID>

 < kill -9 `${CHROOT_BIN_CAT} ${PID_BCK}` >
 ${CHROOT_BIN_RM} ${PID_BCK} >

#################################################################

	" 1>> "${VAR_LOG_CHROOT_SESSION_init}" 2>> "${VAR_LOG_CHROOT_SESSION_init_err}" >> "${VAR_CHROOT_SESSION}/body_mail.txt";
	KILL_PB="Une sauvegarde est deja en cours d'execution";

else
	#echo "${MICROTIME_PID}" > "${PID_BCK}"
	if ( ! echo "${MICROTIME_PID}" > "${PID_BCK}" )
	then
		KILL_PB="Probleme de creation du fichier pid";
		echo "${KILL_PB}" 1>> "${VAR_LOG_CHROOT_SESSION_init}" 2>> "${VAR_LOG_CHROOT_SESSION_init_err}" >> "${VAR_CHROOT_SESSION}/body_mail.txt";	
	fi
fi

################################################
################# fin PRE CHECK ####################
################################################

###
# - > Mise à jour de l'heue via un serveur ntp
###
if [ ! -z "${SRV_SYNC_NTP_TIME}" ]
then
	creation_sous_titre_log "Reglage de l'heure via NTP (${SRV_SYNC_NTP_TIME})" >> "${VAR_LOG_CHROOT_SESSION_init}"
	ntpbck "${SRV_SYNC_NTP_TIME}" 1>> "${VAR_LOG_CHROOT_SESSION_init}" 2>> "${VAR_LOG_CHROOT_SESSION_init_err}"
	if [ ${?} != 0 ]
	then
		status 1 "Probleme pour joindre le serveur NTP < ${SRV_SYNC_NTP_TIME} >"  >> "${VAR_LOG_CHROOT_SESSION_init}"
	fi
fi



init_fin_session "${VAR_LOG_CHROOT_SESSION_init_err}" "${VAR_LOG_CHROOT_SESSION_init}" "${VAR_LOG_NAME}" 1>> "${VAR_LOG_NAME}" 2>&1

