# - > Permet d'envoyer un mail
# - > ARG@ mailLog "${VAR_LOG_NAME}" "${MAIL_TO}" "${MAIL_SUJET}" "${COMPRESSION_PJ}"

mailLog()
{
	
	init_ErrorMail=0;
	#	echo "
	#	1. $1
	#	2.$2
	#	3. $3
	#	";
	if [ -z "${2}" ]; then status 1 "fct 'mailLog' Pour que la notification par mail soit effective, vous devez saisir une adresse email valide !!!" >> "${VAR_LOG_NAME}"; let init_ErrorMail++; fi
	if [ ! -f "${1}" ]; then status 1 "fct 'mailLog' Probleme pour trouver le fichier log";  let init_ErrorMail++; fi;
	
	if [ "${init_ErrorMail}" -eq 0 ]
	then
	
		if [ "${PIECE_JOINTE_LOG}" == "TRUE" ]
		then
			# Avec PJ
			
			NOM_FICHIER_LOG=`${CHROOT_BIN_BASENAME} "${1}"`
			to_dirname=`${CHROOT_BIN_DIRNAME} "${1}"`
			#${CHROOT_BIN_CP} "${1}" "${VAR_CHROOT_SESSION}"
			
#			echo "
#			NOM_FICHIER_LOG=`${CHROOT_BIN_BASENAME} "${1}"` 
#			to_dirname=`${CHROOT_BIN_DIRNAME} ${1}`
#			${CHROOT_BIN_CP} ${1} ${VAR_CHROOT_SESSION}
#			";
			
			#cd "${VAR_CHROOT_SESSION}"
			
			if [ "${COMPRESSION_PJ}" == "TRUE" ]
			then
				NOM_FICHIER_LOG="$NOM_FICHIER_LOG.tar.gz"
				${CHROOT_BIN_TAR} cfz "${NOM_FICHIER_LOG}" "$to_basename"
				outils_bck "test_ecriture" "${NOM_FICHIER_LOG}"
			fi
			
			
			${CHROOT_BIN_MUTT} -s "${3}" -a "${1}" -m text/html ${2} < "${VAR_CHROOT_SESSION}/body_mail.txt"
			return_mail=${?};
			
			if [ "${DEBUG_NOTIF_MAIL}" == "TRUE" ]
			then
				status 5 " ---------- DEBUG NOTIF_MAIL AVEC PJ -----------"
				status 6 "${CHROOT_BIN_MUTT} -s  \"${3}\" -a ${NOM_FICHIER_LOG} -m text/html ${2} < ${VAR_CHROOT_SESSION}/body_mail.txt"
				status 5 " ---------- DEBUG NOTIF_MAIL AVEC PJ -----------"
			fi
		
		else
		
			# SANS PJ
			
			${CHROOT_BIN_MAIL} "${2}" -s "${3}" < "${1}"
			return_mail=${?}
			if [ "${DEBUG_NOTIF_MAIL}" == "TRUE" ]
			then
				br
				status 5 " ---------- DEBUG NOTIF_MAIL SANS PJ -----------"
				status 6 "${CHROOT_BIN_MAIL} ${2} -s ${3} < ${1}" >> ${VAR_LOG_NAME_UNIV}
				status 5 " ---------- DEBUG NOTIF_MAIL SANS PJ -----------"
				br
			fi
			
	 fi
			echo
			status ${return_mail} "Envoi du mail au destinataire : ${2}";
			if [ ${return_mail} = 0 ]; then supprime_element "${VAR_CHROOT_SESSION}/body_mail.txt";fi
			status 0 "Sujet du Mail : ${3}";
			echo
	
	fi
}