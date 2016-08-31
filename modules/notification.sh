##########################################################################################
					## NOTIFICATION ##
#########################################################################################
CHROOT_BIN_MAIL=`/usr/bin/which mail` || NOTIF_MAIL="FALSE";

if [ -z "${COMPRESSION_PJ}" ]; then COMPRESSION_PJ="FALSE"; fi
if [ -z "${NOTIF_MAIL}" ]; then NOTIF_MAIL="FALSE"; fi
if [ -z "${MAIL_SUJET}" ]; then MAIL_SUJET="[BCK120] -> Rapport de la Sauvegarde ${BCK_NAME}"; fi

if [ "${NOTIF_MAIL}" == "ONLY_IF_ERROR" ]
then
	if [ "${error_OP}" -eq 0 ]
	then
		NOTIF_MAIL="FALSE";
	fi
fi
	
if [ "${NOTIF_MAIL}" != "FALSE" ]
then

	if [ "${PIECE_JOINTE_LOG}" == "TRUE" ]
	then
		if (! test_fichier_binaire mutt &>/dev/null)
		then
			PIECE_JOINTE_LOG="FALSE";
			test_fichier_binaire mutt >> "${VAR_LOG_NAME}" 
			status 4 "Desactivation de la notification avec piece jointe" >> "${VAR_LOG_NAME}"
		else
			CHROOT_BIN_MUTT=`/usr/bin/which mutt` 
		fi
	fi
	
	ERROR_CHECK="FALSE (${error_OP}) TRUE (${nbr_OP})";
	case "${NOTIF_MAIL}" in
#		"ONLY_IF_ERROR")
#				MAIL_SUJET="${MAIL_SUJET}";
#		;;
		"KILL")
			MAIL_SUJET="${MAIL_SUJET} | KILL !!";
		;;
		"ROTATION")
			MAIL_SUJET="${MAIL_SUJET} | ROTATION";
		;;
	esac
	MAIL_SUJET="${MAIL_SUJET} <> ${ERROR_CHECK}";
	mailLog "${VAR_LOG_NAME}" "${MAIL_TO}" "${MAIL_SUJET}" "${COMPRESSION_PJ}"
fi