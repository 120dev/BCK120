## ------------ Initialisation ------------ ##
autoload_conf "${VAR_BCK_CHROOT}/init/init_module.sh"
## ------------ fin initialisation ------------ ##
if [ "${!MODULE}" == "TRUE" ]
then

	# - > SI non definis ALORS on applique les parametres par defaut.
	if [ -z "${FORMAT_COMPRESSION_EXTRA}" ]; then FORMAT_COMPRESSION_EXTRA="TARGZ"; fi
	if [ -z "${COMPRESSION_EXTRA}" ]; then COMPRESSION_EXTRA="FALSE"; fi
	if [ -z "${EXTRA_COMPRESSION_COMMUN}" ]; then EXTRA_COMPRESSION_COMMUN="FALSE"; fi
	
	if [ "${CREATION_CHECKSUM}" == "TRUE" ]
	then
		if [ -z "${CHECKSUM_FORMAT}" ]; then CHECKSUM_FORMAT="sfv"; fi
		if [ -z "${FORMAT_CHECKSUM_COMPRESSION}" ]; then FORMAT_CHECKSUM_COMPRESSION="TARGZ"; fi
		if [ -z "${CHECKSUM_COMPRESSION}" ]; then CHECKSUM_COMPRESSION="FALSE"; fi
		if [ -z "${OPTION_CHECKSUM}" ]; then OPTION_CHECKSUM="-Crr"; fi
		if [ -z "${CHECKSUM_RECURSIF}" ]; then CHECKSUM_RECURSIF="TRUE"; fi
	fi

	VAR_DEST_MODULE="${VAR_ROOT}/${MODULE}/${COMMUN_SUFIX_PATH}";
	creation_dossier "$VAR_DEST_MODULE" 1>> ${VAR_LOG_NAME_UNIV_err} 2>&1 || desactivation_module "${MODULE}" >> ${VAR_LOG_NAME_UNIV}
	##########################################################################################

	# On test les variables OBLIGATOIRES pour le bon fonctionnement du module.
	liste_variable=(array_extra);
	i=0;
	while [ $i -lt ${#liste_variable[*]} ];
	do
		if_empty ${liste_variable[$i]} >> ${VAR_LOG_NAME_UNIV_err} || desactivation_module "${MODULE}"
		let i++
	done
fi

i_check=0;
i_count_true_array=0
while [ $i_check -lt ${#array_extra[*]} ];
do
	SOURCE="${array_extra[$i_check]}";
	
	supprime_dernier_slash "${SOURCE}"; SOURCE="${return_supprime_dernier_slash}"
	if [ ! -e "${SOURCE}" ]
	then
		outils_bck "test_ecriture" "${SOURCE}" >> ${VAR_LOG_NAME_UNIV_err} 2>&1
	else
		array_extra_true[$i_count_true_array]="${SOURCE}";
		let i_count_true_array++
	fi
	let i_check++
done

array_extra=(${array_extra_true[@]});
# FIN
creation_sous_titre_log "Sauvegarde des fichiers/dossiers (copie)" >> ${VAR_LOG_NAME_UNIV} & br ${VAR_LOG_NAME_UNIV}
init_fin_session ${VAR_LOG_NAME_UNIV_err} ${VAR_LOG_NAME_UNIV} ${VAR_LOG_NAME} 8 1>> "${VAR_LOG_NAME}" 2>&1
autoload_conf "${VAR_BCK_CHROOT}/init/init_module_end.sh"
