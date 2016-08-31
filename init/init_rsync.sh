## ------------ Initialisation ------------ ##
autoload_conf "${VAR_BCK_CHROOT}/init/init_module.sh"
## ------------ fin initialisation ------------ ##


if [ "${!MODULE}" == "TRUE" ]
then

	# On test les variables OBLIGATOIRES pour le bon fonctionnement du module.
#	liste_variable=(BACKUP_FROM);
#	i=0;
#	while [ $i -lt ${#liste_variable[*]} ];
#	do
#		if_empty ${liste_variable[$i]} >> "${VAR_LOG_NAME_UNIV_err}"  || desactivation_module "${MODULE}";
#		let i++
#	done

	creation_sous_titre_log "Sauvegarde du system avec RSYNC $BACKUP_FROM" >> ${VAR_LOG_NAME_UNIV} & br ${VAR_LOG_NAME_UNIV}

	# - > SI non definis alors on applique les parametres par defaut.
	if [ -z "${OPTION_RSYNC}" ]; then OPTION_RSYNC="--stats -rhuzlO"; fi;
	if [ -z "${TYPE_ANALYSE_RSYNC}" ]; then TYPE_ANALYSE_RSYNC="DEFAULT"; fi;
	if [ -z "${DELETE_EXCLUDED}" ]; then DELETE_EXCLUDED="FALSE"; fi;
	if [ -z "${BACKUP_DELETE_FILES}" ]; then BACKUP_DELETE_FILES="TRUE"; fi;
	if [ -z "${EXCLUSION_PERSO}" ]; then EXCLUSION_PERSO=""; fi;
	if [ -z "${BACKUP_FROM_OVER_SSH}" ]; then BACKUP_FROM_OVER_SSH="FALSE"; fi;
	if [ -z "${BACKUP_FROM_SSH_status}" ]; then BACKUP_FROM_SSH_status="FALSE"; fi;
	if [ -z "${BACKUP_DELETE_FILES_FOLDER_NAME}" ]; then BACKUP_DELETE_FILES_FOLDER_NAME="RECYCLE_BIN"; fi;
	if [ -z "${SHOW_OPTIONS_RSYNC}" ]; then SHOW_OPTIONS_RSYNC="FALSE"; fi;
	titreLogBis=; OPTION_CHECKSUM=; OPTION_DELETE_EXCLUDED=; OPTION_BACKUP_DELETE_FILES=; OPTION_SIMULATION=; OPTION_BWLIMIT=; BACKUP_FROM_SSH_OPTION=;infoConnexionSSH=; OLDIFS=$IFS;
	ori_DEBUG_RSYNC=${DEBUG_RSYNC};
	ori_TYPE_ANALYSE_RSYNC=${TYPE_ANALYSE_RSYNC};
	BACKUP_TO_SSH_status="FALSE";
	
fi

if [ "${!MODULE}" == "TRUE" ]
then
	# Emplacement de RSYNC
	CHROOT_RSYNC=`/usr/bin/which rsync 2>> "${VAR_LOG_NAME_UNIV_err}"` 
	if [ ${?} != 0 ] && ( ! outils_bck "test_execution" "${CHROOT_RSYNC}" >> "${VAR_LOG_NAME_UNIV_err}" )
	then
		desactivation_module "${MODULE}";
		br "${VAR_LOG_NAME_UNIV_err}"
		status 1 "${MODULE} n'est pas correctement installe : < /usr/bin/which rsync >, ne retourne rien de valide !!" >> "${VAR_LOG_NAME_UNIV_err}"
		status 4 "Verifiez l'installation de RSYNC !!" >> "${VAR_LOG_NAME_UNIV_err}";
	fi
fi

if [ "${error_count_module}" == 0 ]
then
	if [ -z ${EXCLUSION_RSYNC} ]; then EXCLUSION_RSYNC="${VAR_BCK_CHROOT}/CONF-USER/${BCK_NAME}-exclusion"; fi;
	if [ -z ${INCLUSION_RSYNC} ]; then INCLUSION_RSYNC="${VAR_BCK_CHROOT}/CONF-USER/${BCK_NAME}-inclusion"; fi;

	# - > Si les fichiers n'existent pas, ils seront automatiquement crees.

################### PREMIER LANCEMENT ##########################
if [ ${INCLU_EXCLU} == "TRUE" ]
then
		if [ ! -f "${EXCLUSION_RSYNC}" ] || [ ! -f "${INCLUSION_RSYNC}" ]
		then
			status 4 "<!> INFORMATIONS PREMIER LANCEMENT <!>"
			status 4 "Il s'agit de votre premier lancement du module RSYNC avec l'instance < ${BCK_NAME} >"
			status 4 "Les fichiers d’exclusions et d'inclusions ont ete crees
	
	Emplacement des fichiers :
	
	EXCLUSION : ${EXCLUSION_RSYNC}
	INCLUSION : ${INCLUSION_RSYNC}
	
	Vous pouvez a present les modifier.
	
	< vi ${EXCLUSION_RSYNC} > 
	< vi ${INCLUSION_RSYNC} >
	
	"
			sleepQuestion 5
		fi
	
		creation_fichier_log "${EXCLUSION_RSYNC}" 1>> "${VAR_LOG_NAME_UNIV}" 2>> "${VAR_LOG_NAME_UNIV_err}" || let error_count_module++
		creation_fichier_log "${INCLUSION_RSYNC}" 1>> "${VAR_LOG_NAME_UNIV}" 2>> "${VAR_LOG_NAME_UNIV_err}" || let error_count_module++
	
	fi
fi

BACKUP_TO=(${VAR_ROOT} ${BACKUP_TO_BIS[*]});
#BACKUP_TO=(${BACKUP_TO_BIS[*]});

# FIN

####### EXCLUSIONS #############################################
#

#if [ "${DEBUG_RSYNC}" == "TRUE" ]
#then
#	#echo "Liste des exclusions : < ${VAR_BCK_CHROOT}/CONF-USER/${BCK_NAME}-exclusion >" >> ${VAR_LOG_NAME_UNIV}
#	lecture_fichier "${EXCLUSION_RSYNC}" 8 '#' 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err};
#	if [ ! -z  "${EXCLUSION_PERSO}" ]; then echo "${EXCLUSION_PERSO}" >> ${VAR_LOG_NAME_UNIV}; fi;
#
#	#echo "Liste des inclusions : < ${VAR_BCK_CHROOT}/CONF-USER/${BCK_NAME}-inclusion >" >> ${VAR_LOG_NAME_UNIV}
#	lecture_fichier "${INCLUSION_RSYNC}" 8 '#' 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err};
##else
##	echo "Exclusion : ${EXCLUSION_RSYNC} " >> ${VAR_LOG_NAME_UNIV};
##	echo "Inclusion : ${INCLUSION_RSYNC} " >> ${VAR_LOG_NAME_UNIV};
#fi
init_fin_session ${VAR_LOG_NAME_UNIV_err} ${VAR_LOG_NAME_UNIV} ${VAR_LOG_NAME} 8 1>> "${VAR_LOG_NAME}" 2>&1
autoload_conf "${VAR_BCK_CHROOT}/init/init_module_end.sh"


