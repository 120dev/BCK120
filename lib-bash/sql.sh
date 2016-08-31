# - > Permet d'effectuer des operations MySQL (stop, start, restart, test_connexion)
# - > ARG@ (TYPE SQL_PATH_INIT SQL_LOGIN SQL_PASSWORD)
Mysql ()
{
	if [ ${1} != "" ]
	then
		if [ ${1} != 'testConnexion' ];
		then
			${SQL_PATH_INIT} ${1} 
			return ${?}
		else
			${CHROOT_MYSQLADMIN} ${2} status
			return ${?}
		fi
	else
	 SQL="FALSE";
	 status 1 "fct 'Mysql' Parametres manquants !! P1(${1}) P2(${2})"
	 return 1
	fi
}

commun_op_mysqldump ()
{
	${CHROOT_MYSQLDUMP} ${OPTION_MYSQLDUMP} ${DB_MYSQLDUMP} ${IDENTIFICATION_MYSQL} >> "${DESTINATION_DUMP}" ; return_mysql_dump=${?}
	NOM_FICHIER_out="${DESTINATION_DUMP}";
	
	if [ "${DEBUG_SQL}" == "TRUE" ]
	then
		if [ ${SHOW_PASSWORD_LOG} == 'TRUE' ]; then IDENTIFICATION_MYSQL_for_log="${IDENTIFICATION_MYSQL}";else IDENTIFICATION_MYSQL_for_log="${IDENTIFICATION_MYSQL_NOPASSWORD}"; fi;
		
		br ${VAR_LOG_NAME_UNIV}
		status 5 "----------- DEBUG MYSQL METHODE 1-----------"
		status 5 "OPTION_MYSQLDUMP = $OPTION_MYSQLDUMP";
		status 5 "DB_MYSQLDUMP = $DB_MYSQLDUMP";
		status 5 "IDENTIFICATION_MYSQL = $IDENTIFICATION_MYSQL_for_log";
		status 5 "DESTINATION_DUMP = $DESTINATION_DUMP";
		status 5 "----------- DEBUG MYSQL -----------"
		br ${VAR_LOG_NAME_UNIV}
		
		status 6 "${CHROOT_MYSQLDUMP} ${OPTION_MYSQLDUMP} ${DB_MYSQLDUMP} ${IDENTIFICATION_MYSQL_for_log} >> ${DESTINATION_DUMP}" ;
	fi
		
	if [ ${return_mysql_dump} != 0 ]
	then
		return_mysql_dump=1; supprime_element "${DESTINATION_DUMP}"; return_filesize='';
		status ${return_mysql_dump} "${DB} --> ${DESTINATION_DUMP}"
	else
		filesize "${DESTINATION_DUMP}" && return_filesize="(${return_filesize})";
		status ${return_mysql_dump} "${DB} --> ${DESTINATION_DUMP} ${return_filesize}"
		
		if [ ${COMPRESS} == "TRUE" ]
		then
			if [ ${COMPRESSION_METHODE_1} == "TRUE" ]
			then 
				compression_format "${FORMAT_COMPRESSION_SQL}" "${DESTINATION_DUMP}" ;
				NOM_FICHIER_out="${NOM_FICHIER_COMPRESS}";
			fi
		fi
		
		if [ "${CREATION_CHECKSUM}" == "TRUE" ] && [ "${SQL_DUMP_COMMUN}" == "FALSE" ]
		then
			create_checksum "${SQL_DOSSIER_METHODE_1}" "${NOM_FICHIER_out}" "${CHECKSUM_FORMAT}" "${OPTION_CHECKSUM}" "${CHECKSUM_COMPRESSION}" "${FORMAT_CHECKSUM_COMPRESSION}" 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} || let error_count_module++
		fi
		br ${VAR_LOG_NAME_UNIV}
	fi
}
