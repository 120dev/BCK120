## ------------ Initialisation ------------ ##
autoload_conf "${VAR_BCK_CHROOT}/init/init_module.sh"
## ------------ fin initialisation ------------ ##

if [ "${SQL}" == "TRUE" ]
then

######################################################################
# -- > METHODE_1 -- > Création d'un ficher DUMP (.sql) personnalisé. #
######################################################################

	if [ "${METHODE_1}" == "TRUE" ]
	then
		# On test les variables OBLIGATOIRES pour le bon fonctionnement du module.
#		if_empty "${SQL_DATABASE}" >> ${VAR_LOG_NAME_UNIV_err} || METHODE_1="FALSE";
#		if_empty "${SQL_LOGIN}" >> ${VAR_LOG_NAME_UNIV_err} || METHODE_1="FALSE";
#		if_empty "${OPTION_MYSQLDUMP}" >> ${VAR_LOG_NAME_UNIV_err} || METHODE_1="FALSE";

		# On test les variables OBLIGATOIRES pour le bon fonctionnement du module.
		liste_variable_m1=(SQL_DATABASE SQL_LOGIN OPTION_MYSQLDUMP);
		i=0;
		while [ $i -lt ${#liste_variable_m1[*]} ];
		do
			if_empty ${liste_variable_m1[$i]} >> ${VAR_LOG_NAME_UNIV_err} || METHODE_1="FALSE";
			let i++
		done
		
		# - > SI non definis alors on applique les parametres par defaut.
		if [ -z "${SQL_HOST}" ]; then SQL_HOST="localhost"; fi
		if [ -z "${SQL_DUMP_COMMUN}" ]; then SQL_DUMP_COMMUN="FALSE"; fi
		if [ -z "${COMPRESSION_METHODE_1}" ]; then COMPRESSION_METHODE_1="TRUE"; fi
		if [ -z "${FORMAT_COMPRESSION_SQL}" ]; then FORMAT_COMPRESSION_SQL="TARGZ"; fi
		if [ -z "${OPTION_MYSQLDUMP}" ]; then OPTION_MYSQLDUMP="--opt --compress --extended-insert --complete-insert --port=3306"; fi

		# - > On test l'existance des fichiers binaires de MYSQL
		liste_binaire=('mysqldump' 'mysqlcheck' 'mysqlshow'  'mysqladmin')
		i=0;
		while [ $i -lt ${#liste_binaire[*]} ];
		do
			test_fichier_binaire ${liste_binaire[${i}]} 2>> ${VAR_LOG_NAME_UNIV_err} 2>&1 || let error_count_init++
			if [ ${?} != 0 ]
			then
				METHODE_1="FALSE";
				creation_sous_titre_log "Le module < SQL METHODE_1 >, est desactive !!" >> ${VAR_LOG_NAME_UNIV} 2>&1 || let error_count_init++
			fi
			let i++
		done

		if [ "${METHODE_1}" == "TRUE" ]
		then
			# - > Path des fichiers binaire de mysql
			CHROOT_MYSQLDUMP=`which mysqldump` || let error_count_init++
			CHROOT_MYSQLCHECK=`which mysqlcheck` || let error_count_init++
			CHROOT_MYSQLSHOW=`which mysqlshow` || let error_count_init++
			CHROOT_MYSQLADMIN=`which mysqladmin` || let error_count_init++
		fi
	fi

	# - > Recapitulatif des parametres SQL (ne pas modifier)
	arrayParam="${SQL_PATH_INIT} ${SQL_LOGIN} ${SQL_PASSWORD}";

	# - > Creation des repertoire pour la sauvegarde de MYSQl
	CHROOT_SQL="${VAR_ROOT}/SQL";
	creation_dossier ${CHROOT_SQL} 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} || let error_count_init++

	VAR_SQL="${CHROOT_SQL}";

	creation_dossier ${VAR_SQL} 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} || let error_count_init++
	if [ ${?} != 0 ];then SQL="FALSE"; fi
fi

if [ "${SQL}" == "TRUE" ]
then
	if [ "${METHODE_1}" == "TRUE" ]
	then

		SQL_DOSSIER_METHODE_1="${VAR_SQL}/METHODE_1/${COMMUN_SUFIX_PATH}";
		creation_dossier ${SQL_DOSSIER_METHODE_1} 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} || let error_count_init++

		if [ ${?} == 0 ]
		then
			if [ "${SQL_DUMP_COMMUN}" == "TRUE" ]; then VAR_SQL_DUMP_COMMUN="${MINUTES}-COMMUN.sql"; fi;
		else
			METHODE_1="FALSE"
		fi

		if [ "${SQL_PASSWORD}" != "" ]
		then
			ori_SQL_PASSWORD="${SQL_PASSWORD}"
			SQL_PASSWORD="-p${SQL_PASSWORD}";
			mysqlshowpassword="--password=${ori_SQL_PASSWORD}";
		fi

		IDENTIFICATION_MYSQL="-h ${SQL_HOST} -u ${SQL_LOGIN} ${SQL_PASSWORD}"
		IDENTIFICATION_MYSQL_NOPASSWORD="-h ${SQL_HOST} -u ${SQL_LOGIN} -p****"

		################################
		# -- > Test de Connexion MySql
		################################

		Mysql "testConnexion" "${IDENTIFICATION_MYSQL}" 1> /dev/null 2>> ${VAR_LOG_NAME_UNIV_err} || let error_count_init++
		if (test ${?} -ne 0)
		then
			METHODE_1="FALSE";

			br ${VAR_LOG_NAME_UNIV_err};
			status 1 "Probleme de connexion MySQL, verifiez vos identifiants" >> ${VAR_LOG_NAME_UNIV_err};

			if [ ${SHOW_PASSWORD_LOG} == 'TRUE' ]
			then
				status 4 "< $SHOW_ERR ${CHROOT_MYSQLADMIN}  ${IDENTIFICATION_MYSQL} status >" >> ${VAR_LOG_NAME_UNIV_err};
			else
				status 4 "< $SHOW_ERR ${CHROOT_MYSQLADMIN}  ${IDENTIFICATION_MYSQL_NOPASSWORD} status >" >> ${VAR_LOG_NAME_UNIV_err};
			fi

			####### !!!!!!!!!! ATTENTION CELA IMPLIQUE QUE LA METHODE 2 SOIT ACTIVE !!!!!!
			(${CHROOT_BIN_CAT} ${VAR_LOG_NAME_UNIV_err} | grep mysql.sock) &>/dev/null
			if [ ${?} == 0 ]
			then
				br ${VAR_LOG_NAME_UNIV_err};
				echo "Essayez de faire un reboot de mysql " >> ${VAR_LOG_NAME_UNIV_err};
				echo "!! - > ${SQL_PATH_INIT} restart  < - !! " >> ${VAR_LOG_NAME_UNIV_err};
				echo "!! - > ${SQL_PATH_INIT} status   < - !! " >> ${VAR_LOG_NAME_UNIV_err};
				br ${VAR_LOG_NAME_UNIV_err};
				if [ "${STOPSQL}" == "TRUE" ]
				then
					${SQL_PATH_INIT} restart >> ${VAR_LOG_NAME_UNIV_err} || let error_count_init++
					${SQL_PATH_INIT} status >>  ${VAR_LOG_NAME_UNIV_err} || let error_count_init++

					if [ ${?} == 0 ]; then METHODE_1="TRUE";fi
				fi
			fi
			####### !!!!!!!!!! ATTENTION CELA IMPLIQUE QUE LA METHODE 2 SOIT ACTIVE !!!!!!
		fi
	fi

############################################################
# - > METHODE_2 -- > Sauvegarde du dossier '/var/lib/mysql'#
############################################################

	if [ "${METHODE_2}" == "TRUE" ]
	then
		# - > On test l'existance des variables
		liste_variable_m1=(SQL_PATH_INIT PATH_LIB_SQL);
		i=0;
		while [ $i -lt ${#liste_variable_m1[*]} ];
		do
			if_empty ${liste_variable_m1[$i]} >> ${VAR_LOG_NAME_UNIV_err} || METHODE_2="FALSE";

			let i++
		done

		# - > SI non definis alors on applique les parametres par defaut.
		if [ -z ${STOPSQL} ]; then STOPSQL="FALSE"; fi
		if [ -z ${COMPRESSION_METHODE_2} ]; then COMPRESSION_METHODE_2="TRUE"; fi

		outils_bck "test_lecture" "${SQL_PATH_INIT}" >> ${VAR_LOG_NAME_UNIV_err} 2>&1 || let error_count_init++
		outils_bck "test_lecture" "${PATH_LIB_SQL}" >> ${VAR_LOG_NAME_UNIV_err} 2>&1 || METHODE_2="FALSE";
	fi

	if [ "${METHODE_2}" == "TRUE" ]
	then
		SQL_DOSSIER_METHODE_2="${VAR_SQL}/METHODE_2/${COMMUN_SUFIX_PATH}";
		creation_dossier ${SQL_DOSSIER_METHODE_2} 1>> ${VAR_LOG_NAME_UNIV} 2>> ${VAR_LOG_NAME_UNIV_err} || { METHODE_2="FALSE"; let error_count_init++; }
	fi
fi

if [ "${METHODE_1}" == "FALSE" ] && [ "${METHODE_2}" == "FALSE" ]
then
	br ${VAR_LOG_NAME_UNIV_err};
	status 4 "##################################" >> ${VAR_LOG_NAME_UNIV_err};
	status 4 "#                                #" >> ${VAR_LOG_NAME_UNIV_err};
	status 4 "# !! Aucun module SQL active  !! #" >> ${VAR_LOG_NAME_UNIV_err};
	status 4 "#                                #" >> ${VAR_LOG_NAME_UNIV_err};
	status 4 "##################################" >> ${VAR_LOG_NAME_UNIV_err};
fi


# FIN
autoload_conf "${VAR_BCK_CHROOT}/init/init_module_end.sh"
