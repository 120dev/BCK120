##########################################################################################
#		## EXTRAS ##
##########################################################################################
MODULE="EXTRA";

## ------------ Initialisation ---------------- ##
autoload_conf "${VAR_BCK_CHROOT}/init/init_${MODULE_lower}.sh";
## ------------ fin Initialisation ------------ ##
	
if [ "${!MODULE}" == "TRUE" ]
then

	i=0
	while [ $i -lt ${#array_extra[*]} ]
	do
		SOURCE="${array_extra[$i]}";
		if [ ! -z "${SOURCE}" ] && [ -e "${SOURCE}" ]
		then
			SOURCE_FICHIER=`${CHROOT_BIN_BASENAME} "${SOURCE}"`;
			NOM_DESTINATION="${SOURCE_FICHIER}";
			PATH_DESTINATION="${VAR_DEST_MODULE}/${NOM_DESTINATION}";

			if [ "${DEBUG_EXTRA}" == "TRUE" ]
			then
				br ${VAR_LOG_NAME_UNIV}
				status 5 " ---------- DEBUG EXTRA -----------" >> ${VAR_LOG_NAME_UNIV}
				status 6 "${CHROOT_BIN_CP} -fr ${SOURCE} ${PATH_DESTINATION}" >> ${VAR_LOG_NAME_UNIV}
				status 5 " ---------- DEBUG EXTRA -----------" >> ${VAR_LOG_NAME_UNIV}
				br ${VAR_LOG_NAME_UNIV}
			fi

			${CHROOT_BIN_CP} -fr "${SOURCE}" "${PATH_DESTINATION}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}

			if [ ${?} -eq 0 ]
			then
				filesize "${PATH_DESTINATION}" || let error_count_module++
				outils_bck "test_lecture" "${PATH_DESTINATION}" || let error_count_module++
				return_test_lecture=${?}

				status ${return_test_lecture} "Sauvegarde de '${SOURCE} (${return_filesize})'" >> ${VAR_LOG_NAME_UNIV};
				NOM_FICHIER_out=`${CHROOT_BIN_BASENAME} "${SOURCE}"`;
				
				
				if [ "${COMPRESSION_EXTRA}" == "TRUE" ] && [ "${EXTRA_COMPRESSION_COMMUN}" == "FALSE" ]
				then
					compression_fast "${FORMAT_COMPRESSION_EXTRA}" "${PATH_DESTINATION}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} || let error_count_module++
					NOM_FICHIER_out="${NOM_FICHIER_COMPRESS}";
				fi

				if [ "${CREATION_CHECKSUM}" == "TRUE" ] &&  [ "${COMPRESSION_EXTRA}" == "TRUE" ]
				then
					create_checksum "${VAR_DEST_MODULE}" "${NOM_FICHIER_out}" "${CHECKSUM_COMPRESSION}" "${FORMAT_CHECKSUM_COMPRESSION}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} || let error_count_module++
				fi
		  fi
		 fi
		 br ${VAR_LOG_NAME_UNIV}
		let i++;
	done
	if [ "${COMPRESSION_EXTRA}" == "TRUE" ] && [ "${EXTRA_COMPRESSION_COMMUN}" == "TRUE" ] && [ "${error_count_module}" == 0 ]
	then
		compression_fast "${FORMAT_COMPRESSION_EXTRA}" "${VAR_DEST_MODULE}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} || let error_count_module++
		NOM_FICHIER_out="${NOM_FICHIER_COMPRESS}";
	fi

	if [ "${CREATION_CHECKSUM}" == "TRUE" ]
	then
		VAR_DEST_MODULE_BASENAME=`${CHROOT_BIN_BASENAME} "${VAR_DEST_MODULE}"`;
		VAR_DEST_MODULE_DIRNAME=`${CHROOT_BIN_DIRNAME} "${VAR_DEST_MODULE}"`;
		
		if [ "${EXTRA_COMPRESSION_COMMUN}" == "FALSE" ]
		then
			PWD_="${VAR_DEST_MODULE_DIRNAME}"
			NOM_FICHIER_out="${VAR_DEST_MODULE_BASENAME}";
		else
			PWD_="${VAR_DEST_MODULE_DIRNAME}"
		fi
	
		create_checksum "${PWD_}" "${NOM_FICHIER_out}" "${CHECKSUM_COMPRESSION}" "${FORMAT_CHECKSUM_COMPRESSION}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} || let error_count_module++
	fi
	br ${VAR_LOG_NAME_UNIV}

fi
error_OP=$((error_OP+error_count_module))
init_fin_session ${VAR_LOG_NAME_UNIV_err} ${VAR_LOG_NAME_UNIV} "${VAR_LOG_NAME}" 1>> "${VAR_LOG_NAME}" 2>&1