##########################################################################################
#		## ROTATION ##
##########################################################################################
MODULE="ROTATION";

## ------------ Initialisation ---------------- ##
autoload_conf "${VAR_BCK_CHROOT}/init/init_${MODULE_lower}.sh"
## ------------ fin Initialisation ------------ ##

if [ "${!MODULE}" == "TRUE" ]
then
	status 4 "Recherche des ‘fichiers/dossiers’ datant de plus de < ${NBR_JOUR_ROTATION} > jours pour < ${TYPE_ROTATION} ${TYPE_ARCHIVAGE} >" >> ${VAR_LOG_NAME_UNIV} & br ${VAR_LOG_NAME_UNIV}
	i=0;
	while [ $i -lt ${#array_Rotation[*]} ]; 
	do
		ARRAY_DOSSIER_ROTATION="${array_Rotation[$i]}";
		if [ "${ARRAY_DOSSIER_ROTATION}" == "RSYNC" ]; then ARRAY_DOSSIER_ROTATION="backup-files_delete"; fi;
		
		if [ "${ARRAY_DOSSIER_ROTATION}" == "SQL_METHODE_1" ]; then ARRAY_DOSSIER_ROTATION="SQL/METHODE_1"; fi;
		if [ "${ARRAY_DOSSIER_ROTATION}" == "SQL_METHODE_2" ]; then ARRAY_DOSSIER_ROTATION="SQL/METHODE_2"; fi;

		DOSSIER="${VAR_ROOT}/${ARRAY_DOSSIER_ROTATION}/"
		if [ -d "${DOSSIER}" ]
		then
			br ${VAR_LOG_NAME_UNIV};
			status 4 "Recherche dans : '${DOSSIER}'" >> ${VAR_LOG_NAME_UNIV};
			status 4 "-----" >> ${VAR_LOG_NAME_UNIV};

			if [ "${DEBUG_ROTATION}" == "TRUE" ]
			then
				br ${VAR_LOG_NAME_UNIV}
				status 4 "----------- DEBUG ROTATION -----------" >> ${VAR_LOG_NAME_UNIV}
				status 4 "find ${DOSSIER} -noleaf -maxdepth ${MAXDEPTH} -ctime +${NBR_JOUR_ROTATION}" >> ${VAR_LOG_NAME_UNIV}
				status 4 " ---------- DEBUG ROTATION -----------" >> ${VAR_LOG_NAME_UNIV}
				br ${VAR_LOG_NAME_UNIV}
			fi

			 for FROM_Rotation in `find "${DOSSIER}" -noleaf -maxdepth ${MAXDEPTH} -ctime +${NBR_JOUR_ROTATION}`
			 do
			 	outils_bck "test_ecriture" "${FROM_Rotation}" >> ${VAR_LOG_NAME_UNIV}
			 	return_test_ecriture=${?};
			 	
				NOT_CHROOT_ROTATION="${FROM_Rotation#*$ARRAY_DOSSIER_ROTATION/}"
				if [ ! -z "${NOT_CHROOT_ROTATION}" ] && [ ${return_test_ecriture} -eq 0 ]
				then
					TO_Rotation=$DOSSIER_ROTATION_ARCHIVAGE/$ARRAY_DOSSIER_ROTATION/${FROM_Rotation#*$ARRAY_DOSSIER_ROTATION/};
					TO_FROM_CP=`${CHROOT_BIN_DIRNAME} $TO_Rotation`
					#echo "FROM_Rotation = ${FROM_Rotation}" >> ${VAR_LOG_NAME_UNIV}
					#echo "TO_Rotation = ${TO_Rotation}" >> ${VAR_LOG_NAME_UNIV}

					count_str_string "${NOT_CHROOT_ROTATION}" "/";
					return_count_str_string="${?}";
					#echo "return_count_str_string == $return_count_str_string" >> ${VAR_LOG_NAME_UNIV}
					if [ "${return_count_str_string}" -eq ${MAXDEPTH} ]
					then
						if [ "${COMPRESSION_ROTATION}" == "TRUE" ]
						then
					  	  compression_format "${FORMAT_COMPRESSION_ROTATION}" "${FROM_Rotation}" "${TO_Rotation}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
								return_compression=$?;
								if [ ${return_compression} != 0 ]; then ROTATION_ERROR=$((${return_compression})); fi
								let ROTATION_FICHIER++;
						else
							case "${TYPE_ROTATION}"  in
								ARCHIVAGE)
									creation_dossier "${TO_FROM_CP}"
									echo "${CHROOT_BIN_MV} -f ${FROM_Rotation} ${TO_FROM_CP}/" 1>> ${VAR_LOG_NAME_UNIV}

									case "${TYPE_ARCHIVAGE}" in
										"COPIE")
											${CHROOT_BIN_CP} -fr "${FROM_Rotation}" "${TO_FROM_CP}/" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} || let error_count_module++
										;;
										"MOVE")
											${CHROOT_BIN_MV} -f "${FROM_Rotation}" "${TO_FROM_CP}/" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} || let error_count_module++
										;;
									esac
									return_mv=${?};

									status ${return_mv}  "Archivage de '${NOT_CHROOT_ROTATION}'" >> ${VAR_LOG_NAME_UNIV};
									if [ ${return_mv} == 0 ]
									then
										let ROTATION_FICHIER++;
									fi
									outils_bck "test_ecriture" ${TO_Rotation} >> ${VAR_LOG_NAME_UNIV}
								;;
								SUPPRESSION)
									supprime_element ${FROM_Rotation} 2>&1 >> ${VAR_LOG_NAME_UNIV} ;
									status $? "Suppression de '${NOT_CHROOT_ROTATION}'" >> ${VAR_LOG_NAME_UNIV};
									let ROTATION_FICHIER++;
							  ;;
							 esac
						fi
					fi
				fi
			 done
		fi
		let i++;
	done
fi

# FIN
if (test ${ROTATION_FICHIER} -ne 0);
then
	prefix_log=""${VAR_LOG_NAME}""
	IF_ROTATION="ROTATION-"
	br ${VAR_LOG_NAME_UNIV};
	status 4 "-----" >> ${VAR_LOG_NAME_UNIV};
	status 4 "Elements trouves : < ${ROTATION_FICHIER} >" >> ${VAR_LOG_NAME_UNIV};

	if [ "$NOTIF_MAIL" != "FALSE" ]; then NOTIF_MAIL='ROTATION'; fi;

else
	br ${VAR_LOG_NAME_UNIV};
	creation_sous_titre_log "Aucun 'Fichier/Dossier' trouve." >> ${VAR_LOG_NAME_UNIV};
fi

error_OP=$((error_OP+error_count_module))
init_fin_session ${VAR_LOG_NAME_UNIV_err} ${VAR_LOG_NAME_UNIV} "${VAR_LOG_NAME}" 1>> "${VAR_LOG_NAME}" 2>&1
