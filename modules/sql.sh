##########################################################################################
#					  ## SQL ##
# - > Pour Sauvegarder MySQL, vous avez deux possibilites
# - > 1ere Methode -- > Creation d'un ficher DUMP (.sql) personnalise.
# - > 2nd Methodes -- > Sauvegarde du dossier '/var/lib/mysql'
##########################################################################################
MODULE="SQL";

if [ -z "${METHODE_1}" ]; then METHODE_1="FALSE"; fi
if [ -z "${METHODE_2}" ]; then METHODE_2="FALSE"; fi

## ------------ Initialisation ------------ ##
autoload_conf "${VAR_BCK_CHROOT}/init/init_${MODULE_lower}.sh" 
## ------------ fin Initialisation ------------ ##
	
if [ "${!MODULE}" == "TRUE" ]
then	
	status 4 "Sauvegarde MYSQL " >> ${VAR_LOG_NAME_UNIV} & br ${VAR_LOG_NAME_UNIV}
	
	if [ ${METHODE_1} == "TRUE" ]
	then		
		cd "${SQL_DOSSIER_METHODE_1}";
		creation_sous_titre_log "METHODE_1" >> ${VAR_LOG_NAME_UNIV}; br ${VAR_LOG_NAME_UNIV};
		
		br ${VAR_LOG_NAME_UNIV};
		status 4 "---------------------" >> ${VAR_LOG_NAME_UNIV};
		status 4 "Serveur : ${SQL_HOST}" >> ${VAR_LOG_NAME_UNIV};
		status 4 "Login : ${SQL_LOGIN}" >> ${VAR_LOG_NAME_UNIV};
		status 4 "DB : ${SQL_DATABASE}" >> ${VAR_LOG_NAME_UNIV};
		status 4 "Backup TO : '${SQL_DOSSIER_METHODE_1}' : " >> ${VAR_LOG_NAME_UNIV};
		status 4 "---------------------" >> ${VAR_LOG_NAME_UNIV};
		br ${VAR_LOG_NAME_UNIV};
		
		case ${SQL_DUMP_COMMUN} in
			TRUE)
				if [ "${SQL_DATABASE[0]}" == "all" ]
				then
						DB="--all-databases"; DB_MYSQLDUMP="${DB}"; DESTINATION_DUMP="${VAR_SQL_DUMP_COMMUN}"; COMPRESS="${COMPRESSION_METHODE_1}";
						commun_op_mysqldump 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err};
				else
					i=0
					while [ $i -lt ${#SQL_DATABASE[*]} ]
					do
						DB=${SQL_DATABASE[$i]}; DB_MYSQLDUMP="--database ${DB}"; DESTINATION_DUMP="${VAR_SQL_DUMP_COMMUN}"; COMPRESS="${COMPRESSION_METHODE_1}";
						commun_op_mysqldump 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err};
						let i++;
					done
				fi
		 ;;
		 FALSE)
				if [ "${SQL_DATABASE[0]}" == "all" ]
				then
					for i in `${CHROOT_MYSQLSHOW} ${IDENTIFICATION_MYSQL} | grep -v "Databases" | grep -v "+-" | ${CHROOT_BIN_AWK} '{print $2}'`
			  	do
					 	DB="$i"; DB_MYSQLDUMP="--database ${DB}"; DESTINATION_DUMP="${DB}.sql"; COMPRESS="${COMPRESSION_METHODE_1}";
						commun_op_mysqldump 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err};
		      done
		   else
				  i=0
				  while [ $i -lt ${#SQL_DATABASE[*]} ]
				  do
					  DB=${SQL_DATABASE[$i]}; DB_MYSQLDUMP="--database ${DB}"; DESTINATION_DUMP="${DB}.sql"; COMPRESS="${COMPRESSION_METHODE_1}";
						commun_op_mysqldump 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err};
					 let i++;
				  done
		   fi
		 ;;
		esac
		
		if [ "${SQL_DUMP_COMMUN}" == "TRUE" ]
		then
			create_checksum "${SQL_DOSSIER_METHODE_1}" "${NOM_FICHIER_out}" "${CHECKSUM_COMPRESSION}" "${FORMAT_CHECKSUM_COMPRESSION}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} || let error_count_module++
		fi
		infoSpace=`/usr/bin/du -sh ${SQL_DOSSIER_METHODE_1} | ${CHROOT_BIN_AWK} '{print $1}'`;
		status 4 "Taille de la sauvegarde : $infoSpace" 1>> ${VAR_LOG_NAME_UNIV}
	fi

	if [ ${METHODE_2} == "TRUE" ]
	then
		
		creation_sous_titre_log "METHODE_2" >> ${VAR_LOG_NAME_UNIV}; br ${VAR_LOG_NAME_UNIV};
		status 4 "Sauvegarde de < ${PATH_LIB_SQL} > dans < ${SQL_DOSSIER_METHODE_2} >" >> ${VAR_LOG_NAME_UNIV};
		status 4 "---------------------" >> ${VAR_LOG_NAME_UNIV}
		
		if [ ${STOPSQL} == "TRUE" ]
		then
			
			Mysql "stop" ${arrayParam[*]}  1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
			returnLevel=${?};
			status ${returnLevel} "Arrêt du Serveur SQL" >> ${VAR_LOG_NAME_UNIV};
			
			if (test ${returnLevel} -ne 0)
			then 
				Mysql "status" ${arrayParam[*]}  1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
			  if [ ${?} -ne 3 ]; then METHODE_2="TRUE"; fi;
				if [ ${DEBUG_SQL} == "TRUE" ]
				then
					br ${VAR_LOG_NAME_UNIV} 
					status 5 "----------- DEBUG MYSQL METHODE 2-----------" >> ${VAR_LOG_NAME_UNIV}
					status 6 "${arrayParam[*]} status" >> ${VAR_LOG_NAME_UNIV}
					status 5 "----------- DEBUG MYSQL -----------" >> ${VAR_LOG_NAME_UNIV}
				fi
			fi
			if [ ${DEBUG_SQL} == "TRUE" ]
			then
				br ${VAR_LOG_NAME_UNIV} 
				status 5 "----------- DEBUG MYSQL METHODE 2-----------" >> ${VAR_LOG_NAME_UNIV}
				status 6 "${arrayParam[*]} stop" >> ${VAR_LOG_NAME_UNIV}
				status 5 "----------- DEBUG MYSQL -----------" >> ${VAR_LOG_NAME_UNIV}
			fi
		fi

		if [ ${METHODE_2} == "TRUE" ]
		then
			${CHROOT_BIN_CP} -fR ${PATH_LIB_SQL} ${SQL_DOSSIER_METHODE_2} 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
			returnLevel=${?};
			status ${returnLevel} "Sauvegarde du dossier '${PATH_LIB_SQL}'" >> ${VAR_LOG_NAME_UNIV};			

			if [ ${DEBUG_SQL} == "TRUE" ]
			then
				br ${VAR_LOG_NAME_UNIV}
				status 5 "----------- DEBUG MYSQL METHODE 2-----------" >> ${VAR_LOG_NAME_UNIV}
				status 6 "${CHROOT_BIN_CP} -fR ${PATH_LIB_SQL} ${SQL_DOSSIER_METHODE_2}" >> ${VAR_LOG_NAME_UNIV}
				status 5 "----------- DEBUG MYSQL -----------" >> ${VAR_LOG_NAME_UNIV}
			fi			
			VAR_DEST_MODULE_BASENAME=`${CHROOT_BIN_BASENAME} "${SQL_DOSSIER_METHODE_2}"`;
			VAR_DEST_MODULE_DIRNAME=`${CHROOT_BIN_DIRNAME} "${SQL_DOSSIER_METHODE_2}"`;
			
			if [ ${COMPRESSION_METHODE_2} == "FALSE" ] && [ "${CREATION_CHECKSUM}" == "TRUE" ]
			then
				create_checksum "${VAR_DEST_MODULE_DIRNAME}" "${VAR_DEST_MODULE_BASENAME}" "${CHECKSUM_COMPRESSION}" "${FORMAT_CHECKSUM_COMPRESSION}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} || let error_count_module++
			fi

			if [ ${STOPSQL} == "TRUE" ]
			then
				Mysql "start" ${arrayParam[*]} 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
				returnLevel=${?};
				status ${returnLevel} "Lancement du Serveur SQL" >> ${VAR_LOG_NAME_UNIV};

				if [ ${returnLevel} != 0 ]
				then
					Mysql "restart" ${arrayParam[*]}  1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
					if [ ${DEBUG_SQL} == "TRUE" ]
					then					
						returnLevel=${?};
						status ${returnLevel} "Reboot du Serveur SQL" >> ${VAR_LOG_NAME_UNIV}
						status 5 "----------- DEBUG MYSQL METHODE 2-----------" >> ${VAR_LOG_NAME_UNIV}
						status 6 "${arrayParam[*]} restart" >> ${VAR_LOG_NAME_UNIV}
						status 5 "----------- DEBUG MYSQL -----------" >> ${VAR_LOG_NAME_UNIV}
					fi
				fi
				Mysql "status" ${arrayParam[*]}  1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err}
				returnLevel=${?};
				status ${returnLevel} "Status du server SQL" >> ${VAR_LOG_NAME_UNIV};

				if [ ${returnLevel} != 0 ]; then let error_OP++;	fi;
				if [ ${DEBUG_SQL} == "TRUE" ]
				then
					status 5 "----------- DEBUG MYSQL METHODE 2-----------" >> ${VAR_LOG_NAME_UNIV}
					status 6 "${arrayParam[*]} status" >> ${VAR_LOG_NAME_UNIV}
					status 6 "${arrayParam[*]} start" >> ${VAR_LOG_NAME_UNIV}
					status 5 "----------- DEBUG MYSQL -----------" >> ${VAR_LOG_NAME_UNIV}
			fi
		 fi

			if [ ${COMPRESSION_METHODE_2} == "TRUE" ]
			then
				compression ${FORMAT_COMPRESSION_SQL} ${SQL_DOSSIER_METHODE_2} >> ${VAR_LOG_NAME_UNIV}
				NOM_FICHIER_out="${NOM_FICHIER_COMPRESS}";
			fi
			
			if [ ${COMPRESSION_METHODE_2} == "TRUE" ] && [ "${CREATION_CHECKSUM}" == "TRUE" ]
			then
				create_checksum "${VAR_DEST_MODULE_DIRNAME}" "${NOM_FICHIER_out}" "${CHECKSUM_COMPRESSION}" "${FORMAT_CHECKSUM_COMPRESSION}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} || let error_count_module++
			fi

		fi
  fi
fi

# FIN
init_fin_session ${VAR_LOG_NAME_UNIV_err} ${VAR_LOG_NAME_UNIV} "${VAR_LOG_NAME}" 1>> "${VAR_LOG_NAME}" 2>&1
