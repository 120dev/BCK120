#!/bin/bash

ArrayRsync=(
# BCK FROM
bck_from
# BCK TO
bck_to
# BCK OPTIONS
option
)
function syncro_rsync ()
{
	echo ${ArrayRsync[0]}
	echo ${ArrayRsync[1]}
	echo ${ArrayRsync[2]}
}
---------
##########################################################################################
#		## RSYNC ##
##########################################################################################
MODULE="RSYNC";

## ------------ Initialisation ---------------- ##
autoload_conf "${VAR_BCK_CHROOT}/init/init_${MODULE_lower}.sh"
## ------------ fin Initialisation ------------ ##

if [ "${!MODULE}" == "TRUE" ]
then
	# On parcout les dossiers à sauvegarder
	i_to=0;
	while [ $i_to -lt ${#BACKUP_TO[*]} ];
	do

		creation_sous_titre_log "No $i_to ${BACKUP_TO}" >> ${VAR_LOG_NAME_UNIV};
		br ${VAR_LOG_NAME_UNIV};
		BACKUP_DESTINATION="${BACKUP_TO}/backup";
		if [ ${?} != 0 ]
		then
			status 1 "Desactivation de BACKUP_DELETE_FILES" >> "${VAR_LOG_NAME_UNIV_err}"
			BACKUP_DELETE_FILES='FALSE';
		fi

	  # On parcout les dossiers a sauvegarder
		i=0;
		while [ $i -lt ${#BACKUP_FROM[*]} ];
		do
			BACKUP_DIR="${BACKUP_FROM[$i]}"
			#supprime_dernier_slash "${BACKUP_DIR}"; BACKUP_DIR="${return_supprime_dernier_slash}"
			#BACKUP_TO=;NON_DOSSIER=;

			IFS=@; login=( $BACKUP_DIR ); login=${login[0]};
			IFS=: ;host=( ${login[1]} );	host=${host[0]};dossier=${host[1]};
			
			if [ ! -z ${host} ]
			then
				echo 'ooooooooooooooooooooo'  >> "${VAR_LOG_NAME_UNIV}"
				BACKUP_FROM_SSH_status="TRUE";
				SSH_RSYNC_OPTION="-e ssh";
				#NON_DOSSIER=`${CHROOT_BIN_BASENAME} "${dossier}"`;
				BACKUP_SOURCE="${login}@${host}:${dossier}";
				BACKUP_DIR="${dossier}";
				#BACKUP_TO="${BACKUP_TO}/${NON_DOSSIER}";
				
			else
				NON_DOSSIER=`${CHROOT_BIN_BASENAME} "${BACKUP_DIR}"`;
				
				
			fi
			BACKUP_DESTINATION="${BACKUP_DESTINATION}${BACKUP_DIR}";
			creation_dossier "${BACKUP_DESTINATION}"
			
			# - > Repertoire de destination des 'fichiers/dossiers' effaces.
			VAR_DELETE_FILE="${BACKUP_TO}/${BACKUP_DELETE_FILES_FOLDER_NAME}${BACKUP_DIR}/${COMMUN_SUFIX_PATH}";
			creation_dossier "${VAR_DELETE_FILE}" >> "${VAR_LOG_NAME_UNIV_err}" 2>&1
			
			IFS=$OLDIFS;

			status_pour_log=`${CHROOT_BIN_BASENAME} "${BACKUP_DIR}"`;
			
			if [ "${BACKUP_FROM_OVER_SSH}" == "FALSE" ]
			then
				BACKUP_FROM_OVER_SSH_status="
-- Information sur la synchronisation --
----------------------------------
Source             : < ${BACKUP_DIR} >
Destination        : < ${BACKUP_DESTINATION} >
Elements supprimes : < ${VAR_DELETE_FILE}/${NON_DOSSIER} >";
			else
				BACKUP_FROM_OVER_SSH_status="Destination : < ${BACKUP_DIR} >";
			fi
			
			br  ${VAR_LOG_NAME_UNIV};
			echo "
################################################################

----- [ $status_pour_log ] ------------------------------------

################################################################
${BACKUP_FROM_OVER_SSH_status}
" >> ${VAR_LOG_NAME_UNIV};


			if [ ${BACKUP_FROM_SSH_status} == "FALSE" ] && [ ! -d "${BACKUP_DIR}" ]
			then
				echo "Verifiez que le Dossier : < ${BACKUP_DIR} > existes !!"
				status ${?} "Verifiez que le Dossier : < ${BACKUP_DIR} > existes !!" >> ${VAR_LOG_NAME_UNIV_err};
				echo >> ${VAR_LOG_NAME_UNIV_err};

				SIMULATION="TRUE";
				DELETE_EXCLUDED="FALSE"
			fi


			###############################################################
			# - > Si erreurs lors du montage des dossiers
			# - > Alors le dossier en question, sera exclu de la sauvegarde
			# - > Et les "fichiers/dossiers" exclus ne seront pas supprimes
			###############################################################

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
			EXLU_INCLU="--exclude-from=${EXCLUSION_RSYNC} --include-from=${INCLUSION_RSYNC} ${EXCLUSION_PERSO}";
			####### fin EXCLUSIONS #############################################


			####### LANCEMET DE RSYNC  #############################################
			#

			if [ "${TYPE_ANALYSE_RSYNC}" == "CHECKSUM" ]; then OPTION_CHECKSUM="--checksum"; fi;
			if [ "${DELETE_EXCLUDED}" == "TRUE" ]; then OPTION_DELETE_EXCLUDED="--delete-excluded";	fi;
			if [ "${SIMULATION}" == "TRUE" ]; then OPTION_SIMULATION="--dry-run";	fi;

##############################################################
####### SSH RSYNC  ###########################################
##############################################################
#
#			if [ "${BACKUP_FROM_OVER_SSH}" == "TRUE" ]
#			then
#				SSH_RSYNC_OPTION='-e ssh';
#
#				if [ ! -z "${SSH_BACKUP_TO[$i]}" ]; then BACKUP_DIR_ssh="${SSH_BACKUP_TO[$i]}"; else BACKUP_DIR_ssh="${BACKUP_DIR}"; fi
#				supprime_dernier_slash "${BACKUP_DIR_ssh}"; BACKUP_DIR_ssh="${return_supprime_dernier_slash}";
#
#				VAR_DELETE_FILE="\"${BACKUP_DIR_ssh}/${BACKUP_DELETE_FILES_FOLDER_NAME_ssh}/${COMMUN_SUFIX_PATH}\"";
#
#				if [ -z ${SSH_BACKUP_TO[$i]} ]
#				then
#					supprime_dernier_slash "${BACKUP_DIR}"; BACKUP_DIR="${return_supprime_dernier_slash}";
#					BACKUP_TO="${SSH_LOGIN}@${SSH_HOST}:\"${BACKUP_DIR}/${BCK_NAME}\"";
#
#					# Création du dossier sur l'host distance
#					backupFolder="${BACKUP_DIR}/${BCK_NAME}";
#
#					${CHROOT_BIN_SSH} ${SSH_LOGIN}@${SSH_HOST} "${CHROOT_BIN_MKDIR} -p \"${backupFolder}\""  1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
#					return_status=${?};
#
#				else
#					BACKUP_TO="${SSH_LOGIN}@${SSH_HOST}:\"${SSH_BACKUP_TO[$i]}\"";
#					# Création du dossier sur l'host distance
#					backupFolder="${SSH_BACKUP_TO[$i]}";
#					${CHROOT_BIN_SSH} ${SSH_LOGIN}@${SSH_HOST} "${CHROOT_BIN_MKDIR} -p \"${backupFolder}\""  1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
#					return_status=${?};
#				fi
#
#				if [ ${return_status} != 0 ]
#				then
#					desactivation_module "${MODULE}" >> ${VAR_LOG_NAME_UNIV} >> ${VAR_LOG_NAME_UNIV_err}
#					status 1 "BACKUP_FROM_OVER_SSH ==> Probleme de creation du dossier distant, veuillez le creer manuellement < mkdir ${backupFolder} >" >> ${VAR_LOG_NAME_UNIV_err}
#				else
#					status ${return_status} "Creation du dossier des elements supprimes sur l'host distant" 1>> ${VAR_LOG_NAME_UNIV}
#				fi
#				EXLU_INCLU="${EXLU_INCLU} --exclude=${BACKUP_DELETE_FILES_FOLDER_NAME_ssh}";
#			fi
##############################################################
##############################################################

			if [ "${!MODULE}" == "TRUE" ]
			then
				if [ "${BACKUP_DELETE_FILES}" == "TRUE" ]; then OPTION_BACKUP_DELETE_FILES="--delete --backup --backup-dir=${VAR_DELETE_FILE}/${NON_DOSSIER}";	fi;

				OPTIONS="${OPTION_RSYNC} ${OPTION_BWLIMIT} ${OPTION_SIMULATION} ${OPTION_CHECKSUM} ${SSH_RSYNC_OPTION} ${OPTION_BACKUP_DELETE_FILES} ${OPTION_DELETE_EXCLUDED} ${EXLU_INCLU} ${EXLU_INCLU_mount}"
				OPTIONS="${OPTION_RSYNC} ${OPTION_BWLIMIT} ${OPTION_SIMULATION} ${OPTION_CHECKSUM} ${SSH_RSYNC_OPTION}"

##############################################################
######## LANCEMENT RSYNC ########
##############################################################

#				if (! ${CHROOT_RSYNC} ${OPTIONS} "${BACKUP_SOURCE}" "${BACKUP_DESTINATION}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err})
#				then
#					infoErreur_RSYNC="!!!! --> Probleme avec Rsycn, verifiez la configuration <-- !!!!";
#					DEBUG_RSYNC="TRUE";
#					#desactivation_module "${MODULE}" >> ${VAR_LOG_NAME_UNIV} >> ${VAR_LOG_NAME_UNIV_err}
#				fi
				
##############################################################
##############################################################

				if [ "${DEBUG_RSYNC}" == "TRUE" ]
				then
					br ${VAR_LOG_NAME_UNIV}
					status 5 "----------- DEBUG RSYNC -----------" >> ${VAR_LOG_NAME_UNIV}
					br ${VAR_LOG_NAME_UNIV};
					if [ ! -z "${infoErreur_RSYNC}" ]; then status 1 "${infoErreur_RSYNC}" >> ${VAR_LOG_NAME_UNIV}; br ${VAR_LOG_NAME_UNIV}; fi
					
					echo ${CHROOT_RSYNC} ${OPTIONS} ${BACKUP_SOURCE} "${BACKUP_DESTINATION}"  1>> ${VAR_LOG_NAME_UNIV}
					
					br ${VAR_LOG_NAME_UNIV};
					status 5 " ---------- DEBUG RSYNC -----------" >> ${VAR_LOG_NAME_UNIV}
					br ${VAR_LOG_NAME_UNIV}
				fi
				br ${VAR_LOG_NAME_UNIV};
			fi
			error_OP=$((error_OP+error_count_module))
			let i++;
		done
	let i_to++;
	done
fi

init_fin_session ${VAR_LOG_NAME_UNIV_err} ${VAR_LOG_NAME_UNIV} ${VAR_LOG_NAME} 1>> "${VAR_LOG_NAME}" 2>&1
# FIN
if ( test -f "${VAR_CHROOT_SESSION}/mount_error_new.log" )
then
	if (cat "${VAR_CHROOT_SESSION}/mount_error_new.log" |sed '/^$/d' |wc -l); then supprime_element "${VAR_CHROOT_SESSION}/mount_error_new.log"; fi
fi
	
#if [ ! -z "${BACKUP_FROM_SSH}" ]
#then
#		BACKUP_FROM=(${BACKUP_FROM_SSH[*]});
#		BACKUP_FROM_SSH=;
#		BACKUP_FROM_SSH_status='TRUE';
#		titreLogBis="over SSH";
#		autoload_conf "${VAR_BCK_CHROOT}/modules/${MODULE_lower}.sh" || status 3 "Probleme d'execution du fichier < ${VAR_BCK_CHROOT}/modules/${MODULE_lower}.sh >" ;
#else
#
#
#fi
