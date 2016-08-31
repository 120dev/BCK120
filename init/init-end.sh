outils_bck "test_lecture" "${VAR_LOG_NAME}"
if [ $? = 0 ]
then

	####################
	## PRE TRAITEMENT ##
	####################
	if [ -z ${STOP_SI_RETURN_FALSE} ]; then STOP_SI_RETURN_FALSE='TRUE'; fi;


	################
	## Traitement ##
	################
	if [ -z "${KILL_PB}" ]
	then
		if [ -z "${ORDRE_LOAD}" ]; then ORDRE_LOAD=(RSYNC EXTRA SQL ROTATION STATS_SERVER); fi
		i_load_module=0;
		while [ $i_load_module -lt ${#ORDRE_LOAD[*]} ];
		do
			MODULE_load=${ORDRE_LOAD[${i_load_module}]};
			if [ "${!MODULE_load}" == "TRUE" ]
			then
				MODULE_lower=$(tolower "${MODULE_load}")
				autoload_conf "${VAR_BCK_CHROOT}/modules/${MODULE_lower}.sh" || status 3 "Probleme d'execution du fichier < ${VAR_BCK_CHROOT}/modules/${MODULE_lower}.sh >";
				titreLogBis=;
			fi
			let i_load_module++
		done
	else
		MAIL_SUJET="[BCK120] -> ${BCK_NAME} <!!> ${KILL_PB} <!!>";
		echo "
################### KILL ###############################

<!!> ${KILL_PB} <!!>

################### KILL ###############################
		" >> "${VAR_LOG_NAME}" >> "${VAR_CHROOT_SESSION}/body_mail.txt"
	fi

#				MODULE_lower'stats_server';
#				autoload_conf "${VAR_BCK_CHROOT}/modules/stats_server.sh" || status 3 "Probleme d'execution du fichier < ${VAR_BCK_CHROOT}/modules/${MODULE_lower}.sh >" ;	#####################
	## POST TRAITEMENT ##
	#####################
	#`ls ${VAR_LOG_NAME}`
	if [ ! -z "${POST_TRAITEMENT}" ]
	then
		#br "${VAR_LOG_NAME}"; br "${VAR_LOG_NAME}";
		creation_titre_log "POST TRAITEMENT" >> "${VAR_LOG_NAME}";

		iPost=0;
		while [ $iPost -lt ${#POST_TRAITEMENT[*]} ];
		do

			creation_sous_titre_log "Execution du script < ${POST_TRAITEMENT[$iPost]} >" >> "${VAR_LOG_NAME}";

			sh ${POST_TRAITEMENT[$iPost]} >> "${VAR_LOG_NAME}" 2>&1
			status_traitement=${?};
			status 4 "Status de sortie du post-traitement =  ${status_traitement}" >> "${VAR_LOG_NAME}"

			# Si le script ne renvoi pas zero et que {STOP_SI_RETURN_FALSE est a TRUE, alors on KILL la sauvegarde
			if [ ${status_traitement} != 0 ] && [ ${STOP_SI_RETURN_FALSE} == "TRUE" ]
			then
				status 3 "KILL POST TRAITEMENT";
			fi
			let iPost++
		done

		conversion_temps "$(( `${CHROOT_BIN_DATE} +%s` - ${MICROTIME_init}))" # return MICROTIME_END & unite_temps
		status ${status_end_init} "Duree < ${MICROTIME_END} ${unite_temps} >" >> "${VAR_LOG_NAME}"
		creation_titre_log "FIN POST TRAITEMENT" >> "${VAR_LOG_NAME}";
		#br "${VAR_LOG_NAME}";br "${VAR_LOG_NAME}";
	fi

	###################################################
	## Creation ou Modification des fichiers de logs ##
	###################################################

	if [ "${ROTATION}" == "TRUE" ] && [ "$ROTATION_FICHIER" != 0 ]; then IF_ROTATION="ROTATION"; fi;

	#creation_titre_log "THE END ${BCK_NAME}"  >> "${VAR_LOG_NAME}"
	if [ "${error_OP}" != 0 ]
	then
		nom_fichier_log="${IF_ROTATION}--ERROR-${error_OP}-TRUE-${nbr_OP}.log"
	else
	 	nom_fichier_log="${IF_ROTATION}-TRUE-${nbr_OP}.log"
	fi

	deplacement_fichier_log "${VAR_LOG_NAME}" "${VAR_LOG_FINAL}/${MINUTES}-${JOUR}-${nom_fichier_log}";

	VAR_LOG_NAME="${VAR_LOG_FINAL}/${MINUTES}-${JOUR}-${nom_fichier_log}";

	outils_bck "test_ecriture" "${VAR_LOG_NAME}" >> "${VAR_LOG_NAME}" 2>&1
	#status ${?} "Log de la sauvegarde < ${VAR_LOG_NAME} > " >> "${VAR_LOG_NAME}";


##################################################################################
# FIN
##################################################################################
#                        MICROTIME FIN      - MICROTIME DEBUT
conversion_temps "$(( `${CHROOT_BIN_DATE} +%s` - ${MICROTIME_START}))" # return MICROTIME_END & unite_temps

if [ ${FULL_LOG} == "TRUE" ]
then
true_OP=$((${nbr_OP}-${error_OP}));
echo "
-------ver @bck120 v${VER}---------------
# |
# | Debut : ${DATE_START_BCK}
# | Fin : $(date +%d/%m/%y) $(date +%H:%M:%S)
# | Duree du transfert ${MICROTIME_END} ${unite_temps}
# |
# | Nombre de modules actives : ${ACTIVATION_MODULE}
# | Nombre d'operations : ${nbr_OP} pour TRUE (${true_OP}) et FALSE (${error_OP})
# |
# | LOG < ${VAR_LOG_NAME} >
# |
--------------------------------- " >> "${VAR_LOG_NAME}";
	clean_espace_fichier "${VAR_LOG_NAME}"
fi
	if [ "${NOTIF_MAIL}" != "FALSE" ]
	then
		autoload_conf "${VAR_BCK_CHROOT}/modules/notification.sh"
	fi

	if [ "$DEBUG" == "TRUE" ] || [ ! -z "${KILL_PB}" ] || [ ${error_OP} -ne 0 ]
	then
		if [ ${FULL_LOG} == "TRUE" ]; then echo ' '; status 4 "--- fin ---"; fi;
		showLog "${VAR_LOG_NAME}";
	fi
fi

nettoyage_session

if [ "$DEBUG" == "TRUE" ]; then echo "Exit status = ${error_OP}"; fi;

exit ${error_OP}
