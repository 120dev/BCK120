# - > Permet d'interrompre le backup avant la fin du traitement
KILLBCK ()
{
	VAR_LOG_NAME_KILL="${VAR_LOG_FINAL}/${MINUTES}-${JOUR}-${BCK_NAME}--KILL.log";
	
	status 0 "Interruption du backup en cours ...."
	echo "deplacement_fichier_log "${VAR_LOG_NAME}" ${VAR_LOG_NAME_KILL}";
	deplacement_fichier_log "${VAR_LOG_NAME}" ${VAR_LOG_NAME_KILL}   ;
	VAR_LOG_NAME=${VAR_LOG_NAME_KILL}

#	SQL="FALSE"
#	RSYNC="FALSE"
#	EXTRA="FALSE"

	# - >Permet d'assurer que la fonction 'KILLBCK' s'execute correctement !!!
	trap '' 2

	status 1 "
	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	!!!!!                                                       !!!!!
	!!!!! /!\ NE PAS INTERROMPRE LA POCEDURE D'INTERRUPTION /!\ !!!!!
	!!!!!                                                       !!!!!
	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> "${VAR_LOG_NAME}";

	if [ "${SQL}" == "TRUE" ] && [ "${METHODE_2}" == "TRUE" ] && [ "${STOPSQL}" == "TRUE" ]
	then
		br;

		${SQL_PATH_INIT} restart >> "${VAR_LOG_NAME}";
		returnLevel="${?}";
		status ${returnLevel} "Reboot du Serveur SQL" >> "${VAR_LOG_NAME}";
		echo "
		!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		!! Reboot du Serveur Mysql en cours .....                   !!!!!
		!!  VERIFIEZ QUE LE SERVEUR MYSQL EST EN FONCTIONNEMENT     !!!!!
		!!       - > ${SQL_PATH_INIT} restart  < -                !!!!!
		!!       - > ${SQL_PATH_INIT} status  < -                 !!!!!
		!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " >> "${VAR_LOG_NAME}";
		br;

		${SQL_PATH_INIT} status >> "${VAR_LOG_NAME}";
		status ${?} "Status du server SQL"  >> "${VAR_LOG_NAME}";
	fi

	if [ "${NOTIF_MAIL}" != "FALSE" ]
	then
		NOTIF_MAIL='KILL'
		autoload_conf "${VAR_BCK_CHROOT}/modules/notification.sh"
	fi
	br;
	supprime_element ${PID_BCK}
	status 0 "Suppression du fichier PID"
	status 4 "FIN de l'interruption du backup !!" >> "${VAR_LOG_NAME}"

	showLog  "${VAR_LOG_NAME}";
	nettoyage_session
	trap 2
	sleep 3
	kill -9 $$
}