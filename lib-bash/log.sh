# - > ARG@ (FROM TO)
deplacement_fichier_log ()
{
	if [ "${1}" != "" ] && [ "${2}" != "" ]
	then
		basename_dest=`dirname "${2}"`
		outils_bck "test_ecriture" "${basename_dest}" || status 3 "fct(deplacement_fichier_log) Probleme  ${basename_dest} > ";
		outils_bck "test_ecriture" "${1}" || status 3 "fct(deplacement_fichier_log) Probleme  ${1} > ";
		

		if [ "${1}" != "${2}" ]
		then
			${CHROOT_BIN_CP} -f "${1}" "${2}" || status 3 "fct(deplacement_fichier_log) Probleme de deplacement du fichier < ${1} > < ${2} > ";
			supprime_element "${1}"
		fi
		

		outils_bck "test_lecture" "${2}"

		if [ ${?} == 0 ]
		then
			if [ ${FULL_LOG} == "TRUE" ]; then status 0 "Creation de '${2}'"; fi
			return 0
		else
			if [ ${FULL_LOG} == "TRUE" ]; then status 3 "Creation de '${2}'"; fi
			return 1
		fi
	else
	 status 1 "fct 'deplacement_fichier_log' Parametres manquants !! P1(${1}) P2(${2})"
	 return 1
	fi
}

creation_fichier_log ()
{
	outils_bck test_lecture "${1}" &>/dev/null
	if [ ${?} = 1 ]
	then
		creation_dossier `${CHROOT_BIN_DIRNAME} "${1}"`

		${CHROOT_BIN_TOUCH} "${1}"
		return_CHROOT_BIN_TOUCH=${?}

		outils_bck test_lecture "${1}"
		return ${?};

	fi
}

creation_titre_log ()
{

	if [ "${1}" != '' ]
	then
		echo ' ';
		echo "- > ################## -- > ${1} <-- ##################";
		echo ' ';
	else
		status 1 "fct 'creation_titre_log' Parametre Manquant P1(${1})"
		return 1
	fi
}

creation_sous_titre_log ()
{

	if [ "${1}" != '' ]
	then
		echo ' ';
		echo "## -- > ${1}";
	else
		status 1 "fct 'creation_sous_titre_log' Parametre Manquant P1(${1})"
		return 1
	fi
}

# - > Permet d'afficher le log a la fin du traitement.
# - > ARG@ (FICHIER_LOG)
showLog()
{
	if [ "${1}" != "" ]
	then
		outils_bck "test_lecture" "${1}"
		if [ ${?} == 0 ]
		then
			if [ ${FULL_LOG} == "TRUE" ]; then echo "Affichage du log '"${VAR_LOG_NAME}"'"; echo ' '; fi;
			${CHROOT_BIN_CAT} "${1}";
		fi
	else
	 #status 1 "fct 'showLog' Parametres manquants !! P1(${1})"
	 return 1
	fi
}