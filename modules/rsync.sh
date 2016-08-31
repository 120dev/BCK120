##########################################################################################
#		## RSYNC ##
##########################################################################################
MODULE="RSYNC";
## ------------ Initialisation ---------------- ##
autoload_conf "${VAR_BCK_CHROOT}/init/init_${MODULE_lower}.sh"
## ------------ fin Initialisation ------------ ##

if [ "${!MODULE}" == "TRUE" ]
then

##############################################################################################################################
			# DEFINITION DE LA DESTINATION DES BACKUPS #
##############################################################################################################################

	i_to=0;
	while [ $i_to -lt ${#BACKUP_TO[*]} ];
	do
		BACKUP_DESTINATION="${BACKUP_TO[${i_to}]}/${MODULE}";
		
		BACKUP_TO_SSH_status=; SSH_RSYNC_OPTION=;
		i_to_pour_log=$(($i_to+1))
echo "
#####################################################################

  No $i_to_pour_log < ${BACKUP_DESTINATION} >

#####################################################################
" >> ${VAR_LOG_NAME_UNIV};

		ori_TYPE_ANALYSE_RSYNC=${TYPE_ANALYSE_RSYNC};

		IFS=@; login_to=( $BACKUP_DESTINATION ); login_to=${login_to[0]};
		IFS=: ;host_to=( ${login_to[1]} );	host_to=${host_to[0]};dossier_to=${host_to[1]};
		
		if [ ! -z ${login_to} ] && [ ! -z ${host_to} ] && [ ! -z ${dossier_to} ]
		then
			echo "if [ ! -z ${login_to} ] && [ ! -z ${host_to} ] && [ ! -z ${dossier_to} ]" >> ${VAR_LOG_NAME_UNIV}
			BACKUP_TO_SSH_status="TRUE";
			SSH_RSYNC_OPTION="-e ssh";
			#TYPE_ANALYSE_RSYNC="CHECKSUM";
			TYPE_SYNCHRO="RSYNC over SSH";
			VAR_DELETE_FILE="${dossier_to}/${BCK_NAME}/${BACKUP_DELETE_FILES_FOLDER_NAME}/${COMMUN_SUFIX_PATH}";
			creation_dossier_distant ${login_to} ${host_to} "${dossier_to}" 1>> /dev/null 2>> ${VAR_LOG_NAME_UNIV_err} || skipFolder="TRUE";
			creation_dossier_distant ${login_to} ${host_to} "${VAR_DELETE_FILE}" 1>> /dev/null 2>> ${VAR_LOG_NAME_UNIV_err} || skipFolder="TRUE";
		else
			TYPE_ANALYSE_RSYNC="${ori_TYPE_ANALYSE_RSYNC}";
			BACKUP_TO_SSH_status="FALSE";
		fi
		IFS=$OLDIFS;
		i=0;
		MICROTIME_init=`${CHROOT_BIN_DATE} +%s`;

##############################################################################################################################
			# DEFINITION DE LA SOURCE / DESTINATIONS DES BACKUPS #
##############################################################################################################################
		while [ $i -lt ${#BACKUP_FROM[*]} ];
		do
			BACKUP_DESTINATION="${BACKUP_TO[${i_to}]}/${MODULE}";
			BACKUP_DIR="${BACKUP_FROM[$i]}"
			
			if [ "${BACKUP_TO_SSH_status}" == "TRUE" ]; then creation_dossier_distant ${login_to} ${host_to} "${dossier_to}/RSYNC/${BACKUP_DIR}" 1>/dev/null 2>> ${VAR_LOG_NAME_UNIV_err} || skipFolder="TRUE"; fi

			infoErreur_RSYNC=; statusRSYNC=;

			IFS=@; login=( $BACKUP_DIR ); login=${login[0]};
			IFS=: ;host=( ${login[1]} );	host=${host[0]};dossier=${host[1]};

			# -----------------------------------------------------------------------------
			# Si le dossier à sauvegarder est un dossier au format root@host:/folder
			# -----------------------------------------------------------------------------
			if [ ! -z ${login} ] && [ ! -z ${host} ] && [ ! -z ${dossier} ]
			then
				#echo "if [ ! -z ${login} ] && [ ! -z ${host} ] && [ ! -z ${dossier} ]" >> ${VAR_LOG_NAME_UNIV}
				TYPE_SYNCHRO="RSYNC over SSH";
				# -----------------------------------------------------------------------------
				# Si le dossier de source n'est pas un dossier au format root@host:/folder
				# -----------------------------------------------------------------------------
				if [ "${BACKUP_TO_SSH_status}" == "FALSE" ]
				then

					BACKUP_FROM_SSH_status="TRUE";
					SSH_RSYNC_OPTION="-e ssh";
					BACKUP_DESTINATION="${BACKUP_DESTINATION}/${host}${dossier}";
					if [ "${BACKUP_TO_SSH_status}" == "FALSE" ]; then VAR_DELETE_FILE="${BACKUP_TO[${i_to}]}/${MODULE}/${host}/${BACKUP_DELETE_FILES_FOLDER_NAME}/${dossier}"; fi
			if [ ${BACKUP_TO_SSH_status} == "TRUE" ]
			then
				creation_dossier_distant ${login_to} ${host_to} "${BACKUP_DESTINATION}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} || skipFolder="TRUE";
			fi
			
					#TYPE_ANALYSE_RSYNC="CHECKSUM";
				else
					statusRSYNC="< FALSE >";
					status 1 "< Vous ne pouvez pas synchroniser deux dossiers distants entre eux >" >> ${VAR_LOG_NAME_UNIV_err};
					status 4 "Vous pouvez utiliser < SCP > pour cela" >> ${VAR_LOG_NAME_UNIV_err};
					status 4 "scp -r ${BACKUP_DIR}  ${login_to}@${host_to}:${dossier_to}/backup/${BACKUP_DIR}" >> ${VAR_LOG_NAME_UNIV_err};
					br ${VAR_LOG_NAME_UNIV_err};
				fi

			else
				# -----------------------------------------------------------------------------
				# SINON, il s'agit d'un dossier standard (donc non SSH)
				# -----------------------------------------------------------------------------
				BACKUP_FROM_SSH_status="FALSE";
				TYPE_SYNCHRO=;
  			BACKUP_DESTINATION="${BACKUP_DESTINATION}/localhost/${BACKUP_DIR}";
  			creation_dossier "${BACKUP_DESTINATION}";
			if [ ${BACKUP_TO_SSH_status} == "TRUE" ]
			then

			IFS=@; login_SSH_INIT=( $BACKUP_DESTINATION ); login_SSH=${login_SSH_INIT[0]};
			IFS=: ;host_SSH_INIT=( ${login_SSH_INIT[1]} );	host_SSH=${host_SSH_INIT[0]};dossier_SSH=${host_SSH_INIT[1]};
			recherche_remplace "${dossier_SSH}/" "\/"; dossier_SSH="${dossier_SSH}";
			#echo "==> $BACKUP_DIR $host_SSH $dossier_SSH"1>> ${VAR_LOG_NAME_UNIV}
			creation_dossier_distant ${login_to} ${host_to} "${dossier_SSH}" 1>> ${VAR_LOG_NAME_UNIV}  2>> ${VAR_LOG_NAME_UNIV_err} || skipFolder="TRUE";
			fi
			
				if [ "${BACKUP_TO_SSH_status}" == "FALSE" ]; then VAR_DELETE_FILE="${BACKUP_TO[${i_to}]}/${MODULE}/localhost/${BACKUP_DELETE_FILES_FOLDER_NAME}/${BACKUP_DIR}"; TYPE_ANALYSE_RSYNC="${ori_TYPE_ANALYSE_RSYNC}"; fi
				#TYPE_SYNCHRO="FOLDER";
				outils_bck "test_lecture" "${BACKUP_DIR}" >> ${VAR_LOG_NAME_UNIV_err} || { skipFolder="TRUE"; statusRSYNC="Le dossier < ${BACKUP_DIR} > n'existe pas !!"; }

			fi

			IFS=$OLDIFS;
			if [ ! -n "${statusRSYNC}" ]; then statusRSYNC="OK" ; fi;
			if [ -z "${TYPE_SYNCHRO}" ]; then TYPE_SYNCHRO="< FOLDER >" ; fi;

			recherche_remplace "${BACKUP_DIR}/" "\/"; BACKUP_DIR="${return_recherche_remplace}";
			recherche_remplace "${BACKUP_DESTINATION}/" "\/"; BACKUP_DESTINATION="${return_recherche_remplace}";
			recherche_remplace "${VAR_DELETE_FILE}/" "\/"; VAR_DELETE_FILE="${return_recherche_remplace}";

			VAR_DELETE_FILE="${VAR_DELETE_FILE}/${COMMUN_SUFIX_PATH}";

			echo "
~~~~~~~~~~~~~~~~~~~ Information sur la synchronisation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Source                  : < ${BACKUP_DIR} (${statusRSYNC})>
Destination             : < ${BACKUP_DESTINATION}
Elements supprimes      : < ${VAR_DELETE_FILE} >
Type de synchronisation : < ${TYPE_SYNCHRO} >
Simulation              : < ${SIMULATION_RSYNC} >" >> ${VAR_LOG_NAME_UNIV};

##############################################################################################################################
#             GESTION DES INCLUSIONS / EXCLUSIONS
##############################################################################################################################

			# -----------------------------------------------------------------------------
			# Check des logs du montage
			# -----------------------------------------------------------------------------

			# - > Si erreurs lors du montage des dossiers
			# - > Alors le dossier en question, sera exclu de la sauvegarde
			# - > Et les "fichiers/dossiers" exclus ne seront pas supprimes

			if ( test -f  "${VAR_CHROOT_SESSION}/mount_error.log" && $(${CHROOT_BIN_CAT} "${VAR_CHROOT_SESSION}/mount_error.log" |sed '/^$/d' |wc -l) != 0 )
			then
				${CHROOT_BIN_CAT} "${VAR_CHROOT_SESSION}/mount_error.log"  >> ${VAR_LOG_NAME_UNIV};

				DELETE_EXCLUDED="FALSE"
				mount_error_new="${VAR_CHROOT_SESSION}/mount_error_new.log"
				for m_err in `${CHROOT_BIN_CAT} "${VAR_CHROOT_SESSION}/mount_error.log" |sed '/^$/d'`
				do
					echo "**${m_err#*${BACKUP_DIR}}/**" >> "${mount_error_new}" &&	echo "- **${m_err#*${BACKUP_DIR}}/**" >> "${mount_error_new}"
					echo "${m_err#*${BACKUP_DIR}}" >> "${mount_error_new}" && echo "- ${m_err#*${BACKUP_DIR}}" >> "${mount_error_new}"
					echo "${m_err}" >> "${mount_error_new}" && echo "- ${m_err}" >> "${mount_error_new}"

					var_tmp=${m_err#*"${BACKUP_DIR}"};
					echo "${var_tmp/\//}" >> "${mount_error_new}" && echo "- ${var_tmp/\//}" >> "${mount_error_new}"
					# DEBUG
					cat "${mount_error_new}"  >> ${VAR_LOG_NAME_UNIV};
				done
				EXLU_INCLU_mount="--exclude-from=${VAR_CHROOT_SESSION}/mount_error_new.log";
			fi
			if [ ! -z "${EXCLUSION_PERSO}" ]; then EXCLUSION_PERSO="--exclude='${EXCLUSION_PERSO}'"; fi;
			if [ ${INCLU_EXCLU} == "TRUE" ]
			then
				if [ "${DELETE_EXCLUDED}" == "TRUE" ]; then OPTION_DELETE_EXCLUDED="--delete-excluded";	fi;
				EXLU_INCLU="${OPTION_DELETE_EXCLUDED} --exclude-from=${EXCLUSION_RSYNC} --include-from=${INCLUSION_RSYNC} ${EXCLUSION_PERSO}";
			else
				EXLU_INCLU=;DELETE_EXCLUDED=;
			fi

##############################################################################################################################
#            OPTIONS DE RSYNC
##############################################################################################################################

			if [ "${TYPE_ANALYSE_RSYNC}" == "CHECKSUM" ]; then OPTION_CHECKSUM="--checksum"; fi;
			
			if [ "${SIMULATION_RSYNC}" == "TRUE" ]; then OPTION_SIMULATION="--dry-run";	fi;
			if [ "${BACKUP_DELETE_FILES}" == "TRUE" ]; then creation_dossier "${VAR_DELETE_FILE}"; OPTION_BACKUP_DELETE_FILES="--delete --backup --backup-dir=${VAR_DELETE_FILE}"; fi;
			OPTIONS="${OPTION_RSYNC} ${OPTION_BWLIMIT} ${OPTION_SIMULATION} ${OPTION_CHECKSUM} ${SSH_RSYNC_OPTION} ${OPTION_BACKUP_DELETE_FILES} ${EXLU_INCLU} ${EXLU_INCLU_mount} --exclude ${BACKUP_DELETE_FILES_FOLDER_NAME}"
			#OPTIONS="${OPTION_RSYNC} ${OPTION_BWLIMIT} ${OPTION_SIMULATION} ${OPTION_CHECKSUM} ${SSH_RSYNC_OPTION} ${OPTION_BACKUP_DELETE_FILES}"

			if [ "${SHOW_OPTIONS_RSYNC}" == "TRUE" ]; then echo "Options RSYNC           : < ${OPTIONS} >" >> ${VAR_LOG_NAME_UNIV}; fi; br ${VAR_LOG_NAME_UNIV};

##############################################################################################################################
#             LANCEMENT DE RSYNC
##############################################################################################################################
	#	skipFolder="TRUE";
		if [ "${!MODULE}" == "TRUE" ] && [ -z "${skipFolder}" ]
		then
		
			creation_dossier "${BACKUP_DESTINATION}";
			
			echo "######" >> ${VAR_LOG_NAME_UNIV};br ${VAR_LOG_NAME_UNIV}; 
			if ( ! ${CHROOT_RSYNC} ${OPTIONS} "${BACKUP_DIR}" "${BACKUP_DESTINATION}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} )
			then
				infoErreur_RSYNC="!!!! --> Probleme avec Rsycn, verifiez la configuration <-- !!!!";
				DEBUG_RSYNC="TRUE";
			else
				DEBUG_RSYNC=${ori_DEBUG_RSYNC};
				infoErreur_RSYNC=;
			fi
			br ${VAR_LOG_NAME_UNIV}; echo "######" >> ${VAR_LOG_NAME_UNIV};br ${VAR_LOG_NAME_UNIV}; 
		fi
		
##############################################################################################################################
#             DEBUG
##############################################################################################################################


			if [ "${DEBUG_RSYNC}" == "TRUE" ] || [ "${skipFolder}" == "TRUE" ]
			then
				br ${VAR_LOG_NAME_UNIV}
				status 5 "----------- DEBUG RSYNC -----------" >> ${VAR_LOG_NAME_UNIV}
				br ${VAR_LOG_NAME_UNIV};
				if [ ! -z "${infoErreur_RSYNC}" ]; then status 1 "${infoErreur_RSYNC}" >> ${VAR_LOG_NAME_UNIV}; br ${VAR_LOG_NAME_UNIV}; fi

				echo ${CHROOT_RSYNC} ${OPTIONS} "${BACKUP_DIR}" "${BACKUP_DESTINATION}" >> ${VAR_LOG_NAME_UNIV}

				br ${VAR_LOG_NAME_UNIV};
				status 5 " ---------- DEBUG RSYNC -----------" >> ${VAR_LOG_NAME_UNIV}
				br ${VAR_LOG_NAME_UNIV}
			fi

			init_fin_session ${VAR_LOG_NAME_UNIV_err} ${VAR_LOG_NAME_UNIV} "${VAR_LOG_NAME}" 1>> "${VAR_LOG_NAME}" 2>&1
			rm -f ${VAR_LOG_NAME_UNIV_err}; touch ${VAR_LOG_NAME_UNIV_err};
			let i++;
		done
	let i_to++;
	done
fi
echo "
###############################
~~~~~~~~-- FIN RSYNC -~~~~~~~~-
###############################
" >> ${VAR_LOG_NAME};

##############################################################################################################################
			# FIN #
##############################################################################################################################
if ( test -f "${VAR_CHROOT_SESSION}/mount_error_new.log" )
then
	if (cat "${VAR_CHROOT_SESSION}/mount_error_new.log" |sed '/^$/d' |wc -l); then supprime_element "${VAR_CHROOT_SESSION}/mount_error_new.log"; fi
fi