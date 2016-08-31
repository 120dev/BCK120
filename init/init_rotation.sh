## ------------ Initialisation ------------ ##
autoload_conf "${VAR_BCK_CHROOT}/init/init_module.sh"
## ------------ fin initialisation ------------ ##

if [ "$ROTATION" == "TRUE" ]
then
	CHROOT_ROTATION="$VAR_ROOT/ROTATION";
	VAR_ROTATION="$CHROOT_ROTATION/$ANNEE/$JOUR";
	creation_dossier "$VAR_ROTATION" 1>> "${VAR_LOG_NAME_UNIV}" 2>> "${VAR_LOG_NAME_UNIV_err}" || ${ROTATION"FALSE" && let error_OP++}
	
	if [ "${TYPE_ROTATION}" == "ARCHIVAGE" ]
	then 
		creation_dossier "${DOSSIER_ROTATION_ARCHIVAGE}" 1>> "${VAR_LOG_NAME_UNIV}" 2>> "${VAR_LOG_NAME_UNIV_err}" || ${ROTATION"FALSE" && let error_OP++}
	fi
	
	# COMPTEUR DE ROTATION
	ROTATION_FICHIER=0;
	ROTATION_ERROR=0;
	
	# On test les variables OBLIGATOIRES pour le bon fonctionnement du module.
	liste_variable=(array_Rotation NBR_JOUR_ROTATION );
	i=0;
	while [ $i -lt ${#liste_variable[*]} ];
	do
		if_empty ${liste_variable[$i]} >> ${VAR_LOG_NAME_UNIV_err}  || ROTATION="FALSE";
		let i++
	done
	
	# - > SI non definis alors on applique les parametres par defaut.
	if [ -z "${TYPE_ROTATION}" ]; then TYPE_ROTATION="ARCHIVAGE"; fi
	if [ -z "${MAXDEPTH}" ]; then MAXDEPTH=3; fi
	if [ -z "${COMPRESSION_ROTATION}" ]; then COMPRESSION_ROTATION="FALSE"; fi
	if [ -z "${FORMAT_COMPRESSION_ROTATION}" ]; then FORMAT_COMPRESSION_ROTATION="TARGZ"; fi
	if [ "${TYPE_ROTATION}" == "ARCHIVAGE" ]
	then
		if [ -z "${TYPE_ARCHIVAGE}" ]; then TYPE_ARCHIVAGE="COPIE"; fi
	fi
	
fi

# FIN
autoload_conf "${VAR_BCK_CHROOT}/init/init_module_end.sh"